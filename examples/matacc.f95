! This is a simple example program to illustrate the use of
! OclWrapperF, my OpenCL wrapper for Fortran
! (c) Wim Vanderbauwhede 2011-2021

      program MatrixAccumulation
        use oclWrapper
        implicit none
        ! Variables set via cpp macros
        integer :: nruns    
        integer :: mSize
        integer :: mWidth 
        integer :: knum
        ! loop counters
        integer :: i,j,k,run

        real:: mCref
        real, allocatable, dimension(:)  :: mA 
        real, allocatable, dimension(:)  :: mC 

        integer :: nunits
        ! character(15) :: kstr ! TODO: dynamic allocation
        ! character(10) :: srcstr  ! TODO: dynamic allocation
        character(len=*), parameter :: srcstr = "matacc.cl"
        character(len=:),allocatable :: knumstr, kstr
        character(len=*), parameter :: kbasestr   = "mataccKernel"

        !integer(8):: ocl
        integer(8):: mA_buf
        integer(8):: mC_buf
        integer, dimension(1):: mAsz
        integer, dimension(1):: mCsz

#ifdef VERBOSE        
        ! for comparison with reference        
        real::mCtot
        integer :: correct
#endif        
        ! for timings
        real, dimension(2) :: tarray
        real :: result
        real(4) :: exectime
        exectime = 0.0
        knum= KERNEL
        nruns=NRUNS
        mSize = WIDTH*WIDTH
        mWidth = WIDTH       
        mAsz(1) = mSize
        
        ! print *, mWidth
        allocate( mA(mSize) )
        ! Create the data sets   
        mA = (/ (k*0.0+1.0/mSize, k=1,mSize) /)
#if REF!=0
        mCref=0.0
        do run=1,nruns
            mCref=0.0
            call dtime(tarray, result)
            do i = 1,mWidth 
                do j = 1,mWidth 
                    mCref= mCref + mA((i-1)*mWidth+j)
                end do
            end do
            call dtime(tarray, result)
#ifdef VERBOSE
        print *,  "Execution time for reference: ",result*1000," ms"
#else
        print *,  " ",result*1000, " "
#endif
        end do
#endif

#if REF!=2
        !--------------------------------------------------------------------------------
        !---- Here starts the actual OpenCL part
        !--------------------------------------------------------------------------------

        ! Initialise the OpenCL system

        ! Create the kernel name

        if (knum .gt. 9) then
                allocate( character(len=14) :: kstr )
                allocate( character(len=2) :: knumstr )            
                write(knumstr,'(i2.2)') knum
        else
                allocate( character(len=13) :: kstr )
                allocate( character(len=1) :: knumstr )
                write(knumstr,'(i1.1)') knum
        !     write(kstr,'(a12,i1.1)') "mataccKernel", knum
        end if
        kstr = kbasestr // knumstr
        call oclInit(srcstr,kstr)
        call oclGetMaxComputeUnits(nunits)

#ifdef VERBOSE
        print *, "Number of compute units: ",nunits
#endif 

        ! Allocate space for results
        allocate( mC(nunits) )
        mCsz(1) = nunits

        ! Create the buffers
        call oclMake1DFloatArrayReadBuffer(mA_buf, mAsz, mA)
        call oclMake1DFloatArrayWriteBuffer(mC_buf,mCsz) 
        ! setArg takes the index of the argument and a value of the same type as the kernel argument
        call oclSetFloatArrayArg(0, mA_buf )
        call oclSetFloatArrayArg(1, mC_buf)
        call oclSetIntConstArg(2, mWidth)

        do run=1,nruns
            call oclWrite1DFloatArrayBuffer(mA_buf, mASz, mA)
        ! This is the actual "run" command.
            call dtime(tarray, result)
!   double tstart=wsecond()
            call runOcl( &
#if KERNEL<7 || KERNEL==14
             nunits, &
             1       &
#elif KERNEL<=8 || KERNEL==15
            nunits*16, &
            16 &  
#elif KERNEL==9 || KERNEL==16
            nunits*32,&
            32 & 
#elif KERNEL==10
            nunits*16,&
            16 & 
#elif KERNEL==12
            nunits*16, &
            16 &
#elif KERNEL==13 || KERNEL==17
            nunits*64, &
            64 &
#elif KERNEL==18 || KERNEL==20
            nunits*128, &
            128 &
#elif KERNEL==19
            nunits*256, &
            256 &
#elif KERNEL==11
            nunits, &
            1 &
#endif
        , exectime )
           
            ! Read back the results
            call oclRead1DFloatArrayBuffer(mC_buf,mCsz,mC)
            call dtime(tarray, result)
#endif 
        !--------------------------------------------------------------------------------
        !----  Here ends the actual OpenCL part
        !--------------------------------------------------------------------------------
#ifdef VERBOSE
#if REF==1
            mCtot=0.0
            do i=1,nunits
                mCtot=mCtot+mC(i)
            end do
            correct=0               ! number of correct results returned
            if (mCtot .eq. mCref) then
                correct=correct+1
            end if
            print '(A2,F3.1,A2,F3.1)', "  ",mCtot,"<>",mCref
#endif
#if REF!=2
            print *, "OpenCL kernel execution time: ",exectime," ms"
            print *, "OpenCL execution time: ",result*1000," ms"
        end do ! nruns
#endif
#else
#if REF!=2
            print *,  " ",result*1000," "
        end do ! nruns
#endif
#endif


      end
