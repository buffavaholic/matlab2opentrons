% Startup file for MATLAB

MainSUfolder = 'C:\Users\Scope4\Documents\MATLAB';
%% Liquid Handler 

% OT class location
OTloc = 'C:\Users\Scope4\Documents\MATLAB\Mat2OT';

% Add OT class to file path
addpath(OTloc)

% Add utilities to path
addpath(genpath([OTloc,'\Util']))

% % Move to OT files folder
% cd([OTloc,'\Util\OTfiles'])
% 
% % Start OpenTrons
% OT = OpenTrons(0);

% Return to Main Folder
cd(MainSUfolder);

%% Clear variables

clear all;