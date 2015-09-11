#include "OclWrapperF.h"

//void* unpack(OclWrapper* ocl) {
//	void* pt = reinterpret_cast<void*>(ocl);
//	return pt;
//}
//
//OclWrapper* pack(void* res) {
//	OclWrapper* ocl=(OclWrapper*)res;
//	return ocl;
//}

//int64_t toWord(OclWrapper* ocl) {
//	void* vp=unpack(ocl);
//	int64_t ivp =(int64_t)vp;
//	return ivp;
//}
//
//OclWrapper* fromWord(int64_t ivp) {
//	void* vp=(void*)ivp;
//	OclWrapper* ocl=pack(vp);
//	return ocl;
//}


extern "C" {
int isbrol (int c) {
       return !std::isalnum(c) && !(c==46) && !(c==95) ; // remove anything not alphanum, . or _
}

int isbrolcpp (int c) {
       return !std::isalnum(c) && !(c==46) && !(c==95) && !(c==44) && !(c==45) ; // remove anything not alphanum, . or _ or , or -
}

void oclinitf_(OclWrapperF ocl_ivp,const char* source, int* srclen, const char* kernel, int* klen) {
//	std::cout <<"init\n";
// 	bool use_gpu=true;
//#ifdef CPU
//	use_gpu=false;
//#endif
//	std::cout <<"oclinitf_: kernel=<"<<kernel<<"> len = "<<*klen <<"\n";
	std::string kstr(kernel);
	kstr = kstr.substr(0,*klen);
//	std::cout <<"oclinitf_: kstr=<"<<kstr<<">\n";
	kernel=kstr.c_str();
//	std::cout <<"oclinitf_: source=<"<<source<<"> len = " << *srclen <<"\n";
	std::string sstr(source);
	sstr = sstr.substr(0,*srclen);
//	std::cout <<"oclinitf_: sstr=<"<<sstr<<">\n";
	source=sstr.c_str();
    //std::cout << source<<", "<<kernel<<", <"<<KERNEL_OPTS<<">\n";
	OclWrapper* ocl = new OclWrapper(source,kernel,KERNEL_OPTS);
//	std::cout <<"cast\n";
	*ocl_ivp=toWord<OclWrapper*>(ocl);
//	std::cout <<ocl_ivp<<"\n";
//	std::cout <<(*ocl_ivp)<<"\n";
}


void oclinitdevf_(OclWrapperF ocl_ivp,const char* source, int* srclen, const char* kernel, int* klen, int* devIdx) {
	std::string kstr(kernel);
	kstr = kstr.substr(0,*klen);
	kernel=kstr.c_str();
	std::string sstr(source);
	sstr = sstr.substr(0,*srclen);
	source=sstr.c_str();
    std::cout << "FORTRAN_KERNEL_OPTS: "<< KERNEL_OPTS  <<"\n";
	OclWrapper* ocl = new OclWrapper(source,kernel,KERNEL_OPTS,*devIdx);
	*ocl_ivp=toWord<OclWrapper*>(ocl);
}

void oclinitoptsf_(OclWrapperF ocl_ivp,const char* source,int* srclen,const char* kernel,int* klen,const char* kernel_opts, int* koptslen) {
	std::string kstr(kernel);
	kstr = kstr.substr(0,*klen);
	kernel=kstr.c_str();
	std::string sstr(source);
	sstr = sstr.substr(0,*srclen);
	source=sstr.c_str();
	std::string kopts_str(kernel_opts);
    kopts_str =  kopts_str.substr(0,*koptslen);
    std::string kopts_from_builder(KERNEL_OPTS);
    kernel_opts = (kopts_str+" "+kopts_from_builder).c_str();
    //kernel_opts = kopts_str.c_str();
    std::cout << "FORTRAN_KERNEL_OPTS: "<<kopts_str<<"\n";
    std::cout << "FORTRAN_KERNEL_OPTS: "<<kopts_from_builder<<"\n";
	OclWrapper* ocl = new OclWrapper(source,kernel,kernel_opts);
	*ocl_ivp=toWord<OclWrapper*>(ocl);
}

void oclinitoptsdevf_(OclWrapperF ocl_ivp,const char* source,int* srclen,const char* kernel,int* klen,const char* kernel_opts, int* koptslen, int* devIdx) {
	std::string kstr(kernel);
	kstr = kstr.substr(0,*klen);
	kernel=kstr.c_str();
	std::string sstr(source);
	sstr = sstr.substr(0,*srclen);
	source=sstr.c_str();
	std::string kopts_str(kernel_opts);
    kopts_str =  kopts_str.substr(0,*koptslen);
    std::string kopts_from_builder(KERNEL_OPTS);
    kernel_opts = (kopts_str+" "+kopts_from_builder).c_str();
    //kernel_opts = kopts_str.c_str();
    std::cout << "FORTRAN_KERNEL_OPTS: "<<kopts_str<<"\n";
    std::cout << "FORTRAN_KERNEL_OPTS: "<<kopts_from_builder<<"\n";
	OclWrapper* ocl = new OclWrapper(source,kernel,kernel_opts,*devIdx);
	*ocl_ivp=toWord<OclWrapper*>(ocl);
}

void oclinitc_(OclWrapperF ocl_ivp,const char* source,const char* kernel) {
//	std::cout <<"init\n";
// 	bool use_gpu=true;
//#ifdef CPU
//	use_gpu=false;
//#endif
//	std::cout <<"oclinitc_: kernel=<"<<kernel<<">\n";
	std::string kstr(kernel);
	kstr.erase(std::remove_if(kstr.begin(), kstr.end(), isbrol), kstr.end());
	std::cout <<"oclinitc_: kstr=<"<<kstr<<">\n";
	kernel=kstr.c_str();
//	std::cout <<"oclinitc_: source=<"<<source<<">\n";
	std::string sstr(source);
	sstr.erase(std::remove_if(sstr.begin(), sstr.end(), isbrol), sstr.end());
//	std::cout <<"oclinitc_: sstr=<"<<sstr<<">\n";
//	sstr="matacc.cl"; FIXME!
	source=sstr.c_str();

	OclWrapper* ocl = new OclWrapper(source,kernel,KERNEL_OPTS);
//	std::cout <<"cast\n";
	*ocl_ivp=toWord<OclWrapper*>(ocl);
//	std::cout <<ocl_ivp<<"\n";
//	std::cout <<(*ocl_ivp)<<"\n";
}

void oclinitoptsc_(OclWrapperF ocl_ivp,const char* source,const char* kernel,const char* kernel_opts) {
	std::string kstr(kernel);
	kstr.erase(std::remove_if(kstr.begin(), kstr.end(), isbrol), kstr.end());
	std::cout <<"oclinitc_: kstr=<"<<kstr<<">\n";
	kernel=kstr.c_str();
	std::string sstr(source);
	sstr.erase(std::remove_if(sstr.begin(), sstr.end(), isbrol), sstr.end());
	source=sstr.c_str();

	std::string kopts_str(kernel_opts);
	kopts_str.erase(std::remove_if(kopts_str.begin(), kopts_str.end(), isbrolcpp), kopts_str.end());
	kernel_opts=kopts_str.c_str();
	OclWrapper* ocl = new OclWrapper(source,kernel,kernel_opts);
	*ocl_ivp=toWord<OclWrapper*>(ocl);    
}

void oclgetmaxcomputeunitsc_(OclWrapperF ocl_ivp,int* nunits) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	*nunits = ocl->getMaxComputeUnits();
}

