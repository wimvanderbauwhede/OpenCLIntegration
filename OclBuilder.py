#
# SCons build script for building OpenCL applications using OclWrapper
#
# (c) 2011 Wim Vanderbauwhede <wim.vanderbauwhede@gmail.com>
#

import os
import re
import commands
import sys
import os.path
from SCons.Variables import Variables
from SCons.Environment import Environment
opts=''

def getOpt(optname,desc,default):

    global opts
    opts.Add(optname,desc,default)
    optionl = filter (lambda x: x.key==optname,opts.options)
    if optionl:
        option=optionl[0]
        if opts.args.has_key(optname) and opts.args[optname]!=option.default:
            return opts.args[option.key]
        else: 
            return option.default
    else:
        print "No such option: "+optname
    
def initOcl(*envt):
    if envt==():
        env=Environment()
    else:
        env=envt[0]

    global opts,dev,plat,kernel,useF,useDyn, OPENCL_DIR

    help = """
    Options:
    lib=0|1 [1] build an OclWrapper library
    plat=AMD|NVIDIA|Intel [NVIDIA]
    dev=CPU|GPU [GPU] device
    kernel=<number> [1]   
    sel=<number> [1] generic selection flag SELECT
    w=<number> [1024]   matrix width
    nth=<number> [1] number of threads per core
    kopts=<string> kernel options ['-cl-fast-relaxed-math']
    ref=0|1|2 [1]     reference 2=ref only
    v=0|1 [1]         verbose
    mode=0|1|2   COPY|COPY+ALLOC|USE 
    info=0|1
    gpu=-1|0|1 [-1, means automatic selection]
    dbg=0|1 [0]
    O=[gcc -O flag] [3]
    nruns= [1]
    D=[comma-sep list of macros]
    F=0|1 [0] use the functional (non-OO) interface
    V=1|2 [1]
    """
    
    if commands.getoutput("uname") == "Darwin":
        OSX=1
        OSFLAG='-DOSX'
    else:
        OSX=0
        OSFLAG='-D__LINUX__'

    OPENCL_DIR=os.environ['OPENCL_DIR']
    opts=Variables()        

    args=sys.argv[1:]
    for arg in args:
        if re.match("(\w+)=(\w+)",arg):
            (k,v)=arg.split('=')
            opts.args[k]=v
    dev=getOpt('dev','Device','GPU')
    plat=getOpt('plat','Platform','NVIDIA')
    if OSX==1:
        plat='Apple'
    if plat=='AMD':      
        AMD_SDK_PATH=os.environ['AMDAPPSDKROOT']
    elif plat=='Intel':      
        INTEL_SDK_PATH=os.environ['INTELOCLSDKROOT']
    else:   
        if plat != 'Apple':    
            NVIDIA_SDK_PATH=os.environ['NVSDKCUDA_ROOT']
            if os.environ['OPENCL_GPU']!='NVIDIA':
                print 'No NVIDIA platform, defaulting to AMD CPU'
                if os.environ['OPENCL_CPU']=='AMD':
                    AMD_SDK_PATH=os.environ['AMDAPPSDKROOT']
                    plat='AMD'
                elif os.environ['OPENCL_CPU']=='Intel':
                    INTEL_SDK_PATH=os.environ['INTELOCLSDKROOT']
                    plat='Intel'
                else:
                    print 'No OpenCL-capable GPU found'
                    exit
                dev='CPU'
#        else:
#            print 'NVIDIA'
    env['KERNEL_OPTS']=[]    
    gpu=getOpt('gpu','GPU','-1')
    devidxflag='-DDEVIDX='+gpu
    if gpu!='-1':
        dev='GPU'
        
    kernel=getOpt('kernel','KERNEL','1')
    sel=getOpt('sel','SELECT','1')
    nth=getOpt('nth','#threads','1')
    kopts=getOpt('kopts','OpenCL kernel compilation options','-cl-fast-relaxed-math')
    nruns=getOpt('nruns','Number of runs','1')
    width=getOpt('w','Width','1024')
    env.Append(KERNEL_OPTS=['-DKERNEL='+kernel])
    env.Append(KERNEL_OPTS=['-DSELECT='+sel])
    env.Append(KERNEL_OPTS=['-DNTH='+nth])
    env.Append(KERNEL_OPTS=['-DWIDTH='+width])
    ref=getOpt('ref','Reference','1')
    refflag='-DREF'

    verbose=getOpt('v','Verbose','0')
    vflag='-DVERBOSE'
    if verbose=='0':
        vflag=''

    version=getOpt('V','Version','1')
    verflag=''
    if version=='2':
        verflag='-DOCLV2'

    dbg=getOpt('dbg','Debug','0')    
    dbgflag='-g'
    if dbg=='0':
        dbgflag=''

    useF=getOpt('F','Functional',0)
    if 'useF' in env:
        if env['useF']==1:
            useF='1'

    useDyn=getOpt('dyn','Dynamic Library',0)
    if 'useDyn' in env:
        if env['useDyn']==1:
            useDyn='1'
            
    optim=getOpt('O','Optimisation','3')
    optflag='-O'+optim
    mode=getOpt('mode','Mode','1')
    memreadflag='-DMRMODE='+mode
    devinfo=getOpt('info','DeviceInfo','0')
    devinfoflag=''
    platinfoflag=''
    if devinfo=='1':
        devinfoflag='-DDEVINFO'
        platinfoflag='-DPLATINFO'
        
    defs=getOpt('D','Defines',None)
    defflags=[]
    if defs!=None:
        deflist=defs.split(',')
        defflags=map (lambda s: '-D'+s, deflist)   

    DEVFLAGS=['-D'+dev,devidxflag]+env['KERNEL_OPTS']+['-DNRUNS='+nruns,'-DREF='+ref,vflag,verflag, memreadflag,devinfoflag,platinfoflag]+defflags
    kernel_opts='\\"'+kopts+' '+(' '.join(env['KERNEL_OPTS']))+'\\"'
    KERNEL_OPTS=['-DKERNEL_OPTS='+kernel_opts+''] 
    if commands.getoutput("uname") == "Darwin":
        DEVFLAGS+=['-DOSX']    
    oclsources=map (lambda s: OPENCL_DIR+'/OpenCLIntegration/'+s, ['Timing.cc','DeviceInfo.cc','PlatformInfo.cc','OclWrapper.cc'])
    env['OCLSOURCES']=oclsources
    if OSX==1 and 'ROOTSYS' in os.environ:
        env['CXX'] = ['g++-4.2'] # FIXME: because any higher g++ results in ERROR: malloc: *** error for object 0x7fff7064c500: pointer being freed was not allocated
    env.Append(CXXFLAGS = ['-std=c++0x','-Wall',dbgflag,optflag,DEVFLAGS,KERNEL_OPTS]) 
    env.Append(CFLAGS = ['-Wall',dbgflag,optflag,DEVFLAGS,KERNEL_OPTS])     
    env.Help(help)

    env.Append(CPPPATH=[OPENCL_DIR,OPENCL_DIR+'/OpenCLIntegration'])    
    if OSX==1:
        env.Append(FRAMEWORKS=['OpenCL'])
