% Get current folder

curDir = pwd;
cd('LiquidHandler/OTfiles')
%% Start up script for connecting to the robot

%import the robot directly
% import py.opentrons.robot;
robot = py.opentrons.robot;
% Add well location function
mod = py.importlib.import_module('getLoc');
py.importlib.reload(mod);

robot.reset();

pause(3);
%return to main folder
cd(curDir);

%Open up OT gui

OTgui(robot);
% %% Connect to the robot
% 
% conn = robot.connect('COM3');
% 
% if conn == 1
%     robot.home()
% else
%     error('Could not connect to robot')    
% end



