! To make this work in GMCF with multiple OpenCL platforms and devices, or at least multiple devices, I use OCL_MULTIPLE_DEVICES
! Somewhat ad-hoc I use the devIdx as the index of the ocl instance, so this relies on the user selecting a different device in every thread, but otherwise it does not make sense anyway

    module oclWrapper
        implicit none
!        integer(8) :: ocl ! Is not used in user code and would need to be per-thread unique, so it must be an array.
        integer(8), dimension(0:7) :: ocl ! Is not used in user code and would need to be per-thread unique, so it must be an array.
#ifdef OCL_MULTIPLE_DEVICES
        integer(8) :: oclinstmap ! A pointer to a map from the POSIX thread ID to the OpenCL instance id, which is the index into the ocl array
#endif
        integer :: oclNunits, oclNthreadsHint  ! Does not need to be package global, can be defined locally in the module doing the API calls
! So I haven't solved this satisfactorily
! A better way might be to use setters and getters for this, so that you would say "call oclStoreBuffer()" and "call oclLoadBuffer()"

        integer(8), dimension(32) :: oclBuffers ! Is used in user code and would need to be per-thread unique
!#ifdef OCL_MULTIPLE_DEVICES
        integer(8), dimension(0:7,32) :: oclBuffersPerInst ! Is used in user code and would need to be per-thread unique, instead I require use of an explicit index
!#endif
        integer, dimension(32,3) :: oclBufferShapes ! Not used
        integer :: oclGlobalRange, oclLocalRange ! Does not need to be package global, can be defined locally in the module doing the API calls
        integer, dimension(2) :: oclGlobal2DRange, oclLocal2DRange ! Does not need to be package global, can be defined locally in the module doing the API calls
        integer, dimension(3) :: oclGlobal3DRange, oclLocal3DRange ! Does not need to be package global, can be defined locally in the module doing the API calls
        save
        contains

!        subroutine oclInit(srcstr,srclen,kstr,klen)
        subroutine oclInit(srcstrp,kstrp)
            integer(8) :: oclinstid
            integer :: srclen, klen
            character(len=*) :: srcstrp, kstrp
            character(len=:), allocatable :: srcstr, kstr
            srclen = len(srcstrp)
            klen = len(kstrp)
!            character(srclen) :: srcstr 
!            character(klen) :: kstr 
            allocate(character(len=srclen) :: srcstr)
            allocate(character(len=klen) :: kstr)
            srcstr=srcstrp
            kstr=kstrp
!            print *, "source=<",srcstr,">;  kernel=<",kstr,">"
            oclinstid = 0
!            print *, "INIT OCL"
#ifdef OCL_MULTIPLE_DEVICES
!            print *, "CALL SET INSTANCE"
            call oclsetinstancec(oclinstmap, oclinstid)
#endif
            call oclinitf(ocl(oclinstid), srcstr, srclen, kstr, klen)
        end subroutine

        subroutine oclInitDev(srcstrp,kstrp,devIdx)   
            integer(8) :: oclinstid
            integer, intent(In) :: devIdx
            integer :: srclen, klen
            character(len=*) :: srcstrp, kstrp
            character(len=:), allocatable :: srcstr, kstr
            srclen = len(srcstrp)
            klen = len(kstrp)
!            character(srclen) :: srcstr 
!            character(klen) :: kstr 
            allocate(character(len=srclen) :: srcstr)
            allocate(character(len=klen) :: kstr)
            srcstr=srcstrp
            kstr=kstrp
!            print *, "source=<",srcstr,">;  kernel=<",kstr,">"
#ifndef OCL_MULTIPLE_DEVICES
            oclinstid = 0
#else
            oclinstid = devIdx
           call oclsetinstancec(oclinstmap, oclinstid)
#endif

            call oclinitdevf(ocl(oclinstid), srcstr, srclen, kstr, klen, devIdx)
        end subroutine

        subroutine oclInitOpts(srcstrp,kstrp,koptsstrp)   
            integer(8) :: oclinstid
            integer :: srclen, klen, koptslen
            character(len=*) :: srcstrp, kstrp, koptsstrp
            character(len=:), allocatable :: srcstr, kstr, koptsstr
            srclen = len(srcstrp)
            klen = len(kstrp)
            koptslen = len(koptsstrp)
!            character(srclen) :: srcstr 
!            character(klen) :: kstr 
            allocate(character(len=srclen) :: srcstr)
            allocate(character(len=klen) :: kstr)
            allocate(character(len=koptslen) :: koptsstr)
            srcstr=srcstrp
            kstr=kstrp
            koptsstr = koptsstrp
