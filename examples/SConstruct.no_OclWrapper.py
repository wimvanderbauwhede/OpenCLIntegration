import os
#import commands

help = """
Options:
dev=CPU|GPU [GPU] device
kernel=[1]   
w=number [1024]   matrix width
ref=0|1|2 [1]     reference 2=ref only
v=0|1 [1]         verbose
mode=0|1|2   COPY|COPY+ALLOC|USE 
nruns=[1]
"""

PLATIDX=2 # change this as required
OPENCL_DIR=os.environ['OPENCL_DIR']
NVSDKCUDA_ROOT=os.environ['NVSDKCUDA_ROOT']
# print OPENCL_DIR
dev=ARGUMENTS.get('dev','GPU')
kernel=ARGUMENTS.get('kernel','1')
width=ARGUMENTS.get('w','1024')
ref=ARGUMENTS.get('ref','1')
refflag='-DREF'
verbose=ARGUMENTS.get('v','1')
vflag='-DVERBOSE'
if verbose=='0':
    vflag=''
mode=ARGUMENTS.get('mode','1')
memreadflag='-DMRMODE='+mode
nruns=ARGUMENTS.get('nruns','1')
nrunsflag='-DNRUNS='+nruns

devinfo=ARGUMENTS.get('info','0')
devinfoflag=''
if devinfo=='1':
    devinfoflag='-DDEVINFO'
DEVFLAGS=['-DPLATIDX='+str(PLATIDX),'-DOCLV2','-DCL_TARGET_OPENCL_VERSION=120','-D'+dev,'-DKERNEL='+kernel,'-DWIDTH='+width,'-DREF='+ref,vflag, memreadflag,devinfoflag,nrunsflag]
#if commands.getoutput("uname") == "Darwin":
#    DEVFLAGS+=['-DOSX']
    


sources=Split("""
../DeviceInfo.cc
matacc.cc
""");

Help(help)
env = Environment( CXX = 'g++', CXXFLAGS = ['-Wall','-g',DEVFLAGS])
env['LIBS'] = ['OpenCL']
prog=env.Program('matacc'+kernel,sources,CPPPATH=[NVSDKCUDA_ROOT+'/include'])
env.Depends(prog,['matacc.cl'])

