/*
 * (c) 2011 Wim Vanderbauwhede <wim.vanderbauwhede@gmail.com>
 *
 * */

#include "OclWrapper.h"

// ----------------------------------------------------------------------------------------
// Constructors
// ----------------------------------------------------------------------------------------

OclWrapper::OclWrapper () :
kernel_opts(""),
#ifdef DEV_GPU
useCPU(false),
useGPU(true),
useACC(false),
#else
#ifdef DEV_ACC
useCPU(false),
useGPU(false),
useACC(true),
#else
useCPU(true),
useGPU(false),
useACC(false),
#endif
#endif
nPlatforms(0), ncalls(0) {
//std::cout << "Default constructor\n";
	    // First check the Platform
		cl::Platform::get(&platformList);
		checkErr(platformList.size() != 0 ? CL_SUCCESS : -1, "cl::Platform::get");
#ifdef VERBOSE
//		std::cerr << "Number of platforms is: " << platformList.size() << std::endl;
#endif
		nPlatforms=platformList.size();
#ifdef PLATINFO
		for (unsigned int i=0;i<platformList.size();i++) {
			platformInfo.show(platformList,i);
		}
#endif

		selectDevice();
		createQueue();
        initArgStatus();
//std::cout << "Default constructor DONE\n";
        
    }

OclWrapper::OclWrapper (const char* ksource, const char* kname, const char* kopts) :
#ifdef DEV_GPU
useCPU(false),
useGPU(true),
useACC(false),
#else
#ifdef DEV_ACC
useCPU(false),
useGPU(false),
useACC(true),
#else
useCPU(true),
useGPU(false),
useACC(false),
#endif
#endif
nPlatforms(0), ncalls(0) {

	    // First check the Platform
		cl::Platform::get(&platformList);
		checkErr(platformList.size() != 0 ? CL_SUCCESS : -1, "cl::Platform::get");
#ifdef VERBOSE
//		std::cerr << "Number of platforms is: " << platformList.size() << std::endl;
#endif
		nPlatforms=platformList.size();
#ifdef PLATINFO
		for (unsigned int i=0;i<platformList.size();i++) {
			platformInfo.show(platformList,i);
		}
#endif

		selectDevice();
		loadKernel( ksource,  kname, kopts);
		createQueue();
        initArgStatus();
}

void OclWrapper::initOclWrapper(const char* ksource, const char* kname, const char* kopts)  {
#ifdef DEV_GPU
useCPU=false;
useGPU=true;
useACC=false;
#else
#ifdef DEV_ACC
useCPU=false;
useGPU=false;
useACC=true;
#else
useCPU=true;
useGPU=false;
useACC=false;
#endif
#endif


	nPlatforms=0;
	ncalls=0;

    // First check the Platform
	cl::Platform::get(&platformList);
	checkErr(platformList.size() != 0 ? CL_SUCCESS : -1, "cl::Platform::get");
#ifdef VERBOSE
	std::cerr << "Number of platforms is: " << platformList.size() << std::endl;
#endif
	nPlatforms=platformList.size();
#ifdef PLATINFO
	for (unsigned int i=0;i<platformList.size();i++) {
		platformInfo.show(platformList,i);
	}
#endif

	selectDevice();
	if (strcmp(kopts,"")==0) {
		 std::string stlstr=kernelOpts.str();
		 kernel_opts = stlstr.c_str();
		 std::cout << "initOclWrapper: KERNEL_OPTS: "<<kernel_opts << "\n";
//std::cout << "initOclWrapper: "<<ksource<<";"<<kname<<"\n";
		 loadKernel( ksource,  kname, kernel_opts);
			std::cout << "initOclWrapper: loaded kernel\n";
	} else {
		loadKernel( ksource,  kname, kopts);
	}
	createQueue();
//			std::cout << "initOclWrapper: created queue\n";
    initArgStatus();
//			std::cout << "initOclWrapper: initialised ArgStatus\n";
}

