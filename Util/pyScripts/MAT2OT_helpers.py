import threading
import opentrons
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

def getVersion():
    
    return opentrons.__version__
    