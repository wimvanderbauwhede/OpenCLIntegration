/*
 * (c) 2011 Wim Vanderbauwhede <wim.vanderbauwhede@gmail.com>
 *
 * */

#ifndef __OCLWRAPPER_H__
#define __OCLWRAPPER_H__

#ifndef OCLV2
#define __NO_STD_VECTOR // Use cl::vector instead of STL version
#else
// OpenCL v1.2
#include <vector>
#endif

#ifdef OSX
// On OS X headers are in non-standard location
#include <cl.hpp>
#ifdef OCLV2
#include <OclKernelFunctor.h>
#endif
#else
// Not OS X, i.e. Linux
#ifdef OCLV2
#include <CL/cl.hpp>
// OpenCL v1.2
#include <OclKernelFunctor.h>
#else
#ifndef FPGA
#include <cl.hpp>
#else
// For Altera
#include <CL/cl.hpp>
#include <OclKernelFunctor.h>
#endif // FPGA
#endif
#endif


#include <sys/time.h>
//#include <cstdio>
//#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
#include <cstdlib>
//#include <iterator>
//#include <Timing.h>

#include <DeviceInfo.h>
#include <PlatformInfo.h>

#define OPENCL_TIMINGS
#define NBUFS 16
void checkErr(cl_int err, const char * name);
inline double wsecond();
typedef unsigned int uint;
enum DeviceType { CPU, GPU, ACC };
#if MRMODE==0
#define CL_MEM_READ_MODE CL_MEM_COPY_HOST_PTR
#elif MRMODE==1
#define CL_MEM_READ_MODE (CL_MEM_COPY_HOST_PTR | CL_MEM_ALLOC_HOST_PTR)
#elif MRMODE==2
// Seems this is problematic!
#define CL_MEM_READ_MODE CL_MEM_USE_HOST_PTR
#else
#define CL_MEM_READ_MODE CL_MEM_COPY_HOST_PTR // default
#endif

class OclWrapper {
	private:
		std::string kernelsource;
#ifdef OCLV2
		std::vector<cl::Platform> platformList;
#else
		cl::vector<cl::Platform> platformList;
#endif
		// This assumes a single context, a single device, a single program and a single kernel
// 		cl::vector<cl::Device> devices;
		const char* kernel_opts;
// 		int platformIdx, deviceIdx;
		bool useCPU;
		bool useGPU;
		bool useACC;
		cl_int err;                            // error code returned from API calls

		void getContextAndDevices();
		void getDevices();
		// For the Fortran interface, but we could use this approach in C/C++ as well
		void initArgStatus();
		
	public:
#ifdef OCLV2
		std::vector<cl::Device> devices;
#else
		cl::vector<cl::Device> devices;
#endif
		cl::Context* context_p;
		cl::Kernel* kernel_p;
		cl::Kernel kernel;
		cl::Program* program_p;
#ifndef OCLV2
		cl::KernelFunctor runKernel;
		cl::KernelFunctor kernel_functor;
#else
		OclKernelFunctor runKernel;
#endif
		cl::CommandQueue* queue_p;
		cl::CommandQueue queue;
		cl::Buffer* buf[NBUFS];
		cl::Buffer* buf_p;
		int nPlatforms;
		DeviceInfo deviceInfo;
		int platformIdx, deviceIdx;
#ifdef PLATINFO
		PlatformInfo platformInfo;
#endif
		int ncalls;
		// For the Fortran interface, but we could use this approach in C/C++ as well
		int argStatus[NBUFS];
		std::ostringstream kernelOpts;		
		OclWrapper ();
		OclWrapper (int deviceIdx);
//		OclWrapper ();
//		OclWrapper (const char* ksource, const char* kname, const char* kopts="");
        OclWrapper (const char* ksource, const char* kname, const char* kopts="",int devIdx=-1);
		void initOclWrapper(const char* ksource, const char* kname, const char* kopts="");

		bool hasCPU(int pIdx);
		bool hasGPU(int pIdx);
		bool hasACC(int pIdx);
		void showDeviceInfo();
		int nDevices(int pIdx, std::string dev);
		void selectDevice(int platformIdx, int deviceIdx, DeviceType devt);
		void selectDevice(int deviceIdx);
		void selectDevice();
		void selectCPU();
		void selectGPU();
		void selectACC();

