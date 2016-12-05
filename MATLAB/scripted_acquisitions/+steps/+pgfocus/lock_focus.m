% Locks and unlocks the pgFocus.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = lock_focus(params)
% Locks and unlocks the pgFocus.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name   : string
%   The name of the device in the global handles structure.
% locked : bool
%   Should the pgFocus be locked or unlocked?

global g_gui;
global g_mmc;
global g_acq;

%% Unpack the acquisition parameters from params struct
try
    name = params.name;
    lock = params.lock;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['The params struct for locking/unlocking '...
               'the pgFocus is missing a field.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: pgFocus\n' ...
              'Command: Lock focus']));
    else
        rethrow(ME);
    end
end

if lock
    command = 'Lock Focus';
else
    command = 'Unlock Focus';
end

%% Device control functions
    function deviceControl()
        g_mmc.setProperty(name, 'Focus Mode', command);
    end

handle = @() deviceControl();
end