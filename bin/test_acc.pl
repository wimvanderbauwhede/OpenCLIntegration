#!/usr/bin/perl
my $acc='';
if (-x '/sbin/lspci') {
    $acc=`lspci -v | grep Co-processor`;
} else { # assumme it's a Mac
    $acc='NONE';#`system_profiler -detailLevel mini | grep Chipset`;
}
if ($acc=~/Intel/i ) {
print 'Intel';
} elsif (
$acc=~/AMD/i ) { # bogus, but I don't know what would be OK
print 'AMD';
} else {
    print 'NONE';
}
