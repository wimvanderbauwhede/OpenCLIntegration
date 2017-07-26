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

    global opts,dev,plat,multi,kernel,kopts,kernel_opts,useF,useDyn, mcModel, OPENCL_DIR, useOclWrapper, sel

    OPENCL_DIR=os.environ['OPENCL_DIR']
    
    envsh = open(OPENCL_DIR+'/OpenCLIntegration/ocl_env.sh', "r")
    envs =envsh.read()
    help = """
    Options:
     lib=0|1 [1] build an OclWrapper library
    *dyn=0|1 [0] build a dynamic Library             OclBuilder.useDyn
    *mcm=s|m|l [s] mcmodel flag for gcc/gfortran
    *plat=AMD|NVIDIA|Intel|Altera|Xilinx|MIC [NVIDIA]
    *dev=CPU|GPU|ACC|FPGA [GPU] device
     gpu=-1|0|1 [-1, means automatic selection]
     acc=-1|0|1 [-1, means automatic selection]
     O=[gcc -O flag] [3]
     F=0|1 [0] use the functional (non-OO) interface OclBuilder.useF
     V=1.1|1.2 [1.2] OpenCL C++ API version
     info=0|1                                        (DEVINFO, PLATINFO)
    *oclwrapper=0|1 [1] use the OclWrapper API       OclBuilder.useOclWrapper

    The following flags can be used to define macros in your code, they are passed on to the OpenCL kernel as well.
     kernel=<number> [1]                             KERNEL   
     sel=<number> [1] generic selection flag         SELECT
     w=<number> [1024] width, e.g. for matrix        WIDTH 
     wx,wy,wz=<number> [128,128,64] x/y/z dimensions WX,WY,WZ
     nth=<number> [1] number of threads per core     NTH
     nunits=<number> [1] number of compute units         NUNITS
     ngroups=<number> [0] number of workgroups         NGROUPS
     order=<number> [1] loop order                     LOOP_ORDER 
     ref=0|1|2 [1]     reference 2=ref only          REF
     v=0|1 [1]         verbose                       VERBOSE 
     warn=0|1 [1]      warnings                      WARNINGS
     mode=0|1|2   COPY|COPY+ALLOC|USE 
     dbg=0|1 [0]                                     OCLDBG
     nruns= [1]                                      NRUNS
     multi=0|1 [0]   Support multiple devices in threads, for use with Fortran/GMCF     OCL_MULTIPLE_DEVICES
    *kopts=<string> kernel options, can only be a single alphanumeric string 
                    if you need complex options, put them in the Scons script
                    For example, to add a path for kernel includes:
                    OclBuilder.kopts='-I/abs/path/to/includes'

    D=[comma-sep list of host-only macros, without values]

    The options marked with * can be set as OclBuilder.OPTION=VALUE in the SCons script
    The macros controlled by the other options are listed on the right
    The directory for the OclWrapper can be accessed via OclBuilder.OPENCL_DIR

    The following environment variables must be set (see OPENCL_DIR/OpenCLIntegration/ocl_env.sh):

    """ + envs

   # by default, use the OclWrapper.
    if not 'useOclWrapper' in globals():    
        useOclWrapper = True
 
    if commands.getoutput("uname") == "Darwin":
        OSX=1
        OSFLAG='-DOSX'
    else:
        OSX=0
        OSFLAG='-D__LINUX__'

    opts=Variables()        
    CWD= os.environ['PWD']
    args=sys.argv[1:]
    for arg in args:
        if re.match("(\w+)=(\w+)",arg):
            (k,v)=arg.split('=')
            opts.args[k]=v

    oclwrapper = getOpt('oclwrapper','OclWrapper','1')
    if oclwrapper != '1':
        useOclWrapper = False

    dev=getOpt('dev','Device','GPU')
    plat=getOpt('plat','Platform','NVIDIA')
