% Sets the power of the Coherent Sapphire 488nm laser.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = set_power(params)
% Sets the power of the Coherent Sapphire 488nm laser.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name  : string
%   The name of the device in the global handles structure.
% power : double
%   The power set point of the laser.
%
% Returns
% -------
% handle : function handle
%   A pointer to a function that executes the desired hardware commands.

global g_gui;
global g_mmc;
global g_acq;
global g_h;

%% Unpack the acquisition parameters from params struct
try
    name  = params.name;
    power = params.power;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['Missing field in params struct for the '
               'Sapphire 488 laser.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: ' name '\n' ...
              'Command: Set power']));
    else
        rethrow(ME);
    end
end

if (power < 5.5) || (power > 50)
    error(['Sapphire 488 laser power cannot be less than 5 mW '
           'or greater than 50 mW.']);
end

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_mmc.setProperty(name, 'PowerSetpoint', power);
    end

handle = @() deviceControl();
end