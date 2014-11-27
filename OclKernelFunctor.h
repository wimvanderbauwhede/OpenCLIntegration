#ifndef __OCL_KERNEL_FUNCTOR_H__
#define __OCL_KERNEL_FUNCTOR_H__

#ifdef OSX
#include <cl.hpp>
#else
#ifdef OCLV2
#include <CL/cl.hpp>
#else
#include <cl.hpp>
#endif
#endif

using namespace cl;

/*! \class OclKernelFunctor
 * WV: taken from the OpenCL C++ 1.1 header
 * \brief Kernel functor interface
 *
 * \note Currently only functors of zero to fourteen arguments are supported. It
 * is straightforward to add more and a more general solution, similar to
 * Boost.Lambda could be followed if required in the future.
 */
#ifndef OCLV2
namespace cl {
#endif    
class OclKernelFunctor
{
private:
    Kernel kernel_;
    CommandQueue queue_;
    NDRange offset_;
    NDRange global_;
    NDRange local_;

    cl_int err_;
public:
    OclKernelFunctor() { }

    OclKernelFunctor(
        const Kernel& kernel,
        const CommandQueue& queue,
        const NDRange& offset,
        const NDRange& global,
        const NDRange& local) :
            kernel_(kernel),
            queue_(queue),
            offset_(offset),
            global_(global),
            local_(local),
            err_(CL_SUCCESS)
    {}

    OclKernelFunctor& operator=(const OclKernelFunctor& rhs);

    OclKernelFunctor(const OclKernelFunctor& rhs);

    cl_int getError() { return err_; }

    inline Event operator()(const VECTOR_CLASS<Event>* events = NULL);

    template<typename A1>
    inline Event operator()(
        const A1& a1, 
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3,
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3, class A4>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4,
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3, class A4, class A5>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5,
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3, class A4, class A5, class A6>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3, class A4,
             class A5, class A6, class A7>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6, 
        const A7& a7,
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6, 
        const A7& a7, 
        const A8& a8,
        const VECTOR_CLASS<Event>* events = NULL);

    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6, 
        const A7& a7, 
        const A8& a8, 
        const A9& a9,
        const VECTOR_CLASS<Event>* events = NULL);
    
    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9, class A10>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const A7& a7, 
        const A8& a8, 
        const A9& a9, 
        const A10& a10,
        const VECTOR_CLASS<Event>* events = NULL);
    
    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9, class A10,
             class A11>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const A7& a7, 
        const A8& a8, 
        const A9& a9, 
        const A10& a10, 
        const A11& a11,
        const VECTOR_CLASS<Event>* events = NULL);
    
    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9, class A10,
             class A11, class A12>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const A7& a7, 
        const A8& a8, 
        const A9& a9, 
        const A10& a10, 
        const A11& a11, 
        const A12& a12,
        const VECTOR_CLASS<Event>* events = NULL);
    
    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9, class A10,
             class A11, class A12, class A13>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const A7& a7, 
        const A8& a8, 
        const A9& a9, 
        const A10& a10, 
        const A11& a11, 
        const A12& a12, 
        const A13& a13,
        const VECTOR_CLASS<Event>* events = NULL);
    
    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9, class A10,
             class A11, class A12, class A13, class A14>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const A7& a7, 
        const A8& a8, 
        const A9& a9, 
        const A10& a10, 
        const A11& a11,
        const A12& a12, 
        const A13& a13, 
        const A14& a14,
        const VECTOR_CLASS<Event>* events = NULL);
    
    template<class A1, class A2, class A3, class A4, class A5,
             class A6, class A7, class A8, class A9, class A10,
             class A11, class A12, class A13, class A14, class A15>
    inline Event operator()(
        const A1& a1, 
        const A2& a2, 
        const A3& a3, 
        const A4& a4, 
        const A5& a5, 
        const A6& a6,
        const A7& a7, 
        const A8& a8, 
        const A9& a9, 
        const A10& a10, 
        const A11& a11,
        const A12& a12, 
        const A13& a13, 
        const A14& a14, 
        const A15& a15,
        const VECTOR_CLASS<Event>* events = NULL);
};

inline OclKernelFunctor bindKernel(
    const Kernel& kernel,	
    const CommandQueue& queue,
    const NDRange& offset,
    const NDRange& global,
    const NDRange& local)
{
    return OclKernelFunctor(kernel,queue,offset,global,local);
}

inline OclKernelFunctor bindKernel(
    const Kernel& kernel,	
    const CommandQueue& queue,
    const NDRange& global,
    const NDRange& local)
{
    return OclKernelFunctor(kernel,queue,NullRange,global,local);
}

inline OclKernelFunctor& OclKernelFunctor::operator=(const OclKernelFunctor& rhs)
{
    if (this == &rhs) {
        return *this;
    }
    
    kernel_ = rhs.kernel_;
    queue_  = rhs.queue_;
    offset_ = rhs.offset_;
    global_ = rhs.global_;
    local_  = rhs.local_;
    
    return *this;
}

