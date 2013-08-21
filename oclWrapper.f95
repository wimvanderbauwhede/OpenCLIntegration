    module oclWrapper
        implicit none
        integer(8) :: ocl
        integer :: oclNunits
        integer(8), dimension(32) :: oclBuffers
        integer, dimension(32,3) :: oclBufferShapes
        integer :: oclGlobalRange, oclLocalRange
        save
        contains

        subroutine oclInit(source,kernel)
            character(*) :: source 
            character(*) :: kernel 
!            print *, source, kernel
            call oclinitc(ocl, source, kernel)
        end subroutine

        subroutine oclGetMaxComputeUnits(nunits)
            integer :: nunits
            call oclGetMaxComputeUnitsC(ocl,nunits)
            oclNunits=nunits
        end subroutine

        subroutine oclMakeFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
!            real, dimension(size(array)):: array1d
!            array1d = reshape(array,shape(array1d))
            sz1d = size(array)*4 ! x4 because real is 4 bytes
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        subroutine oclMakeFloatArrayReadWriteBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
!            real, dimension(size(array)):: array1d
!            print *, 'Reshaping array'
!            array1d = reshape(array,shape(array1d))
            !sz1d = sz(1)*sz(2)*sz(3) ! 
            sz1d=size(array)*4 ! x4 because real is 4 bytes
!            real, allocatable, dimension(:) :: ptr
            !print *, 'sz:', sz
            !print *, 'sz1d:', sz1d
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d,array)
        end subroutine
        subroutine oclMakeIntArrayReadWriteBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1),sz(2),sz(3)) :: array
!            real, dimension(size(array)):: array1d
!            print *, 'Reshaping array'
!            array1d = reshape(array,shape(array1d))
            !sz1d = sz(1)*sz(2)*sz(3) ! 
            sz1d=size(array)*4 ! x4 because int is 4 bytes
!            real, allocatable, dimension(:) :: ptr
            !print *, 'sz:', sz
            !print *, 'sz1d:', sz1d
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d,array)
        end subroutine
        subroutine oclMakeIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1),sz(2),sz(3)) :: array
!            real, dimension(size(array)):: array1d
!            array1d = reshape(array,shape(array1d))
            sz1d = size(array)*4 ! x4 because integer is 4 bytes
            !print *, 'sz:', sz
            !print *, 'sz1d:', sz1d
            !integer, allocatable, dimension(:) :: ptr
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
!        subroutine oclMakeIntArrayReadWriteBuffer(buffer, sz,ptr)
!            integer(8):: buffer
!            integer :: sz
!            integer, allocatable, dimension(:) :: ptr
!           call oclMakeReadWriteBufferPtrC(ocl,buffer, sz,ptr)
!       end subroutine
        subroutine oclMakeReadBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz
            call oclMakeReadBufferC(ocl,buffer, sz)
        end subroutine
        subroutine oclMakeReadWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz
            call oclMakeReadWriteBufferC(ocl,buffer, sz)
        end subroutine
        subroutine oclMakeWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz
            call oclmakewritebufferc(ocl,buffer, sz)
        end subroutine
        subroutine oclWriteBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real, dimension(sz(1),sz(2),sz(3)) :: array
!            real, dimension(size(array)):: array1d!
!            array1d = reshape(array,shape(array1d))
            sz1d=size(array)*4 ! x4 because float is 4 bytes
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine

        subroutine oclWriteBufferById(bufferid, sz,array)
            integer:: bufferid
            integer :: sz1d
            integer, dimension(3):: sz
            real, dimension(sz(1),sz(2),sz(3)) :: array
!            real, dimension(size(array)):: array1d!
!            array1d = reshape(array,shape(array1d))
            sz1d=size(array)*4 ! x4 because float is 4 bytes
            call oclwritebufferc(ocl,oclBuffers(bufferid), sz1d,array)
        end subroutine

      
        subroutine oclSetArrayArg(pos,buf)
            integer :: pos 
            integer(8):: buf
            call oclsetarrayargc(ocl,pos,buf)
        end subroutine
        subroutine oclSetIntArrayArg(pos,buf)
            integer :: pos 
            integer(8):: buf
            call oclsetarrayargc(ocl,pos,buf)
        end subroutine
        subroutine oclSetFloatArrayArg(pos,buf)
            integer :: pos 
            integer(8):: buf
            call oclsetfloatarrayargc(ocl,pos,buf)
        end subroutine
        subroutine oclSetFloatConstArg(pos,constarg)
            integer :: pos
            real :: constarg
            call oclsetfloatconstargc(ocl,pos,constarg)
        end subroutine
        subroutine oclSetIntConstArg(pos,constarg)
            integer :: pos
            integer :: constarg
            call oclsetintconstargc(ocl,pos,constarg)
        end subroutine
