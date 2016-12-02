% Sets the camera's exposure time.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = set_exposure(params)
% Sets the camera's exposure time.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% expTime : uint
%   Exposure time in milliseconds.

global g_gui
global g_mmc
global g_acq

%% Unpack the acquisition parameters from params struct
try
    expTime = params.expTime;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['Missing field in params struct for the exposure time.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Camera\n' ...
              'Command: Set exposure']));
    else
        rethrow(ME);
    end
end

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_gui.setExposure(expTime);
    end

handle = @() deviceControl();
end