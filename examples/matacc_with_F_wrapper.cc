#include "OclWrapperF.h"
//#include "OclWrapper.h"
// Use a static data size for simplicity
//
//#define WIDTH 1024
// 1024*1024 gives segmentation fault when using static allocation, because it's on the stack
// 32M is the max because CL_DEVICE_MAX_MEM_ALLOC_SIZE = 128MB for my iMac, and a cl_float is 4 bytes.

int main(void)
{


	int nruns=NRUNS;
    // this array uses stack memory because it's declared inside of a function. 
    // So the size of the stack determines the max array size! 
    //cl_float data[DATA_SIZE];              // original data set given to device
    //cl_float results[DATA_SIZE];           // results returned from device


    const uint mSize = WIDTH*WIDTH;
    const uint mWidth = WIDTH;

    // Create the data sets   
    cl_float* mA=(cl_float*)malloc(sizeof(cl_float)*mSize);
    for(unsigned int i = 0; i < mSize; i++) {
        mA[i] = (cl_float)(1.0/(float)mSize);
    }
#if REF!=0
    cl_float mCref=0.0;
    for (int run=1;run<=nruns;run++) {
    	mCref=0.0;
    double tstartref=wsecond();

    for (uint i = 0; i<mWidth; i++) {
    	for (uint j = 0; j<mWidth; j++) {
			mCref+=mA[i*mWidth+j];
		}
	}

    double tstopref=wsecond();
#ifdef VERBOSE
    std::cout << "Execution time for reference: "<<(tstopref-tstartref)<<" ms\n";
#else
    std::cout <<"\t"<< (tstopref-tstartref); //<<"\n";
#endif
    }
#endif
#if REF!=2
    //--------------------------------------------------------------------------------
    //---- Here starts the actual OpenCL part
    //--------------------------------------------------------------------------------
    float exectime[1]={0.0};
    // Now load the kernel
    int knum= KERNEL;
    std::ostringstream sstr; sstr << "mataccKernel"<< knum;
    std::string stlstr=sstr.str();
    const char* kstr = stlstr.c_str();

    int64_t ocl_ivp;
    oclinitc_(&ocl_ivp,"matacc.cl",kstr);

    int nunits;
    oclgetmaxcomputeunitsc_(&ocl_ivp,&nunits);
#ifdef VERBOSE
    std::cout << "Number of compute units: "<<nunits<< "\n";
#endif // VERBOSE

    // Allocate space for results
    cl_float* mC=(cl_float*)malloc(sizeof(cl_float)*nunits);
    // Create the buffers
    int64_t mA_buf_ivp;
    int mSz[1];
    mSz[0] = sizeof(cl_float) * mSize;
    oclmakereadbufferc_(&ocl_ivp,&mA_buf_ivp,mSz); // this results in a new value for mA_buf_ivp
    int64_t mC_buf_ivp;
    int unitSz[1];
    unitSz[0] = sizeof(cl_float) * nunits;
	oclmakewritebufferc_(&ocl_ivp,&mC_buf_ivp,unitSz); // this results in a new value for mA_buf_ivp
	// setArg takes the index of the argument and a value of the same type as the kernel argument
    int zero[1] = {0};
    int one[1] = {1};
    int two[1] = {2};
    oclsetfloatarrayargc_(&ocl_ivp,zero, &mA_buf_ivp );
    oclsetfloatarrayargc_(&ocl_ivp,one, &mC_buf_ivp);
    oclsetintconstargc_(&ocl_ivp,two, (int*)(&mWidth));

for (int run=1;run<=nruns;run++) {
	oclwritebufferc_(&ocl_ivp,&mA_buf_ivp,mSz,mA);

    // This is the actual "run" command.
	double tstart=wsecond();
    runoclc_(&ocl_ivp,
#if KERNEL<7 || KERNEL==14
            &nunits,
            one
#elif KERNEL<=8 || KERNEL==15
            &(nunits*16),
            (16) // 16 threads
#elif KERNEL==9 || KERNEL==16
            (nunits*32),
            (32) // 32 threads
#elif KERNEL==10
            (nunits*16),
            (16) // 16 threads
#elif KERNEL==12
            (nunits*16),
            (16) // 16 threads
#elif KERNEL==13 || KERNEL==17
            (nunits*64),
            (64) // 64 threads
#elif KERNEL==18 || KERNEL==20
            (nunits*128),
            (128) // 128 threads
#elif KERNEL==19
            (nunits*256),
            (256) // 256 threads
#elif KERNEL==11
            (nunits),
            (1) // single thread
#endif
        ,exectime    );
    // Read back the results
    oclreadbufferc_(&ocl_ivp,&mC_buf_ivp,unitSz,mC);
    double tstop=wsecond();
#endif // REF!=2
    //--------------------------------------------------------------------------------
    //----  Here ends the actual OpenCL part
    //--------------------------------------------------------------------------------
#ifdef VERBOSE
#if REF==1
    float mCtot=0.0;
    for (unsigned int i=0;i<nunits;i++) {
    	mCtot+=mC[i];
    }
    unsigned int correct=0;               // number of correct results returned
        if(mCtot == mCref) {
            correct++;
        }
    std::cout << mCtot <<"<>"<< mCref<<"\n";
    std::cout << (correct==0 ? "Incorrect" : "Correct") <<"\n";
#endif
#if REF!=2
    std::cout << "OpenCL execution time "<<(tstop-tstart)<<" ms\n";
    std::cout << "OpenCL kernel execution time "<<*exectime<<" ms\n";
} // nruns
#endif
#else
#if REF!=2
    std::cout << "\t"<<(tstop-tstart);//<<"\n";
} // nruns
#endif
#endif


    free(mA);
#if REF!=2
    free(mC);
#endif
    return EXIT_SUCCESS;

}