OclWrapper::OclWrapper (int devIdx) :
#ifdef DEV_GPU
useCPU(false),
useGPU(true),
useACC(false),
#else
#ifdef DEV_ACC
useCPU(false),
useGPU(false),
useACC(true),
#else
useCPU(true),
useGPU(false),
useACC(false),
#endif
#endif
		nPlatforms(0) {

	    // First check the Platform
		cl::Platform::get(&platformList);
		checkErr(platformList.size() != 0 ? CL_SUCCESS : -1, "cl::Platform::get");
#ifdef VERBOSE
		std::cerr << "Number of platforms is: " << platformList.size() << std::endl;
#endif
		nPlatforms=platformList.size();
#ifdef PLATINFO
		for (unsigned int i=0;i<platformList.size();i++) {
			platformInfo.show(platformList,i);
		}
#endif

		selectDevice(devIdx);
		createQueue();
        initArgStatus();
    }

//OclWrapper::OclWrapper () : nPlatforms(0) {
//	    // First check the Platform
//		cl::Platform::get(&platformList);
//		checkErr(platformList.size() != 0 ? CL_SUCCESS : -1, "cl::Platform::get");
//#ifdef VERBOSE
//		std::cerr << "Number of platforms is: " << platformList.size() << std::endl;
//#endif
//		nPlatforms=platformList.size();
//#ifdef PLATINFO
//		for (unsigned int i=0;i<platformList.size();i++) {
//			std::cout << "Platform["<< i << "]\n";
//			platformInfo.show(platformList,i);
//		}
//#endif
//        initArgStatus();
//
//   }
// ----------------------------------------------------------------------------------------
// Other public methods
// ----------------------------------------------------------------------------------------

void OclWrapper::setKernelOpts() {

    std::string stlstr=kernelOpts.str();
    kernel_opts = stlstr.c_str();
	std::cout << "setKernelOpts: KERNEL_OPTS: "<<kernel_opts << "\n";
}

bool OclWrapper::hasACC(int i) {

	const cl::Platform& platform=platformList[i];
//	cl::vector<cl::Device> gpus;
	cl_int err= platform.getDevices(CL_DEVICE_TYPE_ACCELERATOR, &devices);
	return (err!=CL_DEVICE_NOT_FOUND);
}
bool OclWrapper::hasGPU(int i) {

	const cl::Platform& platform=platformList[i];
//	cl::vector<cl::Device> gpus;
	cl_int err= platform.getDevices(CL_DEVICE_TYPE_GPU, &devices);
	return (err!=CL_DEVICE_NOT_FOUND);
}

bool OclWrapper::hasCPU(int i) {
	const cl::Platform& platform=platformList[i];
	cl_int err= platform.getDevices(CL_DEVICE_TYPE_CPU, &devices);
	return (err!=CL_DEVICE_NOT_FOUND);
}

int OclWrapper::nDevices(int pIdx, std::string devt) {
	const cl::Platform& platform=platformList[pIdx];
	if (devt=="GPU") {
		platform.getDevices(CL_DEVICE_TYPE_GPU, &devices);
	} else if (devt=="CPU") {
		platform.getDevices(CL_DEVICE_TYPE_CPU, &devices);
	} else if (devt=="ACC") {
		platform.getDevices(CL_DEVICE_TYPE_ACCELERATOR, &devices);
	} else {
		platform.getDevices(CL_DEVICE_TYPE_ALL, &devices);
	}
	int nDevs=devices.size();
//	std::cout << "Number of "<<devt<<" devices for platform "<<pIdx<<": "<< nDevs << "\n";
#ifdef DEVINFO
	for (int dIdx=0;dIdx<nDevs;dIdx++) {
		std::cout << devt<<" Device["<< dIdx << "]: ";
		deviceInfo.show(devices[dIdx]);
	}
#endif
	return nDevs;
}
void OclWrapper::selectGPU() {
	useCPU=false;
	useACC=false;
	useGPU=true;
	selectDevice();
}