		void setKernelOpts();
		void buildProgram(const char* ksource,const char* opts);
		void reloadKernel(const char* kname);
		void loadKernel(const char* kname);
		void loadKernel(const char* ksource, const char* kname);
		void loadKernel(const char* ksource, const char* kname, const char* opts);
		void loadBinary(const char* ksource);
		void storeBinary(const char* ksource);

		int getMaxComputeUnits();
		int getGlobalMemCacheType();
		unsigned long int getGlobalMemSize();
		unsigned long int getLocalMemSize();
        wv_size_t getPreferredWorkGroupSizeMultiple();
        wv_size_t getNThreadsHint();
        wv_size_t getWorkGroupSize();

		cl::Buffer& makeWriteBuffer( int bufSize );
//		cl::Buffer* makeStaticWriteBuffer( int idx,int bufSize );
		void makeWriteBufferPos(int argpos, int bufSize );

		cl::Buffer& makeReadBuffer(int bufSize, void* hostBuf = NULL, cl_mem_flags flags = CL_MEM_READ_ONLY );
		cl::Buffer& makeReadWriteBuffer(int bufSize, void* hostBuf = NULL, cl_mem_flags flags = CL_MEM_READ_WRITE);
		cl::Buffer& makeReadBuffer(int bufSize, const void* hostBuf , cl_mem_flags flags = CL_MEM_READ_ONLY );
		cl::Buffer& makeReadWriteBuffer(int bufSize, const void* hostBuf , cl_mem_flags flags = CL_MEM_READ_WRITE);
//		cl::Buffer* makeStaticReadBuffer(int idx,int bufSize, void* hostBuf = NULL, cl_mem_flags flags = CL_MEM_READ_ONLY );
		void makeReadBufferPos(int argpos, int bufSize);

		void createQueue();
		void setArg(unsigned int idx, const cl::Buffer& buf);
		void setArg(unsigned int idx, const int buf);
		void setArg(unsigned int idx, const float buf);
		int enqueueNDRangeOffset(const cl::NDRange& = cl::NDRange(0),const cl::NDRange& = cl::NDRange(1),const cl::NDRange& = cl::NullRange);
		int enqueueNDRange(const cl::NDRange& = cl::NDRange(1),const cl::NDRange& = cl::NullRange);
		int enqueueNDRangeRun(const cl::NDRange& = cl::NDRange(1),const cl::NDRange& = cl::NullRange);
		float enqueueNDRangeRun(unsigned int = 1, unsigned int = 0);
		void readBuffer(const cl::Buffer& deviceBuf, int bufSize, void* hostBuf);
		void readBuffer(const cl::Buffer& deviceBuf, int bufSize, const void* hostBuf);
		void readBuffer(
				const cl::Buffer& buffer,
				bool blocking_read,
				::wv_size_t offset,
				::wv_size_t size,
				void * ptr,
				const VECTOR_CLASS<cl::Event> * events = NULL,
				cl::Event * event = NULL);
		void readBuffer(
				const cl::Buffer& buffer,
				bool blocking_read,
				::wv_size_t offset,
				::wv_size_t size,
				const void * ptr,
				const VECTOR_CLASS<cl::Event> * events = NULL,
				cl::Event * event = NULL);
//		void readStaticBuffer(int idx, int bufSize, void* hostBuf);
		void readBufferPos(int argpos, int bufSize, void* hostBuf);

		void writeBuffer(const cl::Buffer& deviceBuf, int bufSize, void* hostBuf);
		void writeBuffer(
				const cl::Buffer& deviceBuf,
				bool blocking_write,
				::wv_size_t offset,
				::wv_size_t size,
				void * ptr,
				const VECTOR_CLASS<cl::Event> * events = NULL,
				cl::Event * event = NULL);
		void writeBuffer(const cl::Buffer& deviceBuf, int bufSize, const void* hostBuf);
		void writeBuffer(
				const cl::Buffer& deviceBuf,
				bool blocking_write,
				::wv_size_t offset,
				::wv_size_t size,
				const void * ptr,
				const VECTOR_CLASS<cl::Event> * events = NULL,
				cl::Event * event = NULL);
		void writeBufferPos(int argpos, int bufSize, void* hostBuf);
#ifdef OPENCL_TIMINGS
		double getExecutionTime (const cl::Event& event);
#endif

};


double wsecond()
{
        struct timeval sampletime;
        double         time;

        gettimeofday( &sampletime, NULL );
        time = sampletime.tv_sec + (sampletime.tv_usec / 1000000.0);
        return( time*1000.0 ); // return time in ms
}

#endif  // __OCLWRAPPER_H__
