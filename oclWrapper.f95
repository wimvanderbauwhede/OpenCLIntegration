!!! Don't edit this file!!! Edit oclWrapper_TEMPL.f95 and run gen_F95_wrapper_subs.pl !!!
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

        integer(8), dimension(256) :: oclBuffers ! Is used in user code and would need to be per-thread unique
!#ifdef OCL_MULTIPLE_DEVICES
        integer(8), dimension(0:7,256) :: oclBuffersPerInst ! Is used in user code and would need to be per-thread unique, instead I require use of an explicit index
!#endif
        integer, dimension(256,3) :: oclBufferShapes ! Not used
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

! Make n-D Array Buffers


        subroutine oclMake1DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real,dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake1DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real,dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake2DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake3DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake4DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake5DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake6DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake7DFloatArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real,dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake1DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real,dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake2DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake3DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake4DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake5DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake6DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake7DFloatArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8),dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake1DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8),dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake2DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8),dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake3DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake4DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake5DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake6DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake7DDoubleArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8),dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake1DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8),dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake2DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8),dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake3DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake4DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake5DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake6DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake7DDoubleArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*4 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer,dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake1DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer,dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake2DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake3DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake4DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake5DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake6DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake7DIntArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer,dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake1DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer,dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake2DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake3DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake4DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake5DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake6DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*4 
			! print *, 'oclMake7DIntArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*8 
            call oclMakeWriteBufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8),dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake1DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8),dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake2DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8),dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake3DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake4DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake5DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake6DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake7DLongArrayReadBuffer(',sz1d,')'
            call oclMakeReadBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8),dimension(sz(1)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake1DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8),dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake2DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8),dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake3DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake4DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake5DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake6DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*8 
			! print *, 'oclMake7DLongArrayReadWriteBuffer(',sz1d,')'
            call oclMakeReadWriteBufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        
! Write n-D Array Buffers


        subroutine oclWrite1DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real, dimension(sz(1)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real, dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real, dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite1DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8), dimension(sz(1)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8), dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8), dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite1DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer, dimension(sz(1)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer, dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer, dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*4
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite1DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8), dimension(sz(1)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8), dimension(sz(1), sz(2)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8), dimension(sz(1), sz(2), sz(3)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*8
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        
! Read n-D Array Buffers


        subroutine oclRead1DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real,dimension(sz(1)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real,dimension(sz(1), sz(2)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1), sz(2), sz(3)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            real, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead1DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8),dimension(sz(1)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8),dimension(sz(1), sz(2)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8),dimension(sz(1), sz(2), sz(3)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            real(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead1DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer,dimension(sz(1)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer,dimension(sz(1), sz(2)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1), sz(2), sz(3)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*4
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead1DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8),dimension(sz(1)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8),dimension(sz(1), sz(2)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8),dimension(sz(1), sz(2), sz(3)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8), dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*8
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
    end module oclWrapper