void OclWrapper::selectCPU() {
	useGPU=false;
	useCPU=true;
	useACC=false;
	selectDevice();
}

void OclWrapper::selectACC() {
	useGPU=false;
	useCPU=false;
	useACC=true;
	selectDevice();
}

void OclWrapper::selectDevice(int pIdx, int dIdx, DeviceType devt) {
    // Use the platform info as input for the Context
	platformIdx=pIdx;
	deviceIdx=dIdx;
	switch (devt) {
		case GPU: {
				  useCPU=false;
				  useACC=false;
				  useGPU=true;
				  break;
			  }
		case CPU: {
				  useGPU=false;
				  useCPU=true;
				  useACC=false;
				  break;
			  }

		case ACC: {
				  useGPU=false;
				  useCPU=false;
				  useACC=true;
				  break;
			  }
	};
	getContextAndDevices();
#ifdef DEVINFO
    deviceInfo.show(devices[deviceIdx]);
#endif
}

// Here we set the attributes platformIdx and deviceIdx
void OclWrapper::selectDevice() {

	// So we must first select the platform that has a GPU, then the device that is a GPU
	//bool useCPU = not useGPU;
	platformIdx=0;
	deviceIdx=0;

	for (unsigned int i=0; i<platformList.size();i++) {

		if ((useGPU && hasGPU(i)) 
				|| (useCPU && hasCPU(i))
				|| (useACC && hasACC(i))
		   ) {
			platformIdx=i;
#ifdef DEVINFO
			std::cout << "Found platform "<<platformIdx<< " for ";
			if (useGPU) {
				std::cout << "GPU" <<"\n";
			} else if (useACC) {
				std::cout << "ACC" << "\n";
			} else if (useCPU) {
				std::cout << "CPU" << "\n";
			}
#endif
			break;
		}
	}

	getContextAndDevices();

	for (unsigned int i=0;i<devices.size();i++) {
		if ( (useGPU && deviceInfo.isGPU(devices[i])) 
		|| (useCPU && deviceInfo.isCPU(devices[i])) 
		|| (useACC && deviceInfo.isACC(devices[i])) 
		) {
			deviceIdx=i;
			break;
		}
	}

#ifdef DEVINFO
	deviceInfo.show(devices[deviceIdx]);
#endif
}

// Here we set the attributes platformIdx and deviceIdx
void OclWrapper::selectDevice(int devIdx) {

	// So we must first select the platform that has a GPU, then the device that is a GPU
	//bool useCPU = not useGPU;
	platformIdx=0;
	deviceIdx=0;

	for (unsigned int i=0; i<platformList.size();i++) {

		if ((useGPU && hasGPU(i)) 
				|| (useCPU && hasCPU(i))
				|| (useACC && hasACC(i))
		   ) {
			platformIdx=i;
			break;
		}
	}
	if (devIdx==-1) {
        //std::cout << "Automatic device selection: ";
		for (unsigned int i=0;i<devices.size();i++) {
			if ( (useGPU && deviceInfo.isGPU(devices[i])) 
		|| (useCPU && deviceInfo.isCPU(devices[i])) 
		|| (useACC && deviceInfo.isACC(devices[i])) 
		) {
				deviceIdx=i;
#ifdef DEVINFO
				std::cout << "Found platform "<<platformIdx<< " for ";
				if (useGPU) {
					std::cout << "GPU " <<deviceIdx<<"\n";
				} else if (useACC) {
					std::cout << "ACC " << deviceIdx <<"\n";
				} else if (useCPU) {
					std::cout << "CPU " << deviceIdx << "\n";
				} 
#endif
				break;
			}
		}
	} else {
        deviceIdx=devIdx;
    }
	getContextAndDevices();

#ifdef DEVINFO
	std::cout << "Number of devices: "<<devices.size() << "\n";
	std::cout << "Device Info for Platform "<<platformIdx << ", Device "<<deviceIdx<<"\n";
	deviceInfo.show(devices[deviceIdx]);
#endif
} // END of selectDevice()

