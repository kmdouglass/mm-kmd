% Initializes the engine that runs a scripted acquisition.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function initScriptEngine()
stepFactoryInit()

% If all initialization routines succeed, set this flag to true.
global g_engineInitialized;
g_engineInitialized = true;
end

function stepFactoryInit()
global g_stepFields;
global g_nameMap;

%% Define the fields of a step struct
g_stepFields = {'cmd', 'pauseBefore', 'pauseAfter'};

%% Define the mapping between custom device names and hardware names
% These are applied to devices that have a variable referring to a MATLAB
% handle or a string-based name in another software environment, such as
% the names of fields inside the g_h struct array or device names in
% Micro-Manager.
customNames = {'Filter Wheel',   ... 1
               'Shutter',        ... 2
               'ND Filter',      ... 3
               'Camera',         ... 4
               'MPB Laser 642'};
hwNames     = {'fwheel',         ... 1
               'shutter',        ... 2
               'Arduino-Switch', ... 3
               'Prime',          ... 4
               'COM10'};
g_nameMap   = containers.Map(customNames, hwNames);

end