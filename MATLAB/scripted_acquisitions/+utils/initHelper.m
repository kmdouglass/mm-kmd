% Helps initialize the engine that runs a scripted acquisition.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function initHelper()
stepFactoryInit()

end

function stepFactoryInit()
global g_nameMap;

%% Define the mapping between custom device names and hardware names
% These are applied to devices that have a variable referring to a MATLAB
% handle or a string-based name in another software environment, such as
% the names of fields inside the g_h struct array or device names in
% Micro-Manager.
customNames = {'Filter Wheel',       ... 1
               'Shutter',            ... 2
               'ND Filter',          ... 3
               'Camera',             ... 4
               'MPB Laser 642'       ... 5
               'Acquisition Engine', ... 6
               'pgFocus',            ... 7
               'MPB Laser 750',      ... 8
               'Sapphire Laser 488'};
hwNames     = {'fwheel',                ... 1
               'shutter',               ... 2
               'Arduino-Switch',        ... 3
               'Prime',                 ... 4
               'COM10',                 ... 5
               'acq',                   ... 6
               'pgFocus-Stabilization', ... 7
               'COM12',                 ... 8
               'Laser: Sapphire 488nm'};
g_nameMap   = containers.Map(customNames, hwNames);

end