#    print "PLAT:"+plat
    if OSX==1:
        plat='Apple'
    if plat=='AMD':      
        AMD_SDK_PATH=os.environ['AMDAPPSDKROOT']
    elif plat=='Intel':      
        INTEL_SDK_PATH=os.environ['INTELOCLSDKROOT']
    elif plat=='MIC':      
        INTEL_SDK_PATH=os.environ['INTELOCLSDKROOT']
        dev='ACC'
    elif plat=='Altera':      
        ALTERA_SDK_PATH=os.environ['ALTERAOCLSDKROOT']
        dev='ACC'
    else:   
        if plat != 'Apple':    
            NVIDIA_SDK_PATH=os.environ['NVSDKCUDA_ROOT']
            if os.environ['OPENCL_GPU']!='NVIDIA':
#                print 'No NVIDIA platform, defaulting to AMD CPU'
                if os.environ['OPENCL_CPU']=='AMD':
                    AMD_SDK_PATH=os.environ['AMDAPPSDKROOT']
                    plat='AMD'
                    dev='CPU'
                elif os.environ['OPENCL_ACC']=='Intel':
                    INTEL_SDK_PATH=os.environ['INTELOCLSDKROOT']
                    plat='MIC'
                    dev='ACC'
                elif os.environ['OPENCL_ACC']=='Altera':
                    ALTERA_SDK_PATH=os.environ['ALTERAOCLSDKROOT']
                    plat='Altera'
                    dev='FPGA'
                elif os.environ['OPENCL_ACC']=='Xilinx':
                    XILINX_SDK_PATH=os.environ['SDACCELROOT'] 
                    plat='Xilinx'
                    dev='FPGA'
                elif os.environ['OPENCL_CPU']=='Intel':
                    INTEL_SDK_PATH=os.environ['INTELOCLSDKROOT']
                    plat='Intel'
                    dev='CPU'
                else:
                    print 'No OpenCL-capable GPU found'
                    exit
