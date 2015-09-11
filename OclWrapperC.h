/*
   This is a function-based OclWrapper API intended for use in FORTRAN programs

   The approach is to cast the pointer to the OclWrapper object to a 64-bit integer and return it.
   This word gets passed around in the FORTRAN code (as INTEGER*8).
   Every call to the API takes this word as its first argument, casts it back to the object and so on.

   So we create some low-level casting functions first
*/
#ifndef _OCL_WRAPPER_C_H_
#define _OCL_WRAPPER_C_H_
typedef int64_t* OclBufferF;
typedef int64_t* OclWrapperF;
//extern "C" {

// The minimal API is as follows:
void oclinitc_(OclWrapperF ocl,const char* source,const char* kernel);
void oclinitoptsc_(OclWrapperF ocl,const char* source,const char* kernel,const char* kernel_opts);
void oclinitf_(OclWrapperF ocl,const char* source,int* srclen, const char* kernel, int* klen);
void oclinitdevf_(OclWrapperF ocl,const char* source,int* srclen, const char* kernel, int* klen, int* devIdx);
void oclinitoptsf_(OclWrapperF ocl,const char* source,int* srclen,const char* kernel,int* klen,const char* kernel_opts, int* koptslen);
void oclinitoptsdevf_(OclWrapperF ocl,const char* source,int* srclen,const char* kernel,int* klen,const char* kernel_opts, int* koptslen, int* devIdx);

void oclgetmaxcomputeunitsc_(OclWrapperF ocl,int* nunits);
void oclgetnthreadshintc_(OclWrapperF ocl,int* nthreads);

void oclmakereadbufferptrc_(OclWrapperF ocl,OclBufferF buffer, int* size, void* ptr);
void oclmakereadwritebufferptrc_(OclWrapperF ocl,OclBufferF buffer, int* size,void* ptr);
void oclmakereadbufferc_(OclWrapperF ocl,OclBufferF buffer, int* size);
void oclmakereadwritebufferc_(OclWrapperF ocl,OclBufferF buffer, int* size);
void oclmakewritebufferc_(OclWrapperF ocl,OclBufferF buffer, int* size);

void oclwritebufferc_(OclWrapperF ocl,OclBufferF buffer, int* size,void* array);
void oclreadbufferc_(OclWrapperF ocl,OclBufferF buffer,int* size,void* data);
void oclenqueuendrangec_(OclWrapperF ocl,int* global , int* local);
// We can't use the functor inside this because we can't create it at compile time
// so we need setArgs.
void oclsetarrayargc_(OclWrapperF ocl,int* pos, OclBufferF buf);
void oclsetfloatarrayargc_(OclWrapperF ocl,int* pos, OclBufferF buf);
void oclsetfloatconstargc_(OclWrapperF ocl,int* pos, float* constarg);
void oclsetintconstargc_(OclWrapperF ocl,int* pos, int* constarg);
// args is an array of uint64_t; the arguments can be buffers or constants, so I need a bitmask argtypes, another int64_t
// this assumes we have no more than 64 arguments ...
void oclrunc_(OclWrapperF ocl,int* nargs,int64_t argtypes, int64_t* args);
void runoclc_(OclWrapperF ocl,int* global , int* local, float* exectime);
void runoclc2d_(OclWrapperF ocl,int* global , int* local, float* exectime);
void runoclc3d_(OclWrapperF ocl,int* global , int* local, float* exectime);
#ifdef OCL_MULTIPLE_DEVICES
void oclsetinstancec_(int64_t* ivp_oclinstmap, int64_t* ivp_oclinstid );
void oclgetinstancec_(int64_t* ivp_oclinstmap, int64_t* ivp_oclinstid );
#endif
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
*/

//}
#endif // _OCL_WRAPPER_C_H_