void OclWrapper::buildProgram(const char* ksource, const char* opts) {
    std::ifstream file(ksource);
    checkErr(file.is_open() ? CL_SUCCESS:-1, ksource);

    std::string prog(
            std::istreambuf_iterator<char>(file),
            (std::istreambuf_iterator<char>())
            );
//    std::cout <<"Program from source\n";
    cl::Program::Sources source(1, std::make_pair(prog.c_str(), prog.length()+1));
//    std::cout <<"new Program\n";

    program_p = new cl::Program(*context_p, source);
//    program = *program_p;
//    std::cout <<"build Program\n";
    err = program_p->build(devices,opts);
    checkErr(file.is_open() ? CL_SUCCESS : -1, "Program::build()");
}

//void OclWrapper::buildProgram(const char* ksource) {
//    std::ifstream file(ksource);
//    checkErr(file.is_open() ? CL_SUCCESS:-1, ksource);
//
//    std::string prog(
//            std::istreambuf_iterator<char>(file),
//            (std::istreambuf_iterator<char>())
//            );
////    std::cout <<"Program from source\n";
//    cl::Program::Sources source(1, std::make_pair(prog.c_str(), prog.length()+1));
////    std::cout <<"new Program\n";
//
//    program_p = new cl::Program(*context_p, source);
////    program = *program_p;
////    std::cout <<"build Program\n";
//    err = program_p->build(devices,"");
//    checkErr(file.is_open() ? CL_SUCCESS : -1, "Program::build()");
//}


void OclWrapper::loadBinary(const char* ksource) {
    std::ifstream file(ksource);
    checkErr(file.is_open() ? CL_SUCCESS:-1, ksource);

    std::string prog(
            std::istreambuf_iterator<char>(file),
            (std::istreambuf_iterator<char>())
            );

    cl::Program::Binaries binaries(1, std::make_pair(prog.c_str(), prog.length()+1));
#ifdef OCLV2
    std::vector<cl_int> binaryStatus;
#else
    cl::vector<cl_int> binaryStatus;
#endif    
    program_p = new cl::Program(*context_p, devices, binaries, &binaryStatus, &err);
    checkErr(file.is_open() ? CL_SUCCESS : -1, "Program::Program() from Binary");
}

void OclWrapper::storeBinary(const char* ksource) {
#ifdef OCLV2
	std::vector<char*> binaries;
#else
	cl::vector<char*> binaries;
#endif
	err = program_p->getInfo(CL_PROGRAM_BINARIES,&binaries);
	checkErr(err, "Program::getInfo(CL_PROGRAM_BINARIES)");
	// Now write this binary to a file
	std::ofstream file(ksource);
// ...
}

void OclWrapper::reloadKernel(const char* kname) {
    kernel_p= new cl::Kernel(*program_p, kname, &err);
    kernel = *kernel_p;
    checkErr(err, "Kernel::Kernel()");
}

void OclWrapper::loadKernel(const char* kname) {
    kernel_p= new cl::Kernel(*program_p, kname, &err);
    kernel = *kernel_p;
    checkErr(err, "Kernel::Kernel()");
}
void OclWrapper::loadKernel(const char* ksource, const char* kname) {
    //std::cout << "buildProgram\n";
	buildProgram(ksource,"");
    //std::cout << "new Kernel\n";
    kernel_p= new cl::Kernel(*program_p, kname, &err);
    kernel = *kernel_p;
    checkErr(err, "Kernel::Kernel()");
}
void OclWrapper::loadKernel(const char* ksource, const char* kname,const char* opts) {
    std::cout << "buildProgram <" << ksource << ">\n";
	buildProgram(ksource,opts);
    std::cout << "new Kernel <"<< kname <<">\n";
    kernel_p= new cl::Kernel(*program_p, kname, &err);
    kernel = *kernel_p;
    checkErr(err, "loadKernel::Kernel()");
}