#        else:
#            print 'NVIDIA'
    env['KERNEL_OPTS']=[]    
    gpu=getOpt('gpu','GPU','-1')
    acc=getOpt('acc','ACC','-1')
    devidxflag='-DDEVIDX=-1'
    if gpu!='-1':
        devidxflag='-DDEVIDX='+gpu
        dev='GPU'    

    if acc!='-1':
        devidxflag='-DDEVIDX='+acc
        dev='ACC'
        
    kernel=getOpt('kernel','KERNEL','1')
    sel=getOpt('sel','SELECT','1')
    nth=getOpt('nth','#threads','1')
    nunits=getOpt('nunits','#compute units','1')
    ngroups=getOpt('ngroups','#workgroups','0')
    loop_order=getOpt('order','loop order','1')

    multi=getOpt('multi','Support multiple devices (Fortran)','0')    
    multimacro='-DOCL_MULTIPLE_DEVICES=1'
    if multi=='0':
        multimacro=''

    if not 'kopts' in globals():
        kopts=getOpt('kopts','OpenCL kernel compilation options. Can only be a single alphanumeric string.','-cl-fast-relaxed-math')
    nruns=getOpt('nruns','Number of runs','1')
    width=getOpt('w','Width','1024')
    wx=getOpt('wx','X-width','128')
    wy=getOpt('wy','Y-width','128')
    wz=getOpt('wz','Z-width','64')
    env.Append(KERNEL_OPTS=['-DKERNEL='+kernel])
    env.Append(KERNEL_OPTS=['-DSELECT='+sel])
    env.Append(KERNEL_OPTS=['-DNTH='+nth])
    env.Append(KERNEL_OPTS=['-DNUNITS='+nunits])
    env.Append(KERNEL_OPTS=['-DWIDTH='+width])
    env.Append(KERNEL_OPTS=['-DWX='+wx])
    env.Append(KERNEL_OPTS=['-DWY='+wy])
    env.Append(KERNEL_OPTS=['-DWZ='+wz])
    env.Append(KERNEL_OPTS=['-DLOOP_ORDER='+loop_order])
    env.Append(KERNEL_OPTS=[multimacro])
    ref=getOpt('ref','Reference','1')
    refflag='-DREF'

    verbose=getOpt('v','Verbose','0')
    vflag='-DVERBOSE'
    if verbose=='0':
        vflag=''

    warnings=getOpt('warn','Warnings','1')
    wflag='-Wall'
    if ('PGCXX' in os.environ and os.environ['CXX'] == os.environ['PGCXX']):
       wflag = ''
    if warnings=='0':
        vflag=''

    version=getOpt('V','Version','1.2') # FIXME! V1.2 is broken on most platforms
    verflag=''
    if version=='1.2':
        verflag='-DOCLV2'

    dbg=getOpt('dbg','Debug','0')    
    dbgflag='-g'
    dbgmacro='-DOCLDBG=1'
    if dbg=='0':
        dbgmacro=''
        dbgflag=''



    useF=getOpt('F','Functional',0)
    if 'useF' in env:
        if env['useF']==1:
            useF='1'

    useDyn=getOpt('dyn','Dynamic Library',0)
    if 'useDyn' in env:
        if env['useDyn']==1:
            useDyn='1'
            
    mcModel=getOpt('mcm','GCC Code Model Flag','s')
            
    optim=getOpt('O','Optimisation','2')
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

    DEVFLAGS=['-DDEV_'+dev,devidxflag]+env['KERNEL_OPTS']+['-DNRUNS='+nruns,'-DNGROUPS='+ngroups,'-DREF='+ref,vflag,verflag, memreadflag,devinfoflag,platinfoflag,multimacro]+defflags
    if plat=='Altera':
        DEVFLAGS+=['-DFPGA']
    if dev=='CPU':
        dbg_dev=dbgmacro+' '        
    else:    
        dbg_dev=''
    kernel_opts='\\"'+kopts+' -DEXT_DEFS '+dbg_dev+(' '.join(env['KERNEL_OPTS']))+'\\"'
    KERNEL_OPTS=['-DKERNEL_OPTS='+kernel_opts+''] 
    if commands.getoutput("uname") == "Darwin":
        DEVFLAGS+=['-DOSX']    
    if useOclWrapper:    
        oclsources=map (lambda s: OPENCL_DIR+'/OpenCLIntegration/'+s, ['Timing.cc','DeviceInfo.cc','PlatformInfo.cc','OclWrapper.cc'])
        env['OCLSOURCES']=oclsources
    if plat=='Altera':
        oclsources+=[OPENCL_DIR+'/OpenCLIntegration/libstdcxx-compatibility.cpp']
    if OSX==1 and 'ROOTSYS' in os.environ:
        print 'Setting CXX to g++-4.2 for CERN ROOT on OS X'
        env['CXX'] = ['g++-4.2'] # FIXME: because any higher g++ results in ERROR: malloc: *** error for object 0x7fff7064c500: pointer being freed was not allocated
    elif 'CXX_COMPILER' in os.environ:
        env['CXX'] = [ os.environ['CXX_COMPILER'] ]
    elif 'CXX' in os.environ:
        env['CXX'] = [ os.environ['CXX'] ]
    if True or plat!='Altera':
        #if ('GCXX' in  os.environ and  os.environ['CXX'] ==  os.environ['GCXX']): # and int(os.environ['GCXX_VERSION'])<480):
        if ('GCXX' in  os.environ and  os.environ['CXX'] ==  os.environ['GCXX'] and int(os.environ['GCXX_VERSION'])<480):
            print('OLD GCXX: '+os.environ['GCXX_VERSION'])
            env.Append(CXXFLAGS = ['-std=c++0x','-m64','-fPIC','-DOLD_CXX',wflag,dbgflag,dbgmacro,optflag]+DEVFLAGS+KERNEL_OPTS) 
        else:
            env.Append(CXXFLAGS = ['-std=c++11',wflag,dbgflag,dbgmacro,optflag]+DEVFLAGS+KERNEL_OPTS) 
    else:    
        env.Append(CXXFLAGS = [wflag,dbgflag,dbgmacro,optflag]+DEVFLAGS+KERNEL_OPTS) 
    env.Append(CFLAGS = [wflag,dbgflag,optflag]+DEVFLAGS+KERNEL_OPTS)     
    env['MACROS'] = DEVFLAGS
    #env.Append(CXXFLAGS = ['-mcmodel=large']

    env.Help(help)