void oclgetnthreadshintc_(OclWrapperF ocl_ivp,int* nthreads) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	*nthreads = ocl->getNThreadsHint();
}

/*
void floatarraytoocl_(OclWrapperF ocl_ivp,int* argpos,int* sz,float* array) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);

	if (ocl->argStatus[*argpos]==0) {
		ocl->argStatus[*argpos]=1;
		// create the buffer; this method stores the buffer in OclWrapper::buf
		ocl->makeReadBufferPos(*argpos,*sz);
	}
	// write the array to the buffer; the buffer is accessed via argpos
	ocl->writeBufferPos(*argpos,*sz,(void*)array);
}

void floatconsttoocl_(OclWrapperF ocl_ivp,int* argpos,float* constarg) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	ocl->setArg(*argpos,*constarg);
}
// and similar for int, long and double
void floatarrayfromoclalloc_(OclWrapperF ocl_ivp,int* argpos,int* sz) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	if (ocl->argStatus[*argpos]==0) {
		ocl->argStatus[*argpos]=1;
		// create the buffer; this method stores the buffer in OclWrapper::buf
		ocl->makeWriteBufferPos(argpos,sz);
	}
}
void floatarraytooclalloc_(OclWrapperF ocl_ivp,int* argpos,int* sz) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	if (ocl->argStatus[*argpos]==0) {
		ocl->argStatus[*argpos]=1;
		// create the buffer; this method stores the buffer in OclWrapper::buf
		ocl->makeReadBufferPos(*argpos,*sz);
	}
}
void floatarrayfromocl_(OclWrapperF ocl_ivp,int* argpos,int* sz, float* array) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	// read the array from the buffer; the buffer is accessed via argpos
	ocl->readBufferPos(*argpos,*sz,(void*)array);

}
*/
//void oclenqueuendrange_(OclWrapperF ocl_ivp,int global , int local) {
//	OclWrapper* ocl = fromWord(ocl_ivp);
//};

