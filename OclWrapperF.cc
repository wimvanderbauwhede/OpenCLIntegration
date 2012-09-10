
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
	return !std::isalnum(c) && !(c==46) && !(c==95); // remove anything not alphanum, . or _
}

void oclinitc_(OclWrapperF ocl_ivp,const char* source,const char* kernel) {
//	std::cout <<"init\n";
// 	bool use_gpu=true;
//#ifdef CPU
//	use_gpu=false;
//#endif
//	std::cout <<"<"<<kernel<<">\n";
	std::string kstr(kernel);
	kstr.erase(std::remove_if(kstr.begin(), kstr.end(), isbrol), kstr.end());
//	std::cout <<"<"<<kstr<<">\n";
	kernel=kstr.c_str();
//	std::cout <<"<"<<source<<">\n";
	std::string sstr(source);
	sstr.erase(std::remove_if(sstr.begin(), sstr.end(), isbrol), sstr.end());
//	std::cout <<"<"<<sstr<<">\n";
//	sstr="matacc.cl"; FIXME!
	source=sstr.c_str();

	OclWrapper* ocl = new OclWrapper(source,kernel,KERNEL_OPTS);
//	std::cout <<"cast\n";
	*ocl_ivp=toWord<OclWrapper*>(ocl);
//	std::cout <<ocl_ivp<<"\n";
//	std::cout <<(*ocl_ivp)<<"\n";
}

void oclgetmaxcomputeunitsc_(OclWrapperF ocl_ivp,int* nunits) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	*nunits = ocl->getMaxComputeUnits();
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
void runoclc_(OclWrapperF ocl_ivp,int* global , int* local) {
//	std::cout <<"unwrap\n";
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
//	std::cout <<"create ranges "<<(*global)<<","<<(*local)<<"\n";
	cl::NDRange* globalrange=new cl::NDRange(*global);
	cl::NDRange* localrange;
    if (*local!=0) {
	    localrange=new cl::NDRange(*local);
	    ocl->enqueueNDRangeRun(*globalrange,*localrange);
    } else {
//    	std::cout <<"NullRange\n";
    	ocl->enqueueNDRangeRun(*globalrange);
    }
//	std::cout <<"ocl->enqueueNDRangeRun\n";

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
			*sz,
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
			*sz,
			array);
}

void oclmakereadbufferc_(OclWrapperF ocl_ivp,OclBufferF buf_ivp, int* sz) {
	OclWrapper* ocl = fromWord<OclWrapper*>(*ocl_ivp);
	int err;
	cl::Buffer* buf_p= new cl::Buffer(
	            *(ocl->context_p),
	            CL_MEM_READ_ONLY ,
	            *sz,NULL,&err);
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
	            *sz,ptr,&err);
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
	            *sz,NULL,&err);
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
	            *sz,ptr,&err);
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
	            *sz,NULL,&err);
	checkErr(err, "makeReadBuffer()");
//	void* buf_vp=reinterpret_cast<void*>(buf_p);
//	int64_t* buf_ip=(int64_t*)buf_vp;
//	*buf_ivp=(int64_t)buf_ip;
	*buf_ivp=toWord<cl::Buffer*>(buf_p);
}


} // extern "C"
