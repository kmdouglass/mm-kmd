% Initialize the acquisition environment for scripted acquisitions on PC2.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

% Constants
MM_DIR            = 'C:\Program Files\Micro-Manager-1.4.23_20160426';
PCID              = 'PC2'; % ID of this computer
PRIMARY_PCID      = 'PC1'; % ID of the primary acquisition computer

% Global Variables
global g_nameMap;
global g_gui;
global g_mmc;
global g_acq;

 % Struct of incoming variables from other PC
global g_comBuffer; g_comBuffer = [];

%% Initialize the script engine, including device names
% Sets globals g_engineInitialized, g_stepFields, and g_nameMap
utils.initHelper();

%% Launch Micro-Manager GUI
% StartMMStudio.m is included with Micro-Manager Windows installs
path(MM_DIR, path);
g_gui = StartMMStudio(MM_DIR);
g_mmc = g_gui.getCore;
g_acq = g_gui.getAcquisitionEngine;