void oclsetarrayargc_(OclWrapperF ocl_ivpa,int* pos, OclBufferF buf_ivpa) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivpa);
	cl::Buffer* buffer = fromWord<cl::Buffer*>(*buf_ivpa);
	ocl->setArg(*pos, *buffer);
};

void oclsetfloatarrayargc_(OclWrapperF ocl_ivpa,int* pos, OclBufferF buf_ivpa) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivpa);
	cl::Buffer* buffer = fromWord<cl::Buffer*>(*buf_ivpa);
	ocl->setArg(*pos, *buffer);
};
void oclsetfloatconstargc_(OclWrapperF ocl_ivpa,int* pos,  float* constarg) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivpa);
	ocl->setArg(*pos, *constarg);
};
void oclsetintconstargc_(OclWrapperF ocl_ivpa,int* pos,  int* constarg) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivpa);
	ocl->setArg(*pos, *constarg);
};
// This works only for a 1-D range. For a 2-D or 3-D range, we can pass arrays
// but how do we know their size? We can use a 4-elt array, the 1st elt is the size
void runoclc_(OclWrapperF ocl_ivp,int* global , int* local, float* ext_time) {
	//std::cout <<"unwrap pointer "<<ocl_ivp<<"\n";
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	//std::cout <<"create ranges "<<(*global)<<","<<(*local)<<"\n";
    if (*local!=0) {
    	*ext_time = ocl->enqueueNDRangeRun(*global,*local);
    } else {
    	*ext_time = ocl->enqueueNDRangeRun(*global);
    }
	//std::cout <<"ocl->enqueueNDRangeRun done!\n";
    /*
	cl::NDRange* globalrange=new cl::NDRange(*global);
	cl::NDRange* localrange;
    if (*local!=0) {
	    localrange=new cl::NDRange(*local);
	    ocl->enqueueNDRangeRun(globalrange,localrange);
        delete localrange;
    } else {
    	ocl->enqueueNDRangeRun(globalrange);
    }
	//std::cout <<"ocl->enqueueNDRangeRun\n";
    delete globalrange;
    */
};

void runoclc3d_(OclWrapperF ocl_ivp,int* global , int* local, float* ext_time) {
	//std::cout <<"unwrap pointer "<<ocl_ivp<<"\n";
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	//std::cout <<"create ranges "<<(*global)<<","<<(*local)<<"\n";
    if (local[0]!=0) {
    	cl::NDRange global_range(global[0],global[1],global[2]);
    	cl::NDRange local_range(local[0],local[1],local[2]);
    	*ext_time = ocl->enqueueNDRangeRun(global_range,local_range);
    } else {
    	cl::NDRange global_range(global[0],global[1],global[2]);
    	*ext_time = ocl->enqueueNDRangeRun(global_range);
    }
};

