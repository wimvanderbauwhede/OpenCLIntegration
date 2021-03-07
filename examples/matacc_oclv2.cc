#define CL_HPP_TARGET_OPENCL_VERSION 200
#include <CL/cl2.hpp>
#include <iostream>
#include <vector>
#include <memory>
#include <algorithm>
#include <sys/time.h>

#define WIDTH 1024
//1024
#undef VERBOSE
#define NRUNS 5

inline void checkErr(cl_int err, const char * name);
inline double wsecond();


int main(void)
{
    const uint mSize = WIDTH*WIDTH;
    const uint mWidth = WIDTH;

    // Create the data sets   
    //cl_int* mA=(cl_int*)malloc(sizeof(cl_int)*mSize);
    cl_int* mA = new cl_int[mSize];
    // cl_int* mB=(cl_int*)malloc(sizeof(cl_int)*mSize);
    cl_int* mB = new cl_int[mSize];
   

    for(unsigned int i = 0; i < mSize; i++) {
        mA[i] = rand() % 64;
        mB[i] = rand() % 64;
    }
    // cl_int* mCref=(cl_int*)malloc(sizeof(cl_int)*mSize);
    cl_int* mCref= new cl_int[mSize];

    double tstartref=wsecond();
/*
 * To make this multi-threaded I must pass the pointers for mA, mB, mC and a th_id to the thread.
 * So I need some struct which I then cast to void* etc.
 * */
    for (uint idx = 0; idx<mSize; idx++) {
        unsigned int x=idx % mWidth;
        unsigned int y=idx / mWidth;    	
        int elt=0.0;
        for (unsigned int i=0;i<mWidth;i++) {    
            elt+=mA[y*mWidth+i]*mB[i*mWidth+x];
        }
//        printf("%d\n",elt);
        mCref[x+mWidth*y]=elt;
    }
    
    double tstopref=wsecond();
#ifdef VERBOSE
    std::cout << "Execution time for reference: "<<(tstopref-tstartref)<<" ms\n";
#else
//for (int run=0;run<=NRUNS;run++) {
    std::cout << "\t"<<(tstopref-tstartref);//<<"\n";
//}
#endif
    //--------------------------------------------------------------------------------
    //---- Here starts the actual OpenCL part
    //--------------------------------------------------------------------------------

#ifdef VERBOSE
    std::cout << "Entering OpenCL part \n";
#endif
    // WV: I can use this when OCLV22 is set
    // Filter for a 2.0 platform and set it as the default
    std::vector<cl::Platform> platforms; // WV: this is platformList 
    cl::Platform::get(&platforms); // WV: this is in the ctor already
    cl::Platform plat; // WV: see getContextAndDevices
    for (auto &p : platforms) {
        std::string platver = p.getInfo<CL_PLATFORM_VERSION>();
        if (platver.find("OpenCL 2.") != std::string::npos) {
            plat = p;
        }
    }
    if (plat() == 0)  {
        std::cout << "No OpenCL 2.0 platform found.";
        return -1;
    }
    cl::Platform newP = cl::Platform::setDefault(plat); // WV This means the API will use this platform
    if (newP != plat) {
        std::cout << "Error setting default platform.";
        return -1;
    }
    
    //cl::CommandQueue queue = cl::CommandQueue(cl::Context::getDefault(), cl::Device::getDefault(), 0, &err); // WV No need
    
    // Use C++11 raw string literals for kernel source code
    
    std::string matmultkernel{R"CLC(
__kernel void matmultKernel (
    __global int *mA,
    __global int *mB,
    __global int *mC,
    const unsigned int mWidth) {

// naive means every kernel does one element 
    unsigned int idx=get_global_id(0);
    unsigned int x=idx % mWidth;
    unsigned int y=idx / mWidth;

    int elt=0.0;
    for (unsigned int i=0;i<mWidth;i++) {    
        elt+=mA[y*mWidth+i]*mB[i*mWidth+x];
    }
//    printf("%d %d\n",idx,elt);
    mC[idx]=elt;

}
    )CLC"};

    // New simpler string interface style
    std::vector<std::string> programStrings {matmultkernel};
    cl::Program matMultProgram(programStrings);
    
    try {
        matMultProgram.build("-cl-std=CL2.0"); // WV: for OCLV22, OclWrapper::buildProgram
    }
    catch (...) { // WV: a good use for try/catch
        // Print build info for all devices
        cl_int buildErr = CL_SUCCESS;
        auto buildInfo = matMultProgram.getBuildInfo<CL_PROGRAM_BUILD_LOG>(&buildErr);
        for (auto &pair : buildInfo) {
            std::cerr << pair.second << std::endl << std::endl;
        }
        return 1;
    }


        // Traditional cl_mem allocations
        
/*
        std::cout << "Creating cl:Buffer mA_buf\n";        
    cl::Buffer mA_buf(CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, sizeof(cl_int) * mSize, (void*)mA, &err);
    checkErr(err, "cl::Buffer(mA)");
    std::cout << "Creating cl:Buffer mB_buf\n";
    cl::Buffer mB_buf(CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR, sizeof(cl_int) * mSize, (void*)mB, &err);
    checkErr(err, "cl::Buffer(mB)");
    std::cout << "Creating cl:Buffer mC_buf\n";
    cl::Buffer mC_buf(CL_MEM_WRITE_ONLY, sizeof(cl_int) * mSize,nullptr, &err);
    checkErr(err, "cl::Buffer(mC)");
*/
    std::vector<int> mAvec(mA, mA+mSize);
    std::vector<int> mBvec(mB, mB+mSize);

    // cl_int* mC=(cl_int*)malloc(sizeof(cl_int)*mSize);
    cl_int* mC = new cl_int[mSize];

    std::vector<int> mCvec(mC,mC+mSize); 
    cl::Buffer *mA_buf = new cl::Buffer(begin(mAvec), end(mAvec), true);
    cl::Buffer mB_buf(begin(mBvec), end(mBvec), true);
    cl::Buffer mC_buf(begin(mCvec), end(mCvec), false);    
#ifdef DBG
std::cout << "Start run loop\n";
#endif        
    for (int run=1;run<=NRUNS;run++) {
      double tstart=wsecond();
#ifdef DBG      
std::cout << "Buffer write\n";
#endif
    /*
	err = 
	queue.enqueueWriteBuffer(
	            mA_buf,
	            CL_TRUE,
	            0,
	            (::size_t)mSize,
	            (void*)mA);     
    checkErr(err, "cl::Buffer(mA)"); 

	err = queue.enqueueWriteBuffer(
	            mB_buf,
	            CL_TRUE,
	            0,
	            (::size_t)mSize,
	            (void*)mB);     
    checkErr(err, "cl::Buffer(mB)");    
    */
   // WV This should be inside writeBuffer()
   // So I need a variant of writeBuffer for vectors
    cl::copy(begin(mAvec), end(mAvec),*mA_buf);
    cl::copy(begin(mBvec), end(mBvec),mB_buf);
	//ocl.writeBuffer( mA_buf, sizeof(cl_int)*mSize, mA);
	//ocl.writeBuffer( mB_buf, sizeof(cl_int)*mSize, mB);    
	
    // Default queue, also passed in as a parameter
    // WV apparently we don't need this
    cl::DeviceCommandQueue defaultDeviceQueue = cl::DeviceCommandQueue::makeDefault(
        cl::Context::getDefault(), cl::Device::getDefault()
    );
    cl_int error;
// WV: this is the key problem for use in Fortran
    auto matMultKernel =
        cl::KernelFunctor<
            cl::Buffer,
            cl::Buffer,
            cl::Buffer,
            unsigned int
//            cl::DeviceCommandQueue
            
        >(matMultProgram, "matmultKernel");
#ifdef DBG        
    std::cout << "Kernel invocation\n";        
#endif    
    cl::Event event = matMultKernel(
        cl::EnqueueArgs(
            cl::NDRange(mSize),
            cl::NullRange
        ),
        *mA_buf,
        mB_buf,
        mC_buf,
        mWidth,
        error        
    );
    event.wait(); // WV:Apparently no need for this
#ifdef DBG    
    std::cout << "Error value: "<<error << "\n";    
    std::cout << "Buffer read back\n";
#endif
    /*
    // Somehow this is incorrect
	err = queue.enqueueReadBuffer(
	            mC_buf,
	            CL_TRUE,
	            0,
	            (::size_t)mSize,
	            (void*)mC);
    checkErr(err, "cl::Buffer(mC)"); 
*/
    cl::copy(mC_buf, begin(mCvec), end(mCvec));
    mC = &mCvec[0];

//    cl::Device d = cl::Device::getDefault();
 double tstop=wsecond();
    //--------------------------------------------------------------------------------
    //----  Here ends the actual OpenCL part
    //--------------------------------------------------------------------------------
#ifdef VERBOSE

    unsigned int correct=0;               // number of correct results returned
    int nerrors=0;
    int max_nerrors=mSize;
    for (unsigned int i = 0; i < mSize; i++) {
//    std::cout <<mC[i] << "<>" << mCref[i] << "\n";
		int diff = mC[i] - mCref[i];
        if(diff==0) { // 2**-20
            correct++;
        } else {
        	nerrors++;
        	if (nerrors>max_nerrors) break;
        }
    }
    
    if (nerrors==0) {
	    std::cout << "Correct!\n";
    }  else {
	    std::cout << "#errors: "<<nerrors<<"\n";
	    std::cout << "Computed '"<<correct<<"/"<<mSize<<"' correct values!\n";
    }
    std::cout << "OpenCL execution time "<<(tstop-tstart)<<" ms\n";
    

#else // NOT VERBOSE

    std::cout <<"\t"<< (tstop-tstart);//<<"\n";
#endif // VERBOSE
} // loop over NRUNS
    delete [] mCref;
    delete [] mA;
    delete [] mB;
    //free(mC);
    return 0;
}


inline void checkErr(cl_int err, const char * name) {
	if (err != CL_SUCCESS) {
		std::cerr << "ERROR: " << name << " (" << err << ")" << std::endl;
		exit( EXIT_FAILURE);
	}
}

double wsecond()
{
        struct timeval sampletime;
        double         time;

        gettimeofday( &sampletime, NULL );
        time = sampletime.tv_sec + (sampletime.tv_usec / 1000000.0);
        return( time*1000.0 ); // return time in ms
}

