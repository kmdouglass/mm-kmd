% Turns off the MPB 750 laser.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = turn_off(params)
% Turns off the MPB 750 laser.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name             : string
%   The name of the device in the global handles structure.
%
% Returns
% -------
% handle : function handle
%   A pointer to a function that executes the desired hardware commands.

global g_gui;
global g_mmc;
global g_acq;
global g_h;

cmdTerminator = '\r';
ansTerminator = '\rD >'; % D > indicates a successful cmd

%% Unpack the acquisition parameters from params struct
try
    name = params.name;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['Missing field in params struct for the MPB 750 laser.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: ' name '\n' ...
              'Command: Turn off']));
    else
        rethrow(ME);
    end
end

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_mmc.setSerialPortCommand(name, 'SETLDENABLE 0', ...
                                   sprintf(cmdTerminator));
        g_mmc.getSerialPortAnswer(name, sprintf(ansTerminator));
    end

handle = @() deviceControl();
end