void runoclc2d_(OclWrapperF ocl_ivp,int* global , int* local, float* ext_time) {
	//std::cout <<"unwrap pointer "<<ocl_ivp<<"\n";
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	//std::cout <<"create ranges "<<(*global)<<","<<(*local)<<"\n";
    if (local[0]!=0) {
    	cl::NDRange global_range(global[0],global[1]);
    	cl::NDRange local_range(local[0],local[1]);
    	*ext_time = ocl->enqueueNDRangeRun(global_range,local_range);
    } else {
    	cl::NDRange global_range(global[0],global[1]);
    	*ext_time = ocl->enqueueNDRangeRun(global_range);
    }
};

/*
 //    oclmakereadbuffer_(&ocl_ivp,&mA_buf_ivp,sizeof(cl_float) * mSize);

	OclWrapper* ocl_p = fromWord(ocl_ivp);
	int err;
	 cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl_p->context_p),
	            CL_MEM_READ_ONLY,
	            sizeof(cl_float) * mSize,NULL,&err);
	 checkErr(err, "makeReadBuffer()");
	void* buf_vp=static_cast<void*>(buf_p);
	int64_t* mA_buf_ip=(int64_t*)buf_vp;

 * */

void oclwritebufferc_(OclWrapperF ocl_ivp,OclBufferF buf_ivpa, int* sz,void* array) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
//	int64_t buf_ivp=*buf_ivpa;
//	int64_t* buf_ip=(int64_t*)buf_ivp;
//	void* buf_vp=(void*)buf_ivp;
//	cl::Buffer* buffer = (cl::Buffer*)buf_vp;
	cl::Buffer* buffer = fromWord<cl::Buffer*>(*buf_ivpa);
//	ocl->writeBuffer(*buffer,*sz,array);

	ocl->queue_p->enqueueWriteBuffer(
			*buffer,
			CL_TRUE,
			0,
			(::size_t)*sz,
			array);
	/*
	clEnqueueWriteBuffer ( *(ocl->queue_p->object_), // can't do this: object_ is protected
	*buffer,
	CL_TRUE,
	0,
	*sz,
	array,
	0,
	NULL,
	NULL);
*/

}

void oclreadbufferc_(OclWrapperF ocl_ivp,OclBufferF buf_ivpa, int* sz,void* array) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);

//	int64_t buf_ivp=*buf_ivpa;
//	int64_t* buf_ip=(int64_t*)buf_ivp;
//	void* buf_vp=(void*)buf_ivp;
//	cl::Buffer* buffer = (cl::Buffer*)buf_vp;
	cl::Buffer* buffer = fromWord<cl::Buffer*>(*buf_ivpa);
//	ocl->readBuffer(*buffer,*sz,array);


	ocl->queue_p->enqueueReadBuffer(
			*buffer,
			CL_TRUE,
			0,
			(::size_t)*sz,
			array);
}

void oclmakereadbufferc_(OclWrapperF ocl_ivp,OclBufferF buf_ivp, int* sz) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	int err;
	cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl->context_p),
	            CL_MEM_READ_ONLY ,
	            (::size_t)*sz,NULL,&err);
	checkErr(err, "makeReadBuffer()");
//	void* buf_vp=reinterpret_cast<void*>(buf_p);
//	int64_t* buf_ip=(int64_t*)buf_vp;
//	*buf_ivp=(int64_t)buf_ip;
	*buf_ivp=toWord<cl::Buffer*>(buf_p);
}

void oclmakereadbufferptrc_(OclWrapperF ocl_ivp,OclBufferF buf_ivp, int* sz,void* ptr) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	int err;
	cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl->context_p),
	            CL_MEM_READ_ONLY | CL_MEM_READ_MODE,
	            (::size_t)*sz,ptr,&err);
	checkErr(err, "makeReadBuffer()");
//	void* buf_vp=reinterpret_cast<void*>(buf_p);
//	int64_t* buf_ip=(int64_t*)buf_vp;
//	*buf_ivp=(int64_t)buf_ip;
	*buf_ivp=toWord<cl::Buffer*>(buf_p);
}

void oclmakereadwritebufferc_(OclWrapperF ocl_ivp,OclBufferF buf_ivp, int* sz) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	int err;
	cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl->context_p),
	            CL_MEM_READ_WRITE ,
	            (::size_t)*sz,NULL,&err);
	checkErr(err, "makeReadWriteBuffer()");