#if useOclWrapper:
#env.Append(CPPPATH=[OPENCL_DIR,OPENCL_DIR+'/OpenCLIntegration'])    
    env.Append(CPPPATH=[OPENCL_DIR+'/OpenCLIntegration'])    
#   else:
#       env.Append(CPPPATH=[OPENCL_DIR])    
    if OSX==1:
        env.Append(FRAMEWORKS=['OpenCL'])
#        if useDyn=='1' and useF=='1':
#            env.Append(LIBPATH=['.'])
#            env.Append(LIBS=['OclWrapper'])
    else:    
        if plat !='Altera':
            env.Append(LIBS=['OpenCL'])
        if plat=='AMD':
            env.Append(CPPPATH=[AMD_SDK_PATH+'/include/', AMD_SDK_PATH+'/include/CL','/usr/include/CL'])
            env.Append(LIBPATH=[AMD_SDK_PATH+'/lib/x86_64'])
        elif plat=='Intel':
            env.Append(CPPPATH=[INTEL_SDK_PATH+'/include/',INTEL_SDK_PATH+'/include/CL'])
            env.Append(LIBPATH=[INTEL_SDK_PATH+'/lib64'])
        elif plat=='MIC':
            env.Append(CPPPATH=[INTEL_SDK_PATH+'/include/'])
            env.Append(LIBPATH=[INTEL_SDK_PATH+'/lib64'])
        elif plat=='Altera':
            env.Append(CPPPATH=map(lambda s: ALTERA_SDK_PATH+s, ['/host/include/','/common/inc','/board/nalla_pcie/include' ]))
            env.Append(LIBPATH=[ALTERA_SDK_PATH+'/host/linux64/lib',ALTERA_SDK_PATH+'/board/nalla_pcie/linux64/lib']) #,ALTERA_SDK_PATH+'/'+os.environ['AOCL_BOARD_PACKAGE_ROOT']+'/linux64/lib'])
            env.Append(LIBS=['alteracl', 'dl', 'acl_emulator_kernel_rt', 'alterahalmmd', 'nalla_pcie_mmd', 'elf', 'rt', 'stdc++'])
            env.Append(CXXFLAGS = ['-fPIC'])
        elif plat=='Xilinx':
#DSA := xilinx:adm-pcie-7v3:1ddr:1.0
#XOCC := $(XILINX_SDACCEL)/bin/xocc
            XILINX_OPENCL = XILINX_SDK_PATH
            OPENCL_INC = XILINX_OPENCL+'/runtime/include/1_2'
            OPENCL_LIB = XILINX_OPENCL+'/runtime/lib/x86_64'
