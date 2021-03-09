# OclWrapper for Perl

This is a Perl wrapper around the C API defined in `OclWrapperC.h` and implemented in `OclWrapperF.cc`
It needs the `Inline::C` module from CPAN.

To build the libraries, run:

    scons -f SConstruct.Perl.py [any other options you need] install

The `install` target will install the libraries in `$OPENCL_DIR/OpenCLIntegraton/lib`, where the Perl wrapper will look for them.