//	void* buf_vp=reinterpret_cast<void*>(buf_p);
//	int64_t* buf_ip=(int64_t*)buf_vp;
//	*buf_ivp=(int64_t)buf_ip;
	*buf_ivp=toWord<cl::Buffer*>(buf_p);
}

void oclmakereadwritebufferptrc_(OclWrapperF ocl_ivp,OclBufferF buf_ivp, int* sz, void* ptr) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	int err;
	cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl->context_p),
	            CL_MEM_READ_WRITE | CL_MEM_READ_MODE,
	            (::size_t)*sz,ptr,&err);
	checkErr(err, "makeReadWriteBuffer()");
//	void* buf_vp=reinterpret_cast<void*>(buf_p);
//	int64_t* buf_ip=(int64_t*)buf_vp;
//	*buf_ivp=(int64_t)buf_ip;
	*buf_ivp=toWord<cl::Buffer*>(buf_p);
}

void oclmakewritebufferc_(OclWrapperF ocl_ivp,OclBufferF buf_ivp, int* sz) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	int err;
	cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl->context_p),
	            CL_MEM_WRITE_ONLY,
	            (::size_t)*sz,NULL,&err);
	checkErr(err, "makeReadBuffer()");
//	void* buf_vp=reinterpret_cast<void*>(buf_p);
//	int64_t* buf_ip=(int64_t*)buf_vp;
//	*buf_ivp=(int64_t)buf_ip;
	*buf_ivp=toWord<cl::Buffer*>(buf_p);
}
#ifdef OCL_MULTIPLE_DEVICES
void oclgetinstancec_(int64_t* ivp_oclinstmap, int64_t* oclinstid) {
	std::unordered_map<int64_t,int64_t>* oclinstmap_ptr;
//	std::cout << "OCLINSTID TO GET: "<< *oclinstid << "\n";
//	std::cout << "OCLINSTMAP (GET): "<< *ivp_oclinstmap << "\n";
	// Defensive, in principle oclsetinstancec_ should have been called first but who knows
	if(*ivp_oclinstmap == 0) { // Fortran sets the variable to 0 initially, so we can use this as a check
		oclinstmap_ptr = new std::unordered_map<int64_t,int64_t>;
//		std::cout << "NEW OCLINSTMAP (GET): "<< oclinstmap_ptr << "\n";
		void* vp = (void*)oclinstmap_ptr;
		int64_t iv =(int64_t)vp;
		*ivp_oclinstmap = iv;

	} else {

	int64_t ivp = *ivp_oclinstmap;
	void* vp=(void*)ivp;
	oclinstmap_ptr = (std::unordered_map<int64_t,int64_t>*)vp;
	}
	int64_t tid = (int64_t)pthread_self();
	*oclinstid = oclinstmap_ptr->at(tid);

}

void oclsetinstancec_(int64_t* ivp_oclinstmap, int64_t* oclinstid) {
	std::unordered_map<int64_t,int64_t>* oclinstmap_ptr;
//	std::cout << "OCLINSTID TO SET: "<< *oclinstid << "\n";
//	std::cout << "OCLINSTMAP (SET): "<< *ivp_oclinstmap << "\n";
	if(*ivp_oclinstmap == 0) { // Fortran sets the variable to 0 initially, so we can use this as a check

		oclinstmap_ptr = new std::unordered_map<int64_t,int64_t>;
//		std::cout << "NEW OCLINSTMAP (SET): "<< oclinstmap_ptr << "\n";
		void* vp = (void*)oclinstmap_ptr;
		int64_t iv =(int64_t)vp;
		*ivp_oclinstmap = iv;
	} else {

		int64_t ivp = *ivp_oclinstmap;
		void* vp=(void*)ivp;
		oclinstmap_ptr = (std::unordered_map<int64_t,int64_t>*)vp;
	}
	int64_t tid = (int64_t)pthread_self();
	oclinstmap_ptr->insert(  std::pair<int64_t,int64_t>(tid,*oclinstid) );


}
#endif
} // extern "C"
