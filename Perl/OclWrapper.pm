package OclWrapper;

use strict;
use warnings;
#no warnings 'uninitialized';
use feature qw(switch say);
#use CTypes qw(unsigned char int long uint32_t);

use Inline (
'C' => 'DATA', # Don't know why this must be 'DATA'
        LIBS => '-L. -L'.$ENV{'OPENCL_DIR'}.'/OpenCLIntegration/lib -lOclWrapperF -lstdc++ -lOpenCL',
        INC => '-I'.$ENV{'OPENCL_DIR'}.'/OpenCLIntegration',
		FORCE_BUILD => 0,
        CLEAN_AFTER_BUILD => 0
);

our $READ=0; our $WRITE=1; our $CONST=2;

sub new {
	(my $class, my $srcstr,my $kstr) = @_;
	my $self = [];#*__{SCALAR};
	bless $self, $class;
	$self->[0]=oclInit($srcstr,$kstr);
	return $self;
}

sub getMaxComputeUnits { (my $self) = @_;
	my $ocl=$self->[0];
	return oclGetMaxComputeUnits($ocl);
}

sub makeReadBuffer {
    (my $self,my $code,my $bufsz,my $arr)=@_;
	my $ocl=$self->[0];
    my $wordsz=$code & 0xF;
	my $sz=$wordsz*$bufsz;
    my $buf = [oclMakeReadBuffer($ocl, $sz),$code,$sz,$arr,$READ];
	return $buf;
}

sub makeWriteBuffer {
    (my $self,my $code,my $asz,my $arr)=@_;
	my $ocl=$self->[0];
    my $wsz=$code & 0xF;
	my $sz=$wsz*$asz;
	
    my $buf = [oclMakeWriteBuffer($ocl, $sz),$code,$sz,$arr,$WRITE];
	return $buf;
}

sub writeBuffer {
    (my $self,my $oclbuf)=@_;
	my $ocl=$self->[0];
	my $buf=$oclbuf->[0];
	my $code=$oclbuf->[1];
	my $asz=$oclbuf->[2];
	my $array=$oclbuf->[3];
	
    my $wsz=$code & 0xF;
	my $sz=$asz;

    given ($code) {
	    when (4) {
#float
			my $ap =  pack('f*',@{$array});
			my $buf=$oclbuf->[0];
			oclwritebuffer($ocl,$buf,$sz,$ap);			
		}
	    when (8) {  
#double
		}
	    when (20) { 
#uint32_t			
		}	    	    	    	    	    	    	    
	    when (24) { 
#uint64_t			
		}	    	    	    	    	    	    	    
	    default {  }
	}
}	
sub writeArray {
    (my $self,my $oclbuf,my $code,my $asz, my $array)=@_;
	my $ocl=$self->[0];
    my $wsz=$code & 0xF;
	my $sz=$wsz*$asz;
    
    given ($code) {
	    when (4) {
#float
			my $ap =  pack('f*',@{$array});
			my $buf=$oclbuf->[0];
			oclwritebuffer($ocl,$buf,$sz,$ap);			
		}
	    when (8) {  
#double
		}
	    when (20) { 
#uint32_t			
		}	    	    	    	    	    	    	    
	    when (24) { 
#uint64_t			
		}	    	    	    	    	    	    	    
	    default {  }
	}
}	


sub readArray {
    (my $self,my $oclbuf,my $code,my $asz)=@_;
	my $ocl=$self->[0];
    my $wsz=$code & 0xF;
	my $sz=$wsz*$asz;
    
    given ($code) {
	    when (4) {
#float
			my $ap = oclreadbuffer($ocl, $oclbuf->[0], $sz) ;
			my $fa = [ unpack('f*', $ap) ];
			return $fa;				
		}
	    when (8) {  
#double
		}
	    when (20) { 
#uint32_t			
		}	    	    	    	    	    	    	    
	    when (24) { 
#uint64_t			
		}	    	    	    	    	    	    	    
	    default {  }
	}
}	

