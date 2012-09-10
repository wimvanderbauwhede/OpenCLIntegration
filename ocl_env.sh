# Environment variables for OpenCL Integration

# modify as required
export NVSDKCUDA_ROOT="/Developer/GPU\ Computing/"
export AMDAPPSDKROOT=/usr/local/AMD-APP-SDK-v2.4-lnx64
export INTELOCLSDKROOT=/usr
export OPENCL_DIR= $HOME/OpenCL # dir containing OpenCLIntegration folder!

export OPENCL_GPU=`$OPENCL_DIR/OpenCLIntegration/bin/test_gpu.pl`
export OPENCL_CPU=`$OPENCL_DIR/OpenCLIntegration/bin/test_cpu.pl`

export PYTHONPATH=$PYTHONPATH:$OPENCL_DIR/OpenCLIntegration
export PATH=$OPENCL_DIR/OpenCLIntegration/bin:$PATH

# For Fortran
export GFORTRAN="/usr/bin/gfortran"
export PGFORTRAN="/opt/pgi/bin/pgfortran"
# Must be either GNU or PGI compiler, no others supported yet
export FORTRAN_COMPILER=$GFORTRAN 

