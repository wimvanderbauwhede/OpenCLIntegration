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


print "\n! Make n-D Array Buffers\n\n";

for my $type (@types) {
	my $ftype = $ftypes{$type};
	my $wordsz = $wordsizes{$type};
	for my $mode (@modes) {
		for my $dim (@dims) {
			my $szstr=gen_szstr($dim);
my $code_MakeArrayBuffer = "
        subroutine oclMake${dim}D${type}Array${mode}Buffer(buffer, sz, array)
            integer(8):: buffer
            integer :: sz1d
            integer, dimension($dim):: sz
            $ftype,dimension($szstr) :: array
            sz1d = size(array)*$wordsz 
            call oclMake${mode}BufferPtrC(ocl,buffer, sz1d, array)
        end subroutine
";
print $code_MakeArrayBuffer;
		}
	}
}

print "\n! Write n-D Array Buffers\n\n";

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
            sz1d=size(array)*$wordsz
            call oclwritebufferc(ocl,buffer, sz1d,array)
        end subroutine

";
print $code_WriteBuffer;
		}}

print "\n! Read n-D Array Buffers\n\n";


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
            sz1d = size(array)*$wordsz
            call oclreadbufferc(ocl,buffer,sz1d,array1d)
            array = reshape(array1d,shape(array))
        end subroutine
";
print $code_ReadBuffer;
		}}

