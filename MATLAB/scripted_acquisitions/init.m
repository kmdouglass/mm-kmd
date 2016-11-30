% Initialize the acquisition environment for scripted acquisitions.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

% Constants
MM_DIR            = 'C:\Program Files\Micro-Manager-1.4.23_20160426';
PROGID_FWHEEL     = 'MGMOTOR.MGMotorCtrl.1';
PROGID_SHUTTER    = 'MGMOTOR.MGMotorCtrl.1';
SERIALNUM_FWHEEL  = 40866523; % Serial number of the filter wheel
SERIALNUM_SHUTTER = 85855448; % Serial number of the shutter

% Variables
global g_h; g_h = struct(); % Device handles
global g_f; g_f = struct(); % Figure handles
global g_nameMap;
global g_engineInitialized;
global g_stepFields;

%% Initialize the script engine, including device names
% Sets globals g_engineInitialized, g_stepFields, and g_nameMap
utils.initScriptEngine()

%% Setup Thorlabs APT devices
% Load ActiveX control for the filter wheel
fpos    = get(0,'DefaultFigurePosition');
fpos(3) = 650; % Figure window width
fpos(4) = 450; % Height

% TODO: Assign field names using the names in g_nameMap

% Load ActiveX control for the filter wheel
% 'initFunc', 'MoveHome(0,0)' homes the filter wheel during initialization.
fWheelName = g_nameMap('Filter Wheel');
[g_h.(fWheelName), g_f.(fWheelName)] = utils.initAptDevice(...
    PROGID_FWHEEL, SERIALNUM_FWHEEL,         ...
    'figName','Filter Wheel', 'initFunc', 'MoveHome(0,0)');

% Shifts the shutter controller window downward
fpos(2) = fpos(2) - fpos(4);

% Load ActiveX control for the shutter
shutterName = g_nameMap('Shutter');
[g_h.(shutterName), g_f.(shutterName)] = utils.initAptDevice(...
    PROGID_SHUTTER, SERIALNUM_SHUTTER,         ...
    'figName', 'Shutter', 'fpos', fpos);

clear fpos; % Clean-up

%% Launch Micro-Manager GUI
% StartMMStudio.m is included with Micro-Manager Windows installs
path(MM_DIR, path);
gui = StartMMStudio(MM_DIR);
mmc = gui.getCore;
acq = gui.getAcquisitionEngine;
