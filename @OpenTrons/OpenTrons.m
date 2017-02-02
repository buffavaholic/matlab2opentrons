classdef OpenTrons < handle
    %OpenTrons MATLAB interface with the OpenTrons liquid handling robot. 
    %   Detailed explanation goes here
    
    properties
        %% Directory information
        % Library path
        libPath
        % Class file path
        classPath
        
        %% Robot class
        robot
        
        %% Python helper module
        helper
    end
    
    methods (Static = true)
        function inds = str2inds(posString)
            % must be of the format '[A-Z][1-1000]' with capital letter in
            % front, and integer following
            alph = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            inds(2) = strfind(alph,posString(1));
            inds(1) = str2num(posString(2:end));
        end
        
    end
    
    methods
        
        %% Constructor
        
        function OT = OpenTrons
            % save current directory to move back to later
            curDir = pwd;
            % Get the class path location
            getFileName = mfilename('fullpath');
            OT.classPath = fileparts(getFileName);
            
            cd(OT.classPath)
            cd ..
            % Save the main directory path. 
            OT.libPath = pwd;
            
            % Move into the OTfiles directory so that the calibration,
            % logs, etc are all saved in there for cleanliness
            cd([OT.libPath,'\Util\OTfiles'])
            
            % Initialize the python robot class
            OT.robot = py.opentrons.robot;
            
            % Clear the robot
            OT.robot.reset();
            
            % Pause for 3 seconds to allow the python files to be generated
            pause(3);
            
            cd([OT.libPath,'\Util\pyScripts'])
            
            % Load the helper python file
            OT.helper = py.importlib.import_module('helpers');
            py.importlib.reload(OT.helper);
            
            % Open up the OT GUI
            OTgui(OT);
            
            % Finally, move back to the directory origionally started in
            cd(curDir);
        end
        
        
        
        
    end
    
end

