#!/usr/bin/perl
use warnings;
use strict;

my @modes = qw(Read Write ReadWrite);
my @types = qw(Float Double Int Long);
my %ftypes =(Float => 'real', Int => 'integer', Double => 'real(8)', Long => 'integer(8)');
my %wordsizes = (Float => 4, Double => 8, Int => 4, Long => 8);
my @dims = (1..7); # Fortran arrays are limited to 7 dimensions

sub gen_szstr {
	my $dim=shift;
	my @insts = map {"sz($_)" } (1..$dim);
	my $szstr=join(', ',@insts);
	return $szstr;
}

open my $IN, '<', 'oclWrapper_TEMPL.f95';
open my $OUT, '>', 'oclWrapper.f95';
        print $OUT "!!! Don't edit this file!!! Edit oclWrapper_TEMPL.f95 and run $0 !!!\n";

while (my $line = <$IN> ){
    print $OUT $line;
    if ($line=~/^\s*\!\s*\$GEN\s+WrapperSubs/i) {

        print $OUT "\n! Make n-D Array Buffers\n\n";

        for my $type (@types) {
            my $ftype = $ftypes{$type};
            my $wordsz = $wordsizes{$type};
            for my $mode ('Write') {
                for my $dim (@dims) {
                    my $szstr=gen_szstr($dim);
                    $szstr=~s/\s*,\s*/*/g;
                    my $code_MakeArrayBuffer = "
        subroutine oclMake${dim}D${type}Array${mode}Buffer(buffer, sz)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension($dim):: sz
            integer(8) :: oclinstid
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = $szstr*$wordsz 
            call oclMake${mode}BufferC(ocl(oclinstid),buffer, sz1d)
        end subroutine
        ";
                    print $OUT $code_MakeArrayBuffer;
                }
            }

            for my $mode (qw(Read ReadWrite)) {
                for my $dim (@dims) {
                    my $szstr=gen_szstr($dim);
                    my $code_MakeArrayBuffer = "
        subroutine oclMake${dim}D${type}Array${mode}Buffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension($dim):: sz
            $ftype,dimension($szstr) :: array
            integer(8) :: oclinstid            
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d = size(array)*$wordsz 
			! print *, 'oclMake${dim}D${type}Array${mode}Buffer(',sz1d,')'
            call oclMake${mode}BufferPtrC(ocl(oclinstid),buffer, sz1d, array)
        end subroutine
        ";
                    print $OUT $code_MakeArrayBuffer;
                }
            }

        }

        print $OUT "\n! Write n-D Array Buffers\n\n";

        for my $type (@types) {
            my $ftype = $ftypes{$type};
            my $wordsz = $wordsizes{$type};

            for my $dim (@dims) {
                my $szstr=gen_szstr($dim);

                my $code_WriteBuffer = "
        subroutine oclWrite${dim}D${type}ArrayBuffer(buffer, sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension($dim):: sz
            $ftype, dimension($szstr) :: array
            integer(8) :: oclinstid          
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif             
            sz1d=size(array)*$wordsz
            call oclwritebufferc(ocl(oclinstid),buffer, sz1d,array)
        end subroutine
        ";
                print $OUT $code_WriteBuffer;
            }}

        print $OUT "\n! Read n-D Array Buffers\n\n";

        for my $type (@types) {
            my $ftype = $ftypes{$type};
            my $wordsz = $wordsizes{$type};

            for my $dim (@dims) {
                my $szstr=gen_szstr($dim);

                my $code_ReadBuffer = "
        subroutine oclRead${dim}D${type}ArrayBuffer(buffer,sz,array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension($dim):: sz
            $ftype,dimension($szstr) :: array
            $ftype, dimension(size(array)):: array1d
            integer(8) :: oclinstid      
#ifdef OCL_MULTIPLE_DEVICES            
           call oclgetinstancec(oclinstmap, oclinstid)
#else
            oclinstid = 0           
#endif               
            sz1d = size(array)*$wordsz
            call oclreadbufferc(ocl(oclinstid),buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
        ";
                print $OUT $code_ReadBuffer;
            }
        }
    }
} # loop over template source
close $IN;
close $OUT;
