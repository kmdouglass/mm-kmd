% Initialize the acquisition environment for scripted acquisitions.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

%% Constants
MM_DIR            = 'C:\Program Files\Micro-Manager-1.4.23_20160426';
PROGID_FWHEEL     = 'MGMOTOR.MGMotorCtrl.1';
PROGID_SHUTTER    = 'MGMOTOR.MGMotorCtrl.1';
SERIALNUM_FWHEEL  = 40866523; % Serial number of the filter wheel
SERIALNUM_SHUTTER = 85855448; % Serial number of the shutter

%% Setup Thorlabs APT devices
% TODO: Off-load this boiler plate to another .m file
% Load ActiveX control for the filter wheel
fpos    = get(0,'DefaultFigurePosition');
fpos(3) = 650; % Figure window width
fpos(4) = 450; % Height
 
f_fwheel = figure('Position', fpos,...
                  'Menu','None',...
                  'Name','APT - Filter Wheel');

h_fwheel = actxcontrol(PROGID_FWHEEL, [20 20 600 400], f_fwheel);
h_fwheel.StartCtrl;
set(h_fwheel,'HWSerialNum', SERIALNUM_FWHEEL);
h_fwheel.Identify;
pause(2);               % Wait for the GUI to load up;
h_fwheel.MoveHome(0,0); % Home stage; 0,0 -> channelID, move immediately

% Load ActiveX control for the shutter
fpos(2) = fpos(2) - fpos(4); % Shift location of the figure window down
f_shutter = figure('Position', fpos,...
                   'Menu','None',...
                   'Name','APT - Shutter');

h_shutter = actxcontrol(PROGID_FWHEEL, [20 20 600 400], f_shutter);
h_shutter.StartCtrl;
set(h_shutter,'HWSerialNum', SERIALNUM_SHUTTER);
h_shutter.Identify;
pause(2);               % Wait for the GUI to load up;            

clear fpos              % Clean-up

%% Launch Micro-Manager GUI

% StartMMStudio.m is included with Micro-Manager Windows installs
path(MM_DIR, path);
gui = StartMMStudio(MM_DIR);
mmc = gui.getCore;
acq = gui.getAcquisitionEngine;