inline OclKernelFunctor::OclKernelFunctor(const OclKernelFunctor& rhs) :
    kernel_(rhs.kernel_),
    queue_(rhs.queue_),
    offset_(rhs.offset_),
    global_(rhs.global_),
    local_(rhs.local_)
{
}

Event OclKernelFunctor::operator()(const VECTOR_CLASS<Event>* events)
{
    Event event;

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4, typename A5>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4, typename A5,
         typename A6>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4,
         typename A5, typename A6, typename A7>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6, 
    const A7& a7,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4, typename A5,
         typename A6, typename A7, typename A8>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6, 
    const A7& a7, 
    const A8& a8,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4, typename A5,
         typename A6, typename A7, typename A8, typename A9>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5,
    const A6& a6, 
    const A7& a7, 
    const A8& a8, 
    const A9& a9,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<typename A1, typename A2, typename A3, typename A4, typename A5,
         typename A6, typename A7, typename A8, typename A9, typename A10>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6,
    const A7& a7, 
    const A8& a8, 
    const A9& a9, 
    const A10& a10,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);
    kernel_.setArg(9,a10);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<class A1, class A2, class A3, class A4, class A5,
         class A6, class A7, class A8, class A9, class A10,
         class A11>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6,
    const A7& a7, 
    const A8& a8, 
    const A9& a9, 
    const A10& a10, 
    const A11& a11,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);
    kernel_.setArg(9,a10);
    kernel_.setArg(10,a11);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<class A1, class A2, class A3, class A4, class A5,
         class A6, class A7, class A8, class A9, class A10,
         class A11, class A12>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6,
    const A7& a7, 
    const A8& a8, 
    const A9& a9, 
    const A10& a10, 
    const A11& a11, 
    const A12& a12,
    const VECTOR_CLASS<Event>* events)
{
    Event event;

    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);
    kernel_.setArg(9,a10);
    kernel_.setArg(10,a11);
    kernel_.setArg(11,a12);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<class A1, class A2, class A3, class A4, class A5,
         class A6, class A7, class A8, class A9, class A10,
         class A11, class A12, class A13>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6,
    const A7& a7, 
    const A8& a8, 
    const A9& a9, 
    const A10& a10, 
    const A11& a11, 
    const A12& a12, 
    const A13& a13,
    const VECTOR_CLASS<Event>* events)
{
    Event event;
    
    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);
    kernel_.setArg(9,a10);
    kernel_.setArg(10,a11);
    kernel_.setArg(11,a12);
    kernel_.setArg(12,a13);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<class A1, class A2, class A3, class A4, class A5,
         class A6, class A7, class A8, class A9, class A10,
         class A11, class A12, class A13, class A14>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5, 
    const A6& a6,
    const A7& a7, 
    const A8& a8, 
    const A9& a9, 
    const A10& a10, 
    const A11& a11,
    const A12& a12, 
    const A13& a13, 
    const A14& a14,
    const VECTOR_CLASS<Event>* events)
{
    Event event;
    
    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);
    kernel_.setArg(9,a10);
    kernel_.setArg(10,a11);
    kernel_.setArg(11,a12);
    kernel_.setArg(12,a13);
    kernel_.setArg(13,a14);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}

template<class A1, class A2, class A3, class A4, class A5,
         class A6, class A7, class A8, class A9, class A10,
         class A11, class A12, class A13, class A14, class A15>
Event OclKernelFunctor::operator()(
    const A1& a1, 
    const A2& a2, 
    const A3& a3, 
    const A4& a4, 
    const A5& a5,
    const A6& a6, 
    const A7& a7, 
    const A8& a8, 
    const A9& a9, 
    const A10& a10, 
    const A11& a11,
    const A12& a12, 
    const A13& a13, 
    const A14& a14, 
    const A15& a15,
    const VECTOR_CLASS<Event>* events)
{
    Event event;
    
    kernel_.setArg(0,a1);
    kernel_.setArg(1,a2);
    kernel_.setArg(2,a3);
    kernel_.setArg(3,a4);
    kernel_.setArg(4,a5);
    kernel_.setArg(5,a6);
    kernel_.setArg(6,a7);
    kernel_.setArg(7,a8);
    kernel_.setArg(8,a9);
    kernel_.setArg(9,a10);
    kernel_.setArg(10,a11);
    kernel_.setArg(11,a12);
    kernel_.setArg(12,a13);
    kernel_.setArg(13,a14);
    kernel_.setArg(14,a15);

    err_ = queue_.enqueueNDRangeKernel(
        kernel_,
        offset_,
        global_,
        local_,
        NULL,    // bgaster_fixme - do we want to allow wait event lists?
        &event);

    return event;
}
#ifndef OCLV2
}
#endif  
#endif // __OCL_KERNEL_FUNCTOR_H__