void OclWrapper::createQueue() {
   // std::cout << "Device Idx: "<<deviceIdx<<"\n";
	
    // Create the CommandQueue
	queue_p = new cl::CommandQueue(*context_p, devices[deviceIdx], 0, &err);

    checkErr(err, "CommandQueue::CommandQueue()");
}
void OclWrapper::setArg(unsigned int idx, const cl::Buffer& buf) {
    err = kernel_p->setArg(idx, buf );
    checkErr(err, "Kernel::setArg()");
}
void OclWrapper::setArg(unsigned int idx, const float buf) {
    err = kernel_p->setArg(idx, buf );
    checkErr(err, "Kernel::setArg()");
}
void OclWrapper::setArg(unsigned int idx, const int buf) {
    err = kernel_p->setArg(idx, buf );
    checkErr(err, "Kernel::setArg()");
}

int OclWrapper::enqueueNDRangeRun(const cl::NDRange& globalRange,const cl::NDRange& localRange) {
	// Create the CommandQueue
    if ((void*)queue_p==NULL) {
#ifdef VERBOSE
			std::cout<<"Creating queue...\n";
#endif
			queue_p = new cl::CommandQueue(*context_p, devices[deviceIdx], 0, &err);
            checkErr(err, "CommandQueue::CommandQueue()");
    }
	ncalls++;
// VERBOSE
//	std::cout << "# kernel calls: "<<ncalls <<std::endl;
	cl::Event event;
//	std::cout << "ocl:"<<this<<"\n";
//    std::cout << "queue_p:"<<queue_p<<"\n";
//    std::cout << "kernel_p:"<<kernel_p<<"\n";
//    std::cout << "FIXME! enqueueNDRangeKernel is commented out!\n";
    // the kernel can be queried successfully ...
#ifdef VERBOSE
    // When calling from Fortran, the next line gives the error:
    // mataccF(3498,0x7fff70c14cc0) malloc: *** error for object 0x1000d1840: pointer being freed was not allocated
    // *** set a breakpoint in malloc_error_break to debug
    //const std::string infostr = this->kernel_p->getInfo<CL_KERNEL_FUNCTION_NAME>() ;
    //std::cout << infostr <<"\n";
#endif // VERBOSE
	err = queue_p->enqueueNDRangeKernel(
            *kernel_p,
            cl::NullRange,
	    globalRange,localRange,
	    NULL,&event);
	event.wait(); // here is where it goes wrong with "-36, CL_INVALID_COMMAND_QUEUE

    return ncalls;
}

int OclWrapper::enqueueNDRange(const cl::NDRange& globalRange,const cl::NDRange& localRange) {
	// Create the CommandQueue
	if ((void*)queue_p==NULL) {
		queue_p = new cl::CommandQueue(*context_p, devices[deviceIdx], 0, &err);
	}
	checkErr(err, "CommandQueue::CommandQueue()");
	ncalls++;
// VERBOSE
	//std::cout << "# kernel calls: "<<ncalls <<std::endl;
#ifndef OCLV2
	runKernel=kernel_p->bind(*queue_p,globalRange, localRange);
	kernel_functor=runKernel;
#else
	runKernel=bindKernel(*kernel_p,*queue_p,globalRange, localRange);
#endif	
	return ncalls;
}

int OclWrapper::enqueueNDRangeOffset(const cl::NDRange& offset,const cl::NDRange& globalRange,const cl::NDRange& localRange) {
	// Create the CommandQueue
	if ((void*)queue_p==NULL) {
		queue_p = new cl::CommandQueue(*context_p, devices[deviceIdx], 0, &err);
	}
	checkErr(err, "CommandQueue::CommandQueue()");
	ncalls++;
// VERBOSE
	//std::cout << "# kernel calls: "<<ncalls <<std::endl;
#ifndef OCLV2
	runKernel=kernel_p->bind(*queue_p,offset,globalRange, localRange);
	kernel_functor=runKernel;
#else
	runKernel=bindKernel(*kernel_p,*queue_p,offset,globalRange, localRange);
#endif	
	return ncalls;
}
//cl::Buffer* OclWrapper::makeStaticWriteBuffer(int idx,int bufSize) {
//	 buf[idx]= cl::Buffer(
//	            *context_p,
//	            CL_MEM_WRITE_ONLY,
//	            bufSize,NULL,&err);
//	 checkErr(err, "Buffer::Buffer()");
//	return buf;
//}