!            print *, "source=<",srcstr,">;  kernel=<",kstr,">"
            oclinstid = 0
#ifdef OCL_MULTIPLE_DEVICES
           call oclsetinstancec(oclinstmap, oclinstid)
#endif
            call oclinitoptsf(ocl(oclinstid), srcstr, srclen, kstr, klen, koptsstr, koptslen)
        end subroutine        

        subroutine oclInitOptsDev(srcstrp,kstrp,koptsstrp,devIdx)
            integer(8) :: oclinstid
            integer, intent(In) :: devIdx
            integer :: srclen, klen, koptslen
            character(len=*) :: srcstrp, kstrp, koptsstrp
            character(len=:), allocatable :: srcstr, kstr, koptsstr
            srclen = len(srcstrp)
            klen = len(kstrp)
            koptslen = len(koptsstrp)
!            character(srclen) :: srcstr
!            character(klen) :: kstr
            allocate(character(len=srclen) :: srcstr)
            allocate(character(len=klen) :: kstr)
            allocate(character(len=koptslen) :: koptsstr)
            srcstr=srcstrp
            kstr=kstrp
            koptsstr = koptsstrp
!            print *, "source=<",srcstr,">;  kernel=<",kstr,">"
#ifndef OCL_MULTIPLE_DEVICES
            oclinstid = 0
#else
            oclinstid = devIdx
           call oclsetinstancec(oclinstmap, oclinstid)
#endif

            call oclinitoptsdevf(ocl(oclinstid), srcstr, srclen, kstr, klen, koptsstr, koptslen, devIdx)
        end subroutine

        subroutine oclGetMaxComputeUnits(nunits)
            integer :: nunits
            integer(8) :: oclinstid
            oclinstid = 0
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif
            call oclGetMaxComputeUnitsC(ocl(oclinstid),nunits)
            oclNunits=nunits
        end subroutine

        subroutine oclGetNThreadsHint(nthreads)
            integer :: nthreads
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclGetNThreadsHintC(ocl(oclinstid),nthreads)
            oclNthreadsHint=nthreads
        end subroutine

        

        subroutine oclMakeFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            real, dimension(size(array)):: array1d
!            array1d = reshape(array,shape(array1d))
            sz1d = size(array)*4 ! x4 because real is 4 bytes
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        subroutine oclMakeFloatArrayReadWriteBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            real, dimension(size(array)):: array1d
!            print *, 'Reshaping array'
!            array1d = reshape(array,shape(array1d))
            !sz1d = sz(1)*sz(2)*sz(3) ! 
            sz1d=size(array)*4 ! x4 because real is 4 bytes
!            real, allocatable, dimension(:) :: ptr
            !print *, 'sz:', sz
            !print *, 'sz1d:', sz1d
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        subroutine oclMakeIntArrayReadWriteBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            real, dimension(size(array)):: array1d
!            print *, 'Reshaping array'
!            array1d = reshape(array,shape(array1d))
            !sz1d = sz(1)*sz(2)*sz(3) ! 
            sz1d=size(array)*4 ! x4 because int is 4 bytes
!            real, allocatable, dimension(:) :: ptr
            !print *, 'sz:', sz
            !print *, 'sz1d:', sz1d
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        subroutine oclMakeIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            real, dimension(size(array)):: array1d
!            array1d = reshape(array,shape(array1d))
            sz1d = size(array)*4 ! x4 because integer is 4 bytes
            !print *, 'sz:', sz
            !print *, 'sz1d:', sz1d
            !integer, allocatable, dimension(:) :: ptr
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
!        subroutine oclMakeIntArrayReadWriteBuffer(buffer, sz,ptr)
!            integer(8):: buffer
!            integer :: sz
!            integer, allocatable, dimension(:) :: ptr
!           call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz,ptr)
!       end subroutine
        subroutine oclMakeReadBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclMakeReadBufferC(ocl(oclinstid),buffer, sz)
        end subroutine
        subroutine oclMakeReadWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclMakeReadWriteBufferC(ocl(oclinstid),buffer, sz)
        end subroutine
        subroutine oclMakeWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclmakewritebufferc(ocl(oclinstid),buffer, sz)
        end subroutine
        subroutine oclWriteBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real, dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            real, dimension(size(array)):: array1d!
