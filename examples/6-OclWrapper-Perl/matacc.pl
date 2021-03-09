#!/usr/bin/perl

# This is a simple example program to illustrate the use of
# OclWrapper.pm, my OpenCL wrapper for Perl

# The kernel accumulates a large array by splitting it over the number of cores
# (c) Wim Vanderbauwhede 2011,2012

use warnings;
use strict;
use feature qw(say);
use Time::HiRes qw(gettimeofday tv_interval);

use OclWrapper;
use CTypes qw(float unsigned int);

# Square matrix dimension
my $WIDTH=1024*1;
my $mSize = $WIDTH*$WIDTH;
my $mWidth = $WIDTH;

my $REF=1;
my $nruns= 1;

# Create the data sets   ;
my $tc0=[gettimeofday];
# nice but useless for large arrays (anything over 16M hangs)
# my $mA = [ map { 1.0/$mSize } (1..$mSize)];

# *much* faster for large arrays 
# but results in an erroneous "Use of uninitialized value $array in pack" warning
my $mA;
$#{$mA}= $mSize-1;
my $v=1.0/$mSize;
for my $i (0 .. $mSize -1 )  {
	$mA->[$i]=$v;
}

my $tc0_tc1=tv_interval ($tc0);

say 'Array creation time: ',$tc0_tc1;

# Accumulate all elements in the matrix
my $mCref=0.0;
if ($REF==1) {
	my $t0=[gettimeofday];
	for my $run (1..$nruns) {
		$mCref=0.0;
		for my $i ( 0 .. $mWidth -1) {
			for my $j ( 0 .. $mWidth -1) {
				$mCref= $mCref + $mA->[$i*$mWidth+$j];
			}
		}
	} # run
	my $t0_t1=tv_interval ($t0);
	say 'Pure Perl run time: ',$t0_t1;
} else {
	$mCref=1.0;
}
#--------------------------------------------------------------------------------;
#---- Here starts the actual OpenCL part;
#--------------------------------------------------------------------------------;
my $t2=[gettimeofday];
# Initialise the OpenCL system;
my $knum= 10; # Kernel number (see .cl source)
my $kstr="mataccKernel$knum";
my $srcstr='matacc.cl';
my $ocl = new OclWrapper($srcstr,$kstr);

# This returns the number of cores on the device
my $nunits = $ocl->getMaxComputeUnits();
#print  "Number of compute units: $nunits\n";

# Create the buffers 
my $mA_buf = $ocl->makeReadBuffer(float, $mSize); # read from by the kernel
my $mC_buf = $ocl->makeWriteBuffer(float, $nunits); # written to by the kernel

# setArg takes the index of the argument and a value of the same type as the kernel argument;
$ocl->setArrayArg(0, $mA_buf );
$ocl->setArrayArg(1, $mC_buf);
$ocl->setConstArg(2, unsigned int, $mWidth);

my $t2_t3=tv_interval ($t2);
say 'OpenCL setup time: ',$t2_t3;

my $t4=[gettimeofday];
my $exec_time=0.0;
for my $run (1 .. $nruns) {
# Write the array to the device
	$ocl->writeArray($mA_buf,float, $mSize,$mA);
# Run the kernel
	$exec_time = $ocl->run($nunits*16,16);
# Read back the results;
	my $mC = $ocl->readArray($mC_buf,float, $nunits);
#--------------------------------------------------------------------------------;
#----  Here ends the actual OpenCL part;
#--------------------------------------------------------------------------------;
	my $mCtot=0.0;
	for my $i (0 .. $nunits-1) {
		$mCtot=$mCtot+$mC->[$i];
	}
	say 'OpenCL result '.(($mCtot==$mCref)? 'matches':'does not match').' Perl result';
	if ($mCtot!=$mCref) {
		say "$mCtot <> $mCref";
	}

} # nruns;
my $t4_t5=tv_interval ($t4);
say 'OpenCL kernel execution time: ',$exec_time;
say 'OpenCL run time: ',$t4_t5;

