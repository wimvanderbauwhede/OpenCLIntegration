program oclWrapperAPIexample

    use oclWrapper

    implicit none

    integer :: i
    real(kind=4), dimension(5) :: exectimes

    character(len=*), parameter :: kernel1 = "stream_reader"
    character(len=*), parameter :: kernel2 = "dyn_kernel"
    character(len=*), parameter :: kernel3 = "shapiro_kernel"
    character(len=*), parameter :: kernel4 = "update_kernel"
    character(len=*), parameter :: kernel5 = "stream_writer"

    integer(kind=8) :: eta_in_buf, eta_out_buf
    integer(kind=4), dimension(1) :: eta_sz

    integer(4), parameter :: nx = 500
    integer(4), parameter :: ny = 500

    real :: eta(0:ny+1,0:nx+1)

    ! Initialisation

    eta_sz(1) = (ny+2)*(nx+2)

    call oclInitMultiKernel("shallowWater2D.bin")
    call loadKernel(kernel1)
    call loadKernel(kernel2)
    call loadKernel(kernel3)
    call loadKernel(kernel4)
    call loadKernel(kernel5)
    ! Create the buffers
    call oclMake1DFloatArrayReadBuffer(eta_in_buf,eta_sz,eta)
    call oclMake1DFloatArrayWriteBuffer(eta_out_buf, eta_sz)

    ! Set the kernel arguments
    call oclSetKernelArrayArg(kernel1,1,eta_in_buf)
    call oclSetKernelArrayArg(kernel5,1,eta_out_buf)

    ! Actuall data transfer and running of kernels

    ! Write data to FPGA memory
    call oclWrite1DFloatArrayBuffer(eta_in_buf,eta_sz,eta)

    ! Launch the kernels

    call runOclTask(kernel1, exectimes(1))
    call runOclTask(kernel2, exectimes(2))
    call runOclTask(kernel3, exectimes(3))
    call runOclTask(kernel4, exectimes(4))
    call runOclTask(kernel5, exectimes(5))

    call oclWait(kernel5)

    ! Read data from FPGA memory
    call oclRead1DFloatArrayBuffer(eta_out_buf, eta_sz,eta)


end program oclWrapperAPIexample
