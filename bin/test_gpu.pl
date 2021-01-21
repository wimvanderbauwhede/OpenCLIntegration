#!/usr/bin/perl
my $gpu='';
if (-x '/usr/bin/lspci' || -x '/sbin/lspci') {
    $gpu=`lspci -v | grep VGA`;
    chomp $gpu;
    $gpu.=`lspci -v | grep NVIDIA`;
} else { # assumme it's a Mac
    $gpu='NVIDIA';#`system_profiler -detailLevel mini | grep Chipset`;
}
if ($gpu=~/nVidia/i ) {
print 'NVIDIA';
} elsif (
$gpu=~/AMD/i ) { # bogus, but I don't know what would be OK
print 'AMD';
} elsif (
$gpu=~/Intel/i ) { # bogus, but I don't know what would be OK
print 'Intel';
} else {
    print 'NONE';
}
