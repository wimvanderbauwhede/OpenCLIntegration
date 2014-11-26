#!/usr/bin/perl
my $cpu='';
if (-x '/usr/bin/lspci' || -x '/sbin/lspci') {
    $cpu=`grep -m 1 'model name' /proc/cpuinfo`;
} else { # assumme it's a Mac
    $cpu='NVIDIA';#`system_profiler -detailLevel mini | grep Chipset`;
}
if ($cpu=~/Intel/i ) {
	print 'Intel';
} elsif ( $cpu=~/AMD/i ) { 
	print 'AMD';
} else {
	print 'NONE';
}