!            array1d = reshape(array,shape(array1d))
            sz1d=size(array)*4 ! x4 because float is 4 bytes
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine

        subroutine oclWriteBufferById(bufferid, sz,array)
            integer:: bufferid
            integer :: sz1d
            integer, dimension(3):: sz
            real, dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            real, dimension(size(array)):: array1d!
!            array1d = reshape(array,shape(array1d))
            sz1d=size(array)*4 ! x4 because float is 4 bytes
            call oclwritebufferc(ocl(oclinstid),oclBuffers(bufferid), sz1d,array)
        end subroutine

      
        subroutine oclSetArrayArg(pos,buf)
            integer :: pos 
            integer(8):: buf
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclsetarrayargc(ocl(oclinstid),pos,buf)
        end subroutine
        subroutine oclSetIntArrayArg(pos,buf)
            integer :: pos 
            integer(8):: buf
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclsetarrayargc(ocl(oclinstid),pos,buf)
        end subroutine
        subroutine oclSetFloatArrayArg(pos,buf)
            integer :: pos 
            integer(8):: buf
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclsetfloatarrayargc(ocl(oclinstid),pos,buf)
        end subroutine
        subroutine oclSetFloatConstArg(pos,constarg)
            integer :: pos
            real :: constarg
            integer(8) :: oclinstid
            oclinstid=0
            call oclsetfloatconstargc(ocl(oclinstid),pos,constarg)
        end subroutine
        subroutine oclSetIntConstArg(pos,constarg)
            integer :: pos
            integer :: constarg
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclsetintconstargc(ocl(oclinstid),pos,constarg)
        end subroutine
!        subroutine oclRun(nargs,argtypes,args)
!            integer :: nargs, argstypes, 
!            call oclrunc(ocl(oclinstid),nargs,argtypes,args)
!        end subroutine

        subroutine runOcl(global,local,exectime)
            integer :: global, local
            integer(8) :: oclinstid
            real(4) :: exectime
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif
            call runoclc(ocl(oclinstid),global,local,exectime)
        end subroutine

        subroutine runOcl2DRange(global,local,exectime)
            integer, dimension(2) :: global, local
            integer(8) :: oclinstid
            real(4) :: exectime
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif
            call runoclc2d(ocl(oclinstid),global,local,exectime)
        end subroutine

        subroutine runOcl3DRange(global,local,exectime)
            integer, dimension(3) :: global, local
            integer(8) :: oclinstid
            real(4) :: exectime
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif
            call runoclc3d(ocl(oclinstid),global,local,exectime)
        end subroutine

        subroutine oclReadBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            sz1d = size(array)*4 ! x4 because real is 4 bytes
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine

        subroutine oclReadBufferById(bufferid,sz,array)
            integer:: bufferid
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            sz1d = size(array1d)*4 ! x4 because real is 4 bytes
            call oclreadbufferc(ocl(oclinstid),oclBuffers(bufferid),sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine

        subroutine oclReadRawBuffer(buffer,sz1d,array1d)
            integer(8):: buffer
            integer :: sz1d
            real, dimension(sz1d):: array1d
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            call oclreadbufferc(ocl(oclinstid),buffer,sz1d*4,array1d)
        end subroutine

! Note the arg type is 3D array of integers!
        subroutine oclWriteIntBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer, dimension(sz(1),sz(2),sz(3)) :: array
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

!            integer, dimension(size(array)):: array1d!
!            array1d = reshape(array,shape(array1d))
            sz1d=size(array)*4 ! x4 because integer is 4 bytes
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine

        subroutine oclReadIntBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1),sz(2),sz(3)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif

            sz1d = size(array1d)*4 ! x4 because integer is 4 bytes
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine

        subroutine padRange(orig_range, m)
            integer, intent(InOut) :: orig_range
            integer, intent(In) :: m
            if (mod(orig_range,m) /= 0) then
                orig_range = orig_range + (m - (mod(orig_range,m)))
            end if
        end subroutine


        subroutine oclStoreBuffer(idx,buffer )
            integer(8):: buffer
            integer :: idx
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif
!            print *, "STORE BUFFER ", buffer , " in INST ",oclinstid, " IDX ", idx
            oclBuffersPerInst(oclinstid,idx) = buffer
        end subroutine oclStoreBuffer

        subroutine oclLoadBuffer(idx, buffer)
            integer(8):: buffer
            integer :: idx
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0
#endif
!            print *, "LOAD BUFFER ", buffer , " from INST ",oclinstid, " IDX ", idx
            buffer = oclBuffersPerInst(oclinstid,idx)
        end subroutine oclLoadBuffer

!$GEN WrapperSubs

    end module oclWrapper
