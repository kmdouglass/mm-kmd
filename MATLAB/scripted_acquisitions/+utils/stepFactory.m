% Creates a single step to perform during a scripted acquisition.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function step = stepFactory(device, command, params, varargin)
% stepFactory creates a single step of a scripted acquisition.
%
% stepFactory is a factory class that returns a single step of a scripted
% acquisition. It accepts a device, which is a customized name assigned to
% a piece of hardware or software (such as the piezo z-stage or the
% Micro-Manager core, respectively), a customized command that the device
% should perform, and optional inputs that determine when and if the
% command is executed.
%
% Each step is a struct whose fields are defined in initScriptEngine.m.
%
% Device names are assigned in initScriptEngine.m.
%
% Parameters
% ----------
% device  : char array
%   The descriptive name given to a device.
% command : char array
%   The descriptive name assigned to a particular action that the device
%   should perform.
% params  : any MATLAB data type
%   The parameters that describing the command. This can be, for example, a
%   laser power or a move distance. If no params are necessary for a given
%   command, then this value is ignored.
%
% Optional Name/Value Parameters
% ------------------------------
% pauseBefore   : numeric
%   The amount of time in milliseconds to pause before executing the
%   command.
%   Default: 0
% pauseAfter    : numeric
%   The same as pauseBefore, but after executing the command.
%   Default: 0
% execCondition : cell array
%   A cell array with three elements: a device, a device property, and a
%   value that the property must have for the command to be executed. This
%   condition must be true at the time immediately before the command is to
%   be executed. Default: {}
%
% Returns
% -------
% step : struct
%   A structure with the fields specified in initScriptEngine.m in the
%   g_stepFields array.

global g_engineInitialized;
global g_nameMap;

%% Initialize factory if not yet initialized
if ~g_engineInitialized
    utils.initScriptEngine()
end

%% Parse the input arguments
p = inputParser;
addRequired(p, 'device', @ischar);
addRequired(p, 'command', @ischar);
addRequired(p, 'params');
addParameter(p, 'pauseBefore', 0);
addParameter(p, 'pauseAfter', 0);
addParameter(p, 'execCondition', {});
parse(p, device, command, params, varargin{:});

%% Convert the command into one that is executable
switch p.Results.device
    %======================
    % Filter Wheel Commands
    %======================
    case 'Filter Wheel'
        name = g_nameMap('Filter Wheel');
        fPos647 = 0;
        fPos488 = 120;
        fPos750 = 240;
        switch p.Results.command
            
            % 240 -> 750 filter
            case 'Move to 647 filter'
                step.cmd = ['g_h.' name '.SetAbsMovePos(0, ' num2str(fPos647) ');' ...   
                            'g_h.' name '.MoveAbsolute(0, 0);'];
            case 'Move to 488 filter'
                step.cmd = ['g_h.' name '.SetAbsMovePos(0, ' num2str(fPos488) ');' ...
                            'g_h.' name '.MoveAbsolute(0, 0);'];
            case 'Move to 750 filter'
                step.cmd = ['g_h.' name '.SetAbsMovePos(0, ' num2str(fPos750) ');' ...
                            'g_h.' name '.MoveAbsolute(0, 0);'];
            case 'Move home'
                step.cmd = ['g_h.' name '.MoveHome(0,0);'];
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
end
end

function commandError(device, command)
% Raises an error when a bad command is issued.
msg = [command ' is an unrecognized command for the device ' device];
error(msg)
end
