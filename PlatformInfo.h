#ifndef __PLATFORM_INFO_H__
#define __PLATFORM_INFO_H__
#include <map>
#include <string>
#include <iostream>
#ifdef OSX
#include "cl.hpp"
#else
//#include "CL/cl.hpp"
#ifdef OCLV2
#include <vector>
#include <CL/cl.hpp>
#else
#define __NO_STD_VECTOR
#ifndef FPGA
#include <cl.hpp>
#else
// For Altera
#include <CL/cl.hpp>
#include <OclKernelFunctor.h>
#endif // FPGA
#endif
#endif

class PlatformInfo {
    private:
        std::map<std::string,int> infotbl;
        std::map<std::string,unsigned int> uint_props;
        std::map<std::string,unsigned long> ulong_props;
        std::map<std::string,std::string> string_props;
//        const cl::vector<cl::Platform>& platformList;
    public:
#ifdef OCLV2
        void show(const std::vector< cl::Platform >& pl_, int platformIdx);
#else
        void show(const cl::vector< cl::Platform >& pl_, int platformIdx);
#endif
        void show(const cl::Platform& platform);

        PlatformInfo() ;

};


#endif //  __PLATFORM_INFO_H__