#CLFLAGS := -g --xdevice $(DSA)
#export XCL_PLATFORM=xilinx_adm-pcie-7v3_1ddr_1_0   
            env.Append(CPPPATH=map(lambda s: XILINX_SDK_PATH+s, ['/runtime/include/1_2'])) 
            env.Append(LIBPATH=[XILINX_SDK_PATH+'/runtime/lib/x86_64']) 
            #env.Append(LIBS=['xilinxcl', 'dl', 'acl_emulator_kernel_rt', 'xilinxhalmmd', 'FIXMEnalla_pcie_mmd', 'elf', 'rt', 'stdc++'])
            #env.Append(CXXFLAGS = ['-fPIC'])
        else: # means NVIDIA
            env.Append(CPPPATH=[NVIDIA_SDK_PATH+'/include',NVIDIA_SDK_PATH+'/OpenCL/common/inc' ,NVIDIA_SDK_PATH+'/OpenCL/common/inc/CL'])

    if useF=='1':
        if 'FORTRAN_COMPILER' in os.environ:
            env['FORTRAN']=os.environ['FORTRAN_COMPILER']
            env['F95']=os.environ['FORTRAN_COMPILER']
        if 'FC' in os.environ:
            env['FORTRAN']=os.environ['FC']
            env['F95']=os.environ['FC']
        if ('GFORTRAN' in os.environ and env['FORTRAN'] == os.environ['GFORTRAN']) :
            env['FORTRANFLAGS']=env['CFLAGS']
            if OSX==1:
                env['LINKFLAGS']=['-Wl,-stack_size,0x40000000'] # Give OS X 1G stack
            env.Append(FORTRANFLAGS=['-Wno-aliasing','-Wno-unused','-Wno-unused-dummy-argument','-cpp','-m64','-ffree-form','-ffree-line-length-0','-fconvert=big-endian'])
            #env.Append(FORTRANFLAGS=['-mcmodel=large'])
#env['F95FLAGS']=['-Wno-aliasing','-Wno-unused','-Wno-unused-dummy-argument','-cpp','-m64','-mcmodel=medium','-ffree-form','-ffree-line-length-0','-fconvert=big-endian']
            env['F95FLAGS']=['-Wno-aliasing','-Wno-unused','-Wno-unused-dummy-argument','-cpp','-m64','-ffree-form','-ffree-line-length-0','-fconvert=big-endian']
            env.Append(F95FLAGS=env['CFLAGS'])
        else :
            env['CFLAGS'].pop(0)
            env['CFLAGS'].pop(0)
            env['CFLAGS'].pop(0)
            env['FORTRANFLAGS']=env['CFLAGS']
            if ('PGFORTRAN' in os.environ and env['FORTRAN'] == os.environ['PGFORTRAN']) : 
                env.Append(FORTRANFLAGS=['-cpp','-m64','-fast','-Mfree','-Mipa=fast'])
                env['F95FLAGS']=env['FORTRANFLAGS']
            else:
                print('Unknown compiler, no options specified.')
        if useOclWrapper:
            if useDyn=='1':
                flib = env.SharedLibrary('OclWrapperF', [oclsources,OPENCL_DIR+'/OpenCLIntegration/OclWrapperF.cc'])
            else:    
                flib = env.Library('OclWrapperF', [oclsources,OPENCL_DIR+'/OpenCLIntegration/OclWrapperF.cc'])
            fflib = env.Object('oclWrapper.o',OPENCL_DIR+'/OpenCLIntegration/oclWrapper.f95')
#    else:            
    if useOclWrapper:
        if useDyn=='1':
            lib = env.Library('OclWrapper',oclsources)
        else:        
            lib = env.Library('OclWrapper',oclsources)        
        env.Append(LIBPATH=['.',OPENCL_DIR+'/OpenCLIntegration/'])
    else:        
        env.Append(LIBPATH=['.'])

    if useOclWrapper:
        if useF:
            #env.Append(LIBS=['OclWrapperF','stdc++'])
            env.Append(LIBS=['stdc++'])
            env.Install(OPENCL_DIR+'/OpenCLIntegration/lib', flib)
            env.Alias('installf',OPENCL_DIR+'/OpenCLIntegration/lib', flib)
#    else:
        env.Append(LIBS=['OclWrapper'])
        env.Install(OPENCL_DIR+'/OpenCLIntegration/lib', lib)
        env.Alias('install',OPENCL_DIR+'/OpenCLIntegration/lib', lib)
    return env

def build(appname,sources):
    global opts, OPENCL_DIR
    env = initOcl()
    env.Program(appname+'_'+dev+'_'+plat+'_'+kernel,sources)

def buildF(env,appname,sources):
    global opts, OPENCL_DIR
#    VariantDir('.',OPENCL_DIR+'/OpenCLIntegration/')
    env.Program(appname+'_'+dev+'_'+plat+'_'+kernel,sources+['oclWrapper.o'])


