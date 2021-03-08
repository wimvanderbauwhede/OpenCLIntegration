# Example OpenCL code with and without OclWrapper

This folder contains example code with and without `OclWrapper`. All examples use the same OpenCl source, `matacc.cl`. The kernels in this source compute the sum of all values in a matrix in different ways. 

## Building the examples

Every example can be built by `cd`-ing into the directory and running `scons`. The build script takes many options that let you configure the build in terms of the size of the matrix, the kernel to use, the device to run the kernel on, etc. Run `scons -h` for a list of all options.

## Description of the examples

Tje 

### 1-OpenCL-v1.2-C++

C++ host code with the OpenCL v1.2 C++ API, no OclWrapper

### 2-OpenCL-v2.2-C++

C++ host code with the OpenCL v2.2 C++ API, no OclWrapper. 

### 3-OclWrapper-C++

C++ host code with the C++ OclWrapper API.

### 4-OclWrapper-internal-C-API

C++ host code with the internal C API used by OclWrapper.

### 5-OclWrapper-Fortran

Fortran-95 host code with the Fortran OclWrapper API.

### 6-OclWrapper-Perl

Perl host code with the Perl OclWrapper API.