#        if useDyn=='1' and useF=='1':
#            env.Append(LIBPATH=['.'])
#            env.Append(LIBS=['OclWrapper'])
    else:    
        env.Append(LIBS=['OpenCL'])
        if plat=='AMD':
            env.Append(CPPPATH=[AMD_SDK_PATH+'/include/', AMD_SDK_PATH+'/include/CL','/usr/include/CL'])
            env.Append(LIBPATH=[AMD_SDK_PATH+'/lib/x86_64'])
        elif plat=='Intel':
            env.Append(CPPPATH=[INTEL_SDK_PATH+'/include/CL'])
            env.Append(LIBPATH=[INTEL_SDK_PATH+'/lib64'])
        else: # means NVIDIA
            env.Append(CPPPATH=[NVIDIA_SDK_PATH+'/OpenCL/common/inc' ,NVIDIA_SDK_PATH+'/OpenCL/common/inc/CL'])

    if useF=='1':
        env['FORTRAN']=os.environ['FORTRAN_COMPILER']
        if os.environ['FORTRAN_COMPILER'] == os.environ['GFORTRAN'] :
            env['FORTRANFLAGS']=env['CFLAGS']
            env.Append(FORTRANFLAGS=['-cpp','-m64'])
        else:
            env['FORTRANFLAGS']  = ['-fast','-fastsse','-Mipa=fast','-Minfo','-m64'  ]
        
        if useDyn=='1':
            flib = env.SharedLibrary('OclWrapperF', [oclsources,OPENCL_DIR+'/OpenCLIntegration/OclWrapperF.cc'])
        else:    
            flib = env.Library('OclWrapperF', [oclsources,OPENCL_DIR+'/OpenCLIntegration/OclWrapperF.cc'])
        fflib = env.Object('oclWrapper.o',OPENCL_DIR+'/OpenCLIntegration/oclWrapper.f')
#    else:            
    if useDyn=='1':
            lib = env.Library('OclWrapper',oclsources)
    else:        
            lib = env.Library('OclWrapper',oclsources)
    env.Append(LIBPATH=['.',OPENCL_DIR+'/OpenCLIntegration/'])
    if useF:
        env.Append(LIBS=['OclWrapperF','stdc++'])
        env.Install(OPENCL_DIR+'/OpenCLIntegration/lib', flib)
        env.Alias('installf',OPENCL_DIR+'/OpenCLIntegration/lib', flib)
#    else:
    env.Append(LIBS=['OclWrapper'])
    env.Install(OPENCL_DIR+'/OpenCLIntegration/lib', lib)
    env.Alias('install',OPENCL_DIR+'/OpenCLIntegration/lib', lib)
    return env
#LIBS=['OclWrapperF','OclWrapper','stdc++']
def build(appname,sources):

    global opts, OPENCL_DIR

    env = initOcl()

#    buildLibrary=getOpt('lib','buildLibrary','0')   # specific to 'build'
#    if appname=='' and buildLibrary=='0':           # specific to 'build'
#             buildLibrary='1'                       # specific to 'build'
    
#    oclsources=env['OCLSOURCES']
#    env.Library('OclWrapper',oclsources)
#    if buildLibrary!='1':        
#    env.Append(LIBPATH=['.',OPENCL_DIR+'/OpenCLIntegration/'])
#    env.Append(LIBS=['OclWrapper'])
#    if useF:
#        env.Append(LIBS=['OclWrapperF'])
    env.Program(appname+'_'+dev+'_'+plat+'_'+kernel,sources)

def buildF(env,appname,sources):
    global opts, OPENCL_DIR
#    VariantDir('.',OPENCL_DIR+'/OpenCLIntegration/')
    env.Program(appname+'_'+dev+'_'+plat+'_'+kernel,sources+['oclWrapper.o'])
