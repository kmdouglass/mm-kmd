% Moves the filter wheel.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = move_filter(params)
% Moves the filter wheel.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% filterWavelength : uint
%   Excitation wavelength corresponding to the desired filter to use.
% name             : string
%   The name of the device in the global handles structure.

global g_gui;
global g_mmc;
global g_acq;
global g_h;

%% Unpack the acquisition parameters from params struct
try
    filterWavelength = params.filterWavelength;
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
if filterWavelength == 647
    fPos = 0;   % Physical position of 647 filter
elseif filterWavelength == 488
    fPos = 120; % Physical position of 488 filter
elseif filterWavelength == 750
    fPos = 240; % Physical position of 750 filter
end

    function deviceControl()
        % Type the hardware and software instructions here
        g_h.(name).SetAbsMovePos(0, fPos);
        g_h.(name).MoveAbsolute(0, 0);
    end

handle = @() deviceControl();
end