cl::Buffer& OclWrapper::makeWriteBuffer(int bufSize) {
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            CL_MEM_WRITE_ONLY,
	            bufSize,NULL,&err);
	 checkErr(err, "Buffer::Buffer()");
	cl::Buffer& buf_r = *buf_p;
	return buf_r;
}

void OclWrapper::makeWriteBufferPos(int argpos, int bufSize) {
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            CL_MEM_WRITE_ONLY,
	            bufSize,NULL,&err);
	 checkErr(err, "Buffer::Buffer()");
    buf[argpos]=buf_p;
    cl::Buffer& buf_r=*buf_p;
    setArg(argpos,buf_r);
}

cl::Buffer& OclWrapper::makeReadBuffer(int bufSize,void* hostBuf, cl_mem_flags flags) {
    if (hostBuf!=NULL && flags==CL_MEM_READ_ONLY) {
     flags=CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR;
    }
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            flags,
	            bufSize,hostBuf,&err);
	 checkErr(err, "makeReadBuffer()");
     cl::Buffer& buf_r=*buf_p;
	return buf_r;
}

cl::Buffer& OclWrapper::makeReadWriteBuffer(int bufSize,void* hostBuf, cl_mem_flags flags) {
    if (hostBuf!=NULL && flags==CL_MEM_READ_WRITE) {
     flags=CL_MEM_READ_WRITE|CL_MEM_COPY_HOST_PTR;
    }
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            flags,
	            bufSize,hostBuf,&err);
	 checkErr(err, "makeReadBuffer()");
     cl::Buffer& buf_r=*buf_p;
	return buf_r;
}

cl::Buffer& OclWrapper::makeReadBuffer(int bufSize,const void* hostBuf, cl_mem_flags flags) {
    if (hostBuf!=NULL && flags==CL_MEM_READ_ONLY) {
     flags=CL_MEM_READ_ONLY|CL_MEM_COPY_HOST_PTR;
    }
    void* t_hostBuf = (void*)hostBuf;
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            flags,
	            bufSize,t_hostBuf,&err);
	 checkErr(err, "makeReadBuffer()");
     cl::Buffer& buf_r=*buf_p;
	return buf_r;
}

cl::Buffer& OclWrapper::makeReadWriteBuffer(int bufSize,const void* hostBuf, cl_mem_flags flags) {
    if (hostBuf!=NULL && flags==CL_MEM_READ_WRITE) {
     flags=CL_MEM_READ_WRITE|CL_MEM_COPY_HOST_PTR;
    }
    void* t_hostBuf = (void*)hostBuf;
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            flags,
	            bufSize,t_hostBuf,&err);
	 checkErr(err, "makeReadBuffer()");
     cl::Buffer& buf_r=*buf_p;
	return buf_r;
}
//cl::Buffer* OclWrapper::makeStaticReadBuffer(int idx,int bufSize,void* hostBuf, cl_mem_flags flags) {
//	 //cl::Buffer* buf_p= new cl::Buffer(
//	 buf[idx]= cl::Buffer(
//	 //buf_p1= new cl::Buffer(
//	            *context_p,
//	            flags,
//	            bufSize,hostBuf,&err);
//	 checkErr(err, "Buffer::Buffer()");
//	return buf;
//}

void OclWrapper::makeReadBufferPos(int argpos, int bufSize) {
	 cl::Buffer* buf_p= new cl::Buffer(
	            *context_p,
	            CL_MEM_READ_ONLY,
	            bufSize,NULL,&err);
	 checkErr(err, "Buffer::Buffer()");
   buf[argpos]=buf_p;
   cl::Buffer& buf_r=*buf_p;
   setArg(argpos,buf_r);

}