sub readBuffer {
    (my $self,my $oclbuf)=@_;
	my $ocl=$self->[0];
	my $buf=$oclbuf->[0];
	my $code=$oclbuf->[1];
	my $asz=$oclbuf->[2];
	
    my $wsz=$code & 0xF;
	my $sz=$asz;

 given ($code) {
	    when (4) {
#float
			my $ap = oclreadbuffer($ocl, $buf, $sz) ;
			@{$oclbuf->[3]} = unpack('f*', $ap) ;
		}
	    when (8) {  
#double
		}
	    when (20) { 
#uint32_t			
		}	    	    	    	    	    	    	    
	    when (24) { 
#uint64_t			
		}	    	    	    	    	    	    	    
	    default {  }
	}
}	


sub setArrayArg {
    (my $self,my $pos, my $buf)=@_;
	my $ocl=$self->[0];
	oclSetArrayArg($ocl,$pos, $buf->[0]);
}

sub setConstArg {
    (my $self,my $pos, my $code, my $constarg)=@_;
	my $ocl=$self->[0];
	given ($code) {
		when (20) {
			oclSetIntConstArg($ocl,$pos, $constarg);
		}
		default {
		}
	}
}
sub makeConstArg {
    (my $self,my $code,my $constarg)=@_;
	
    my $buf = [$constarg,$code,0,[],$CONST];
	return $buf;
}

sub run { (my $self, my $g, my $l)=@_;
	my $ocl=$self->[0];
	oclRun ($ocl,$g, $l);
}

sub setNThreads {
	(my $self, my $nth)=@_;
	$self->[2]=$nth;
}
sub setRange { (my $self, my $g, my $l)=@_;
	$self->[1]=$g/$l;$self->[2]=$l;
}

sub runKernel { (my $self, my @args) = @_;
	my $ocl=$self->[0];
	my $nth= $self->[2];
	my $nunits = oclGetMaxComputeUnits($ocl);
	my $idx=0;
	for my $arg (@args) {
		if ($arg->[4]==$WRITE) {
			oclSetArrayArg($ocl,$idx, $arg->[0] );
		} elsif ($arg->[4]==$READ) {
			oclSetArrayArg($ocl,$idx, $arg->[0] );
			$self->writeBuffer($arg);
		} else {
			$self->setConstArg($idx, $arg->[1], $arg->[0]);
		}
		$idx++;
	}
	$self->run($nunits*$nth,$nth);
	for my $arg (@args) {
		if ($arg->[4]==$WRITE) {
			$self->readBuffer($arg);
		}
	}
}

sub fold { (my $self, my $subref);



}
1;

__DATA__

__C__

#include "OclWrapperC.h"

long oclInit(char* clsrcstr, char* kstr) {
	uint64_t ocl_ivp;
    	oclinitc_(&ocl_ivp,clsrcstr,kstr);
	return ocl_ivp;
}
int oclGetMaxComputeUnits(long ocl) {
	int nunits;
	oclgetmaxcomputeunitsc_(&ocl,&nunits);
	return nunits;
}

long oclMakeReadBuffer(long ocl, int sz) {
	uint64_t buffer;
	oclmakereadbufferc_(&ocl,&buffer, &sz);
	return buffer;
}

long oclMakeWriteBuffer(long ocl, int sz) {
	uint64_t buffer;
	oclmakewritebufferc_(&ocl,&buffer, &sz);
	return buffer;
}

void oclwritebuffer(long ocl, long buffer, int sz, char* array) {
	//void* array=(float*)array;
	oclwritebufferc_(&ocl,&buffer, &sz, array);
}

SV* oclreadbuffer(long ocl, long buffer, int sz ) {
//	void* data = malloc(sz);

	SV *res = newSV(sz);
// Tell the raw SV it should be a string
	SvPOK_on(res);
// Extract the pointer to the underlying buffer
	void *data = SvPV_nolen(res);

	oclreadbufferc_(&ocl,&buffer, &sz,data);
	sv_setpvn(res,data,sz);
//	SV* res = newSVpvn((char*)data,sz);
//	free( data);
	return res;
}
void oclSetArrayArg(long ocl,int pos, long buf) {
	oclsetarrayargc_(&ocl,&pos, &buf);
}
void oclSetFloatArrayArg(long ocl,int pos, long buf) {
	oclsetarrayargc_(&ocl,&pos, &buf);
}
void oclSetIntConstArg(long ocl,int pos, int constarg) {
	oclsetintconstargc_(&ocl,&pos, &constarg);
}
void oclRun (long ocl,int globalrange , int localrange) {
	runoclc_(&ocl,&globalrange , &localrange);
}

