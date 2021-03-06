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

% Local Variables (change these depending on the machine)
PCID           = 'PC1'; % This PC
SECONDARY_PCID = 'PC2'; % The other PC to communicate with

% Global Variables
global g_h; g_h = struct(); % Device handles
global g_f; g_f = struct(); % Figure handles
global g_nameMap;
global g_gui;
global g_mmc;
global g_acq;

 % Struct of incoming variables from other PC
global g_comBuffer; g_comBuffer = [];

%% Initialize the script engine, including device names
% Sets globals g_engineInitialized, g_stepFields, and g_nameMap
utils.initHelper();

%% Setup Thorlabs APT devices
% Load ActiveX control for the filter wheel
fpos    = get(0,'DefaultFigurePosition');
fpos(3) = 650; % Figure window width
fpos(4) = 450; % Height

% Load ActiveX control for the filter wheel
% 'initFunc', 'MoveHome(0,0)' homes the filter wheel during initialization.
fWheelName = g_nameMap('Filter Wheel');
[g_h.(fWheelName), g_f.(fWheelName)] = utils.initAptDevice(...
    PROGID_FWHEEL, SERIALNUM_FWHEEL,         ...
    'figName','Filter Wheel', 'initFunc', 'MoveHome(0,0)');

% Shifts the shutter controller window downward
fpos(2) = fpos(2) - fpos(4);

% Load ActiveX control for the shutter
% 'SC_SetOperatingMode' sets the shutter mode to manual.
shutterName = g_nameMap('Shutter');
[g_h.(shutterName), g_f.(shutterName)] = utils.initAptDevice(...
    PROGID_SHUTTER, SERIALNUM_SHUTTER,         ...
    'figName', 'Shutter', 'fpos', fpos,        ...
    'initFunc', 'SC_SetOperatingMode(0,1)');

clear fpos; % Clean-up

%% Launch Micro-Manager GUI
% StartMMStudio.m is included with Micro-Manager Windows installs
path(MM_DIR, path);
g_gui = StartMMStudio(MM_DIR);
g_mmc = g_gui.getCore;
g_acq = g_gui.getAcquisitionEngine;