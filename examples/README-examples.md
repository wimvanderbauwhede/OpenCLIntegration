# Example OpenCL code with and without OclWrapper

This folder contains example code with and without `OclWrapper`. All examples use the same OpenCl source, `matacc.cl`. The kernels in this source compute the sum of all values in a matrix in different ways. 

## Building the examples

Every example except the Perl one can be built by `cd`-ing into the directory and running `scons`. The build script takes many options that let you configure the build in terms of the size of the matrix, the kernel to use, the device to run the kernel on, etc. Run `scons -h` for a list of all options.

To run the Perl example, you must have the `Inline::C` module installed. Before first use, you must build the libraries in `$OPENCL_DIR/OpenCLIntegration/Perl` by running 

    scons -f SConstruct.Perl.py [any options you require] install

You can either add the `$OPENCL_DIR/OpenCLIntegration/Perl` directory to your `PERL5LIB` environment variable:

    export PERL5LIB=4PERL5LIB:"$OPENCL_DIR/OpenCLIntegration/Perl"

and then you can run the script simply as:

    perl matacc.pl

or specify it using the `-I` flag:

    perl -I $OPENCL_DIR/OpenCLIntegration/Perl matacc.pl

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