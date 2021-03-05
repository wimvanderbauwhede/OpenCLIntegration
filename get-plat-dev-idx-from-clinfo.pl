use v5.30;
use strict;
use warnings;

use Data::Dumper;


=pod
The logic is
- If it is NVIDIA, it is a GPU
- If it is Intel, it is either a GPU or a CPU (forget MIC or FPGA), so look at $dev
- If it is AMD, it is either a GPU or a CPU, so look at $dev
- If it is Xilinx, it must be an FPGA (TODO)
=cut
my $test_clinfo = `which clinfo`;
chomp $test_clinfo;
if ($test_clinfo eq '') {
    return '-1,-1,4';
}
my @i=`clinfo -l`; 
my @entries =map {[split(/:/,$_)]} map {chomp;$_} @i;

my $plat=$ARGV[0];#'AMD';
my $dev=$ARGV[1];#'CPU';

my $platidx=-1;
my $devidx=-1;
my $getdev=0;
my $ok=0;
for my $entry (@entries) {
    
if ($platidx==-1 and $entry->[0]=~/Platform\s+\#(\d)/ ) { 
    $getdev=0;
    $platidx=$1;
    my $platstr=$entry->[1];
    $platstr=~s/^\s+//;
    $platstr=~s/\W.+$//;
    if ($platstr eq $plat) {
        $getdev=1;
    } else {
        $platidx=-1;
    }
}
if ($platidx!=-1 and $getdev and $entry->[0]=~/Device\s+\#(\d)/ ){
    $devidx=$1;
    my $devstr=$entry->[1];
    $devstr=~s/^\s+//;
    if (
        (
        (($plat eq 'AMD') or ($plat eq 'Intel')) and $dev eq 'CPU' and $devstr =~/CPU/ 
        )
        # print "devidx for $dev: $devidx\n";        
    or ($plat eq 'Intel' and $devstr =~/Graphics/ and $dev eq 'GPU' ) 
        # print "devidx for $dev: $devidx\n";
    
    or ($plat eq 'NVIDIA' and $dev eq 'GPU' )) {
        # print "devidx for $plat/$dev: $devidx\n";
        $ok=1;
        last;
    }  
    $devidx=-1;
}
}

if ($ok) {
    # say "$plat $platidx $dev $devidx";
    print "$platidx,$devidx,0"
} else {
    if ($platidx==-1) {
        # say "No valid platidx for $plat/$dev";
        print "$platidx,$devidx,1"
    }
    if ($devidx==-1) {
        # say "No valid devidx for $plat/$dev";
        print "$platidx,$devidx,2"
    }    
    
}
#print Dumper @r;

