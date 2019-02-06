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

extern "C" {
#include "OclWrapperC.h"
}
#endif // _OCL_WRAPPER_F_H_
