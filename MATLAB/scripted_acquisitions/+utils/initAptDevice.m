% Launches a Thorlabs APT device using MATLAB's ActiveX controls.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function [devHandle, figHandle] = launchAptDevice(                      ...
    progid, serialNumber, varargin)
% launchAptDevice Launches a Thorlabs APT device.
%
% Parameters
% ----------
% progid       : char array
%   The programmatic identifier for the device.
% serialNumber : uint32
%   The device's serial number; usually found on the device itself prefixed
%   by "S/N".
%
% Optional Name/Value Parameters
% ------------------------------
% initFunc : char array
%   A string representing a device function that is called to initialize
%   the device. For example, a filter wheel should be homed before use, so
%   the function that homes the device can be passed here. For the Thorlabs
%   BSC 201 controller, pass 'MoveHome(0,0)' to home the device.
%   Default: ''
% figName  : char array
%   The name of the figure window holding the control.
%   Default: 'APT Device'
% fpos     : numeric array
%   [x, y, width, height] of the figure window.
%   Default: get(0, 'DefaultFigurePosition') for x, y; 650, 450 for width,
%            height

%% Parse the input arguments
% Default figure position and size
fpos    = get(0,'DefaultFigurePosition');
fpos(3) = 650; % Width
fpos(4) = 450; % Height

p = inputParser;
addRequired(p, 'progid', @ischar);
addRequired(p, 'serialNumber', @isnumeric);
addParameter(p, 'initFunc', '');
addParameter(p, 'figName', 'APT Device');
addParameter(p, 'fpos', fpos);
parse(p, progid, serialNumber, varargin{:});

%% Create the figure container to hold the control
figHandle = figure('Position', p.Results.fpos,...
                   'Menu', 'None',  ...
                   'Name', p.Results.figName);

%% Create and start the ActiveX control
devHandle= actxcontrol(p.Results.progid, [20 20 600 400], figHandle);
devHandle.StartCtrl;
set(devHandle,'HWSerialNum', p.Results.serialNumber);
devHandle.Identify;
pause(2); % Wait for the GUI to load up;

%% Launch the optional initialization function
if p.Results.initFunc
    eval(['devHandle.' p.Results.initFunc]);
end