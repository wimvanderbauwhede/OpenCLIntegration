#import OclBuilder 
from OclBuilder import initOcl, buildF

envF=Environment(useF=1)
envF=initOcl(envF)

fsources=['matacc.f95']
#fsources=['matacc_multiple_calls.f','matacc_call.f']
# Move into builder
#envF['FORTRANFLAGS']=envF['CFLAGS']
#envF.Append(FORTRANFLAGS=['-cpp','-m64'])

buildF(envF,'mataccF',fsources)

