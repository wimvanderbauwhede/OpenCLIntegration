# An OpenCL wrapper and a SCons build library
## to simplify integration of OpenCL code in Fortran, C++, C, and Perl

(c) Wim Vanderbauwhede 2010-now

This project provides the following:

- `OclWrapper`: and OpenCL wrapper class in C++ with additional bindings for Fortran, C and Perl.
- `OclBuilder.py`: a SCons builder library for OpenCL applications that use `OclWrapper`
- `ocl_env.sh`: environment variables used by `OclBuilder.py` (bash syntax)

## Usage

To use the OclWrapper and OclBuilder, you need the following:

- The [scons](http://scons.org) build system, and therefore Python 3;
- An OpenCL SDK and an OpenCL capable device (e.g. your CPU or GPU);
- A C++ compiler and depending on your target, a C or Fortran compiler, or Perl with the `Inline::C` module.

Modify the environment variables from `ocl_env.sh` to reflect your system setup and put them in your `.bashrc` or `.profile` or equivalent.

### Environment setup

The environment variables defined in `ocl_env.sh` are the following, you should change them to reflect the location of the SDKs on your system, the compilers used etc.:

    # Path to the OpenCLIntegration folder e.g.
    export OPENCL_DIR= $HOME/OpenCLIntegration

    # OpenCL SDK paths
    # NVIDIA
    export NVSDKCUDA_ROOT="..."
    # AMD
    export AMDAPPSDKROOT="..."
    # Intel
    export INTELOCLSDKROOT="..."

    # Compilers
    export CXX_COMPILER=/usr/bin/g++
    export CXX=$CXX_COMPILER
    export C_COMPILER=/usr/bin/gcc
    export CC=$C_COMPILER
    # Must be either GNU or PGI compiler, no others supported yet
    export FORTRAN_COMPILER=/usr/bin/gfortran
    export FC=$FORTRAN_COMPILER

    # Don't modify below this line
    export OPENCL_GPU=`$OPENCL_DIR/bin/test_gpu.pl`
    export OPENCL_CPU=`$OPENCL_DIR/bin/test_cpu.pl`
    export OPENCL_ACC=`$OPENCL_DIR/bin/test_acc.pl`

    export PYTHONPATH=$PYTHONPATH:$OPENCL_DIR
    export PATH=$OPENCL_DIR/bin:$PATH


### Examples

In the `examples` folder there are a number of examples illustrating the use of `OclWrapper` with C++, Fortran and Perl. See `README-examples.md` in that folder for more information.

### Building your code with the OclWrapper

#### Scons builds

- In your SConstruct file:

      from OclBuilder import initOcl

      # Define your Environment as required for your build

      # Initialise OpenCL-specific env values
      env = initOcl(env)

      # Rest of your build as usual

- For a simple build, you can also do:

      from OclBuilder import build

      appname='matmult_int'

      # Any additional sources
      sources=[appname+'.cc']

      build(appname,sources)

- For building Fortran code with the OclWrapper:

      from OclBuilder import initOcl, buildF

      envF=Environment(useF=1)
      envF=initOcl(envF)

      fsources=['matacc.f95']

      buildF(envF,'mataccF',fsources)

#### Building your own code without Scons

If you use Make or another build system for the rest of your code, you can build the OclWrapper library with SCons and then use it in your build script.
For example, to integrate OpenCL into Fortran, your SConscript would look like this:

      from OclBuilder import initOcl

      envF=Environment(useF=1)
      envF=initOcl(envF)

and in your Makefile, add the following:

      OCL_DIR = $(OPENCL_DIR)
      OCL_OBJS = oclWrapper.o
      OCL_LDFLAGS =  -L/path/to/OclWrapper -L$(OCL_DIR) \
                     -lOclWrapperF -lOclWrapper -lOpenCL -lstdc++ 

### Using the OclWrapper

#### C++ API

In  your C++ code:

      #include "OclWrapper.h"

      // Create a wrapper object

      OclWrapper ocl(...); // see code for constructor args

      ocl.makeReadBuffer(...);
      ocl.makeWriteBuffer(...);

      ocl.writeBuffer(...);
      ocl.enqueueNDRange(cl::NDRange(...), cl::NDRange(...));
      ocl.runKernel( ... ).wait();
      ocl.readBuffer(...);
      // There are many more options, see OclWrapper.h code

#### Fortran API

In your Fortran code:

      use oclWrapper

      oclMakeReadBuffer(...);
      oclMakeWriteBuffer(...);

      oclWriteBuffer(...);
      runOcl(globalrange, localrange)
      oclReadBuffer(...)
      ! There are  many more API calls, see `oclWrapper.f95` code

#### Perl API

In your Perl code:

    use OclWrapper;
    use CTypes qw(float unsigned int);

    # Initialise the OpenCL system;
    my $ocl = new OclWrapper('matacc.cl','mataccKernel10');

    # This returns the number of cores on the device
    my $nunits = $ocl->getMaxComputeUnits();

    # Create the buffers
    my $mA_buf = $ocl->makeReadBuffer(float, $mSize); # read from by the kernel
    my $mC_buf = $ocl->makeWriteBuffer(float, $nunits); # written to by the kernel

    # setArg takes the index of the argument and a value of the same type as the kernel argument;
    $ocl->setArrayArg(0, $mA_buf );
    $ocl->setArrayArg(1, $mC_buf);
    $ocl->setConstArg(2, unsigned int, $mWidth);

    # Write the array to the device
    $ocl->writeArray($mA_buf,float, $mSize,$mA);
    # Run the kernel
    $ocl->run($nunits*16,16);
    # Read back the results;
    my $mC = $ocl->readArray($mC_buf,float, $nunits);

    my $mCtot=0.0;
    for my $i (0 .. $nunits-1) {
        $mCtot=$mCtot+$mC->[$i];
    }
