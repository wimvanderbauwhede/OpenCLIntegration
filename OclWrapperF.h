/*
   This is a function-based OclWrapper API intended for use in FORTRAN programs

   The approach is to cast the pointer to the OclWrapper object to a 64-bit integer and return it.
   This word gets passed around in the FORTRAN code (as INTEGER*8).
   Every call to the API takes this word as its first argument, casts it back to the object and so on.

   So we create some low-level casting functions first
*/
#ifndef _OCL_WRAPPER_F_H_
#define _OCL_WRAPPER_F_H_

#include <iostream>
#include <string>
#include <cctype>
#include <algorithm>
#ifdef OCL_MULTIPLE_DEVICES
#include <unordered_map>
#include <pthread.h>
#endif
#include "OclWrapper.h"

typedef int64_t* OclBufferF;
typedef int64_t* OclWrapperF;

template<typename TPtr> TPtr fromWord(int64_t ivp) {
//	int64_t ivp=*ivpa;
	int64_t* ip=(int64_t*)ivp;
	void* vp=(void*)ip;
	TPtr tp = (TPtr)vp;
	return tp;
}

template<typename TPtr> int64_t toWord(TPtr tp) {
	void* vp = reinterpret_cast<void*>(tp);
	int64_t ivp = (int64_t)vp;
	return ivp;
}

//int64_t toWord(OclWrapper*); // suppose I pass by ref, then do I need &? // was inline
//OclWrapper* fromWord(int64_t);// was inline
//inline   OclWrapper* pack(void*);
//inline   void* unpack(OclWrapper*);

extern "C" {
#include "OclWrapperC.h"
/*
// The minimal API is as follows:
void oclinitc_(OclWrapperF ocl,const char* source,const char* kernel);
void oclgetmaxcomputeunits_(OclWrapperF ocl,int* nunits);

void oclmakereadbuffer_(OclWrapperF ocl,OclBufferF buffer, int* size);
void oclmakewritebuffer_(OclWrapperF ocl,OclBufferF buffer, int* size);

// Of course in FORTRAN I think we can't have void*, so we'll need a different function for each type?
void oclwritebuffer_(OclWrapperF ocl,OclBufferF buffer, int* size,void* array);
//void oclwritebuffer_(OclWrapperF ocl,OclBufferF buffer,int size,void* data);
void oclreadbuffer_(OclWrapperF ocl,OclBufferF buffer,int* size,void* data);
void oclenqueuendrange_(OclWrapperF ocl,int* global , int* local);
// We can't use the functor inside this because we can't create it at compile time
// so we need setArgs.
void oclsetfloatarrayarg_(OclWrapperF ocl,int* pos, OclBufferF buf);
void oclsetfloatconstarg_(OclWrapperF ocl,int* pos, float* constarg);
void oclsetintconstarg_(OclWrapperF ocl,int* pos, int* constarg);
// args is an array of uint64_t; the arguments can be buffers or constants, so I need a bitmask argtypes, another int64_t
// this assumes we have no more than 64 arguments ...
void oclrun_(OclWrapperF ocl,int* nargs,int64_t argtypes, int64_t* args);
*/
// I want it a lot simpler:

/*
   What we do is , we check for every argument what its status is
   If it is 0, we create a buffer, if it's 1 we can use the buffer
   So we keep an array of ints in the OclWrapper object for this purpose
   I make it a static array of 256 elts
 */
/*
void floatarraytoocl_(OclWrapperF ocl,int argpos,int sz,float* array);
void floatconsttoocl_(OclWrapperF ocl,int argpos,float constarg);
// and similar for int, long and double
void floatarraytooclalloc_(OclWrapperF ocl,int argpos,int sz);
void floatarrayfromoclalloc_(OclWrapperF ocl,int argpos,int sz);
void floatarrayfromocl_(OclWrapperF ocl,int argpos, int sz, float* array);
void runocl_(OclWrapperF ocl,int global , int local);
*/

}
#endif // _OCL_WRAPPER_F_H_
