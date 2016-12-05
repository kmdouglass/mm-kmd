% Closes the shutter.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = close_shutter(params)
% Closes the shutter.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% rootName  : char array
%   The root directory containing the individual acquisition folders.
% dirName   : char array
%   The name of the directory where the actual data is stored.
% numFrames : uint
%   The number of frames in the time-series acquisition.
% interval  : uint
%   The time between frames (milliseconds).

global g_gui;
global g_mmc;
global g_acq;
global g_h;

%% Unpack the acquisition parameters from params struct
try
    name = params.name;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['The params struct for closing '...
               'the shutter is missing a field.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Shutter\n' ...
              'Command: Close shutter']));
    else
        rethrow(ME);
    end
end

%% Device control functions
    function deviceControl()
        g_h.(name).SC_Disable(0);
    end

handle = @() deviceControl();
end