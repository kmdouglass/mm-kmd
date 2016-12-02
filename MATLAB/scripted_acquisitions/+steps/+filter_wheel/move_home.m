% Homes the filter wheel.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = home_filter(params)
% Homes the filter wheel.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name             : string
%   The name of the device in the global handles structure.

global g_gui;
global g_mmc;
global g_acq;
global g_h;

%% Unpack the acquisition parameters from params struct
try
    name             = params.name;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['Missing field in params struct for the filter wheel.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Filter wheel\n' ...
              'Command: Move filter']));
    else
        rethrow(ME);
    end
end

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_h.(name).MoveHome(0,0);
    end

handle = @() deviceControl();
end