!        subroutine oclRun(nargs,argtypes,args)
!            integer :: nargs, argstypes, 
!            call oclrunc(ocl,nargs,argtypes,args)
!        end subroutine
        subroutine runOcl(global,local)
            integer :: global, local
            call runoclc(ocl,global,local)
        end subroutine

        subroutine oclReadBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4 ! x4 because real is 4 bytes
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine

        subroutine oclReadBufferById(bufferid,sz,array)
            integer:: bufferid
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1),sz(2),sz(3)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array1d)*4 ! x4 because real is 4 bytes
            call oclreadbufferc(ocl,oclBuffers(bufferid),sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine

        subroutine oclReadRawBuffer(buffer,sz1d,array1d)
            integer(8):: buffer
            integer :: sz1d
            real, dimension(sz1d):: array1d
            call oclreadbufferc(ocl,buffer,sz1d*4,array1d)
        end subroutine

! Note the arg type is 3D array of integers!
        subroutine oclWriteIntBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer, dimension(sz(1),sz(2),sz(3)) :: array
!            integer, dimension(size(array)):: array1d!
!            array1d = reshape(array,shape(array1d))
            sz1d=size(array)*4 ! x4 because integer is 4 bytes
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine

        subroutine oclReadIntBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1),sz(2),sz(3)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array1d)*4 ! x4 because integer is 4 bytes
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine

!$GEN WrapperSubs

! Make n-D Array Buffers


        subroutine oclMake1DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            sz1d = sz(1)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            sz1d = sz(1)*sz(2)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            sz1d = sz(1)*sz(2)*sz(3)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DFloatArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real,dimension(sz(1)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real,dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DFloatArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real,dimension(sz(1)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real,dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DFloatArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            sz1d = sz(1)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            sz1d = sz(1)*sz(2)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            sz1d = sz(1)*sz(2)*sz(3)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DDoubleArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8),dimension(sz(1)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8),dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8),dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DDoubleArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8),dimension(sz(1)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8),dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8),dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DDoubleArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            sz1d = sz(1)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            sz1d = sz(1)*sz(2)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            sz1d = sz(1)*sz(2)*sz(3)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DIntArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*4 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer,dimension(sz(1)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer,dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DIntArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*4 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer,dimension(sz(1)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer,dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DIntArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*4 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            sz1d = sz(1)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake2DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            sz1d = sz(1)*sz(2)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake3DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            sz1d = sz(1)*sz(2)*sz(3)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake4DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake5DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake6DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake7DLongArrayWriteBuffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            sz1d = sz(1)*sz(2)*sz(3)*sz(4)*sz(5)*sz(6)*sz(7)*8 
            call oclMakeWriteBufferC(ocl,buffer, sz1d)
        end subroutine
        
        subroutine oclMake1DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8),dimension(sz(1)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8),dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8),dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DLongArrayReadBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*8 
            call oclMakeReadBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake1DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8),dimension(sz(1)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake2DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8),dimension(sz(1), sz(2)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake3DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8),dimension(sz(1), sz(2), sz(3)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake4DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake5DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake6DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
        subroutine oclMake7DLongArrayReadWriteBuffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d = size(array)*8 
            call oclMakeReadWriteBufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
        
! Write n-D Array Buffers


        subroutine oclWrite1DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real, dimension(sz(1)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real, dimension(sz(1), sz(2)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real, dimension(sz(1), sz(2), sz(3)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DFloatArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite1DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8), dimension(sz(1)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8), dimension(sz(1), sz(2)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8), dimension(sz(1), sz(2), sz(3)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DDoubleArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite1DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer, dimension(sz(1)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer, dimension(sz(1), sz(2)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer, dimension(sz(1), sz(2), sz(3)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DIntArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer, dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d=size(array)*4
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite1DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8), dimension(sz(1)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite2DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8), dimension(sz(1), sz(2)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite3DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8), dimension(sz(1), sz(2), sz(3)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite4DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite5DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite6DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
        subroutine oclWrite7DLongArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8), dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            sz1d=size(array)*8
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine
        
! Read n-D Array Buffers


        subroutine oclRead1DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real,dimension(sz(1)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real,dimension(sz(1), sz(2)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real,dimension(sz(1), sz(2), sz(3)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DFloatArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            real, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead1DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            real(8),dimension(sz(1)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            real(8),dimension(sz(1), sz(2)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            real(8),dimension(sz(1), sz(2), sz(3)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DDoubleArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            real(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            real(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead1DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer,dimension(sz(1)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer,dimension(sz(1), sz(2)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer,dimension(sz(1), sz(2), sz(3)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DIntArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer,dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer, dimension(size(array)):: array1d
            sz1d = size(array)*4
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead1DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(1):: sz
            integer(8),dimension(sz(1)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead2DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(2):: sz
            integer(8),dimension(sz(1), sz(2)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead3DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(3):: sz
            integer(8),dimension(sz(1), sz(2), sz(3)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead4DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(4):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead5DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(5):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead6DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(6):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
        subroutine oclRead7DLongArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension(7):: sz
            integer(8),dimension(sz(1), sz(2), sz(3), sz(4), sz(5), sz(6), sz(7)) :: array
            integer(8), dimension(size(array)):: array1d
            sz1d = size(array)*8
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        
    end module oclWrapper