void OclWrapper::readBufferPos(int idx, int bufSize, void* hostBuf) {
//    std::cout << queue_p<<"\n";

	err = queue_p->enqueueReadBuffer(
	            *buf[idx],
	            CL_TRUE,
	            0,
	            bufSize,
	            hostBuf);
    checkErr(err, "CommandQueue::enqueueReadBuffer()");

}

void OclWrapper::readBuffer(const cl::Buffer& deviceBuf, int bufSize, void* hostBuf) {

	err = queue_p->enqueueReadBuffer(
	            deviceBuf,
	            CL_TRUE,
	            0,
	            bufSize,
	            hostBuf);
    checkErr(err, "CommandQueue::enqueueReadBuffer()");

}

void OclWrapper::readBuffer(const cl::Buffer& deviceBuf, bool blocking_read,
		::size_t offset, ::size_t bufSize, void * hostBuf,
		const VECTOR_CLASS<cl::Event> * events,
		cl::Event * event) {
	err = queue_p->enqueueReadBuffer(
			deviceBuf,
			blocking_read,
			offset,
			bufSize,
			hostBuf,
			events,
			event);

	checkErr(err, "CommandQueue::enqueueReadBuffer()");

}


void OclWrapper::readBuffer(const cl::Buffer& deviceBuf, int bufSize, const void* hostBuf) {

	err = queue_p->enqueueReadBuffer(
	            deviceBuf,
	            CL_TRUE,
	            0,
	            bufSize,
	            (void*)hostBuf);
    checkErr(err, "CommandQueue::enqueueReadBuffer()");

}

void OclWrapper::readBuffer(const cl::Buffer& deviceBuf, bool blocking_read,
		::size_t offset, ::size_t bufSize, const void * hostBuf,
		const VECTOR_CLASS<cl::Event> * events,
		cl::Event * event) {
	err = queue_p->enqueueReadBuffer(
			deviceBuf,
			blocking_read,
			offset,
			bufSize,
			(void*)hostBuf,
			events,
			event);

	checkErr(err, "CommandQueue::enqueueReadBuffer()");

}
/*
void OclWrapper::writeBuffer1( int bufSize, void* hostBuf) {

	err = queue_p->enqueueWriteBuffer(
	            *buf_p,
	            CL_TRUE,
	            0,
	            bufSize,
	            hostBuf);
	checkErr(err, "CommandQueue::enqueueWriteBuffer()");

}
*/
void OclWrapper::writeBuffer(const cl::Buffer& deviceBuf, int bufSize, void* hostBuf) {
//    std::cout << queue_p<<"\n";
	err = queue_p->enqueueWriteBuffer(
	            deviceBuf,
	            CL_TRUE,
	            0,
	            bufSize,
	            hostBuf);
	checkErr(err, "CommandQueue::enqueueWriteBuffer()");

}

void OclWrapper::writeBuffer(const cl::Buffer& deviceBuf, bool blocking_write,
		::size_t offset, ::size_t bufSize, void * hostBuf,
		const VECTOR_CLASS<cl::Event> * events,
		cl::Event * event) {
	err = queue_p->enqueueWriteBuffer(
			deviceBuf,
			blocking_write,
			offset,
			bufSize,
			hostBuf,
			events,
			event);

	checkErr(err, "CommandQueue::enqueueWriteBuffer()");

}
void OclWrapper::writeBuffer(const cl::Buffer& deviceBuf, int bufSize, const void* hostBuf) {
//    std::cout << queue_p<<"\n";
	err = queue_p->enqueueWriteBuffer(
	            deviceBuf,
	            CL_TRUE,
	            0,
	            bufSize,
	            (void*)hostBuf);
	checkErr(err, "CommandQueue::enqueueWriteBuffer()");

}

