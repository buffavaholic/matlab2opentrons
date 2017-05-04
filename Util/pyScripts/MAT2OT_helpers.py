import threading

from opentrons.util.vector import Vector

def get_well(plate,index):
    return plate[index]

def get_calibration_file_path(calib):
    return calib._get_calibration_file_path()

def update_vect_values(VectVal,**kwds):
    return VectVal._replace(kwds)



def xyzToVect(x=None, y=None, z=None):
    return Vector(x, y, z)


def runDaemonRun(robo):

    def OTdaemon(robotIn):
        #print('InsideDaemon')
        robotIn.run()
        #print('AfterHome')

    d = threading.Thread(name='otDaemon', target=OTdaemon, args=(robo,))
    #d.setDaemon(True)

    d.start()

    return d

def doHalt(robo):

    robo._driver.halt()
    return 1

def runDaemonMethod(objIn,methIn,*argsIn,**kwargsIn):
    
    def MethDaemon(obj,meth,*args,**kwargs):
        #print('InsideMethDaemon')
        getattr(obj, meth)(*args,**kwargs)
        #print('AfterMethDaemon')

    d = threading.Thread(name='methDaemon', target=MethDaemon, args=(objIn,methIn,*argsIn,),kwargs = kwargsIn)

    d.start()

    return d

def runDaemonMethodKW(objIn,methIn,**kwargsIn):
    
    #print(**kwargsIn)
    #type(kwargsIn)
    #type(**kwargsIn)
    def MethDaemonKW(obj,meth,**kwargs):
        print('InsideMethDaemon')
        #print(meth)
        #print(**kwargs)
        getattr(obj, meth)(**kwargs)
        print('AfterMethDaemon')

    d = threading.Thread(name='methDaemon', target=MethDaemonKW, args=(objIn,methIn,),kwargs = kwargsIn)
    #d = MyThreadWithArgs(name='methDaemon', target=MethDaemonKW, args=(objIn,methIn,),kwargs = kwargsIn)
    d.start()

    return d

def runDaemonMethodGen(objIn,methIn,*argsIn,**kwargsIn):
    
    #print(**kwargsIn)
    #type(kwargsIn)
    #type(**kwargsIn)
    def MethDaemonGen(obj,meth,*args,**kwargs):
        print('InsideMethDaemon')
        #print(meth)
        #print(**kwargs)
        getattr(obj, meth)(*args,**kwargs)
        print('AfterMethDaemon')

    d = threading.Thread(name='methDaemon', target=MethDaemonGen, args=(objIn,methIn,*argsIn,),kwargs = kwargsIn)
    #d = MyThreadWithArgs(name='methDaemon', target=MethDaemonKW, args=(objIn,methIn,),kwargs = kwargsIn)
    d.start()

    return d

def testGetattr(obj,meth,**kwargs):
    
    d = getattr(obj,meth)(**kwargs)

    return d

class MyThreadWithArgs(threading.Thread):

    def __init__(self, group=None, target=None, name=None,
                 args=(), kwargs=None, verbose=None):
        threading.Thread.__init__(self, group=group, target=target, name=name,
                                  verbose=verbose)
        self.args = args
        self.kwargs = kwargs
        return

def MethDaemonKW2(obj,meth,**kwargs):

    print('InsideMethDaemon')
    #print(meth)
    #print(**kwargs)
    d = getattr(obj, meth)(**kwargs)
    print('AfterMethDaemon')

    return d
    