void OclWrapper::writeBuffer(const cl::Buffer& deviceBuf, bool blocking_write,
		::size_t offset, ::size_t bufSize, const void * hostBuf,
		const VECTOR_CLASS<cl::Event> * events,
		cl::Event * event) {
	err = queue_p->enqueueWriteBuffer(
			deviceBuf,
			blocking_write,
			offset,
			bufSize,
			(void*)hostBuf,
			events,
			event);

	checkErr(err, "CommandQueue::enqueueWriteBuffer()");

}

void OclWrapper::writeBufferPos(int argpos, int bufSize, void* hostBuf) {
    OclWrapper::writeBuffer(*buf[argpos], bufSize, hostBuf);
}

// ----------------------------------------------------------------------------------------
// Private methods
// ----------------------------------------------------------------------------------------
void OclWrapper::getContextAndDevices() {

	const cl::Platform& platform = platformList[platformIdx];
	cl_platform_id platformId = platform();
    cl_context_properties cprops[3] = { CL_CONTEXT_PLATFORM,
    		(cl_context_properties)platformId, 0 };

	if (useGPU) {
		if (hasGPU(platformIdx) ) {
#ifdef VERBOSE
			std::cerr << "\nUsing GPU\n";
#endif
			context_p = new cl::Context(CL_DEVICE_TYPE_GPU, cprops, NULL, NULL, &err); // GPU-only
			checkErr(err, "Context::Context()");
		} else  {
			checkErr(CL_FALSE, "Platform has no GPU");
		}
	} else	if (useACC) {
		if (hasACC(platformIdx) ) {
#ifdef VERBOSE
			std::cerr << "\nUsing ACC\n";
#endif
			context_p = new cl::Context(CL_DEVICE_TYPE_ACCELERATOR, cprops, NULL, NULL, &err); // CPU-only
			checkErr(err, "Context::Context()");
		} else {
			checkErr(CL_FALSE, "Platform has no ACCELERATOR");
		}
	} else	if (useCPU) {
		if (hasCPU(platformIdx) ) {
#ifdef VERBOSE
			std::cerr << "\nUsing CPU\n";
#endif
			context_p = new cl::Context(CL_DEVICE_TYPE_CPU, cprops, NULL, NULL, &err); // CPU-only
			checkErr(err, "Context::Context()");
		} else {
			checkErr(CL_FALSE, "Platform has no CPU");
		}
	} else {
			checkErr(CL_FALSE, "Platform not supported (can't find OpenCL device)");
	}

	getDevices();
}

// Unused, devices result from the getDevices call in hasGPU/hasCPU
//WV: NO! the devices in hasGPU are the *platform* devices, not the *context* devices!
void OclWrapper::getDevices() {
	devices = context_p->getInfo<CL_CONTEXT_DEVICES>();
	checkErr( devices.size() > 0 ? CL_SUCCESS : -1, "devices.size() > 0");
}

void OclWrapper::initArgStatus (void) {
    for (int i=0;i<NBUFS;i++) {
        argStatus[i]=0;
    }
}
void OclWrapper::showDeviceInfo() {
	return deviceInfo.show(devices[deviceIdx]);
}

int OclWrapper::getMaxComputeUnits() {
	return deviceInfo.max_compute_units(devices[deviceIdx]);
}

int OclWrapper::getGlobalMemCacheType() {
	cl_device_mem_cache_type ct = deviceInfo.global_mem_cache_type(devices[deviceIdx]);
	return (int)ct;
}

unsigned long int OclWrapper::getGlobalMemSize() {
	return deviceInfo.global_mem_size(devices[deviceIdx]);
}

unsigned long int OclWrapper::getLocalMemSize() {
	return deviceInfo.local_mem_size(devices[deviceIdx]);
}


// ----------------------------------------------------------------------------------------
// Functions, not part of the class
// ----------------------------------------------------------------------------------------

void checkErr(cl_int err, const char * name) {
	if (err != CL_SUCCESS) {
		std::cerr << "ERROR: " << name << " (" << err << ")" << std::endl;
		exit( EXIT_FAILURE);
	}
}


