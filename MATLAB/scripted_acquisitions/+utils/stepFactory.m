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
%
% Returns
% -------
% step : struct
%   A structure with the fields specified in initScriptEngine.m in the
%   g_stepFields array.

global g_engineInitialized;
global g_nameMap;
global g_gui;
global g_mmc;
global g_acq;

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
parse(p, device, command, params, varargin{:});

%% Convert the command into one that is executable
% Make input command case insensitive
cmd = lower(p.Results.command);
switch p.Results.device
    %===================
    % Acquisition Engine
    %===================
    case 'Acquisition Engine'
        switch cmd
            case 'start acquisition'
                params   = p.Results.params;
                try
                    % Unpack the Multi-D Acquisition parameters
                    rootName  = params.rootName;
                    dirName   = params.dirName;
                    numFrames = params.numFrames;
                    interval  = params.interval;
                catch ME
                    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
                        error(['The params struct for the Acquisition '...
                               'Engine is missing a field.']);
                    else
                        rethrow(ME);
                    end
                end
                
                % Launch the acquisition
                step.cmd = ['g_acq.setRootName(''' rootName ''');' ...
                            'g_acq.setDirName(''' dirName ''');'   ...
                            'g_acq.setFrames(' num2str(numFrames)  ...
                            ', ' num2str(interval) ');'            ...
                            'g_acq.acquire();'];
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
    
    %=======
    % Camera
    %=======
    case 'Camera'
        name = g_nameMap('Camera');
        switch cmd
            case 'set exposure'
                expTime = p.Results.params; % Exposure time in milliseconds
                step.cmd = ['g_gui.setExposure(' num2str(expTime) ')'];
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================
    % Filter Wheel Commands
    %======================
    case 'Filter Wheel'
        name = g_nameMap('Filter Wheel');
        switch cmd
            case 'move filter'
                if p.Results.params == 647
                    fPos = 0;   % Physical position of 647 filter
                elseif p.Results.params == 488
                    fPos = 120; % Physical position of 488 filter
                elseif p.Results.params == 750
                    fPos = 240; % Physical position of 750 filter
                end
                
                step.cmd = ['g_h.' name '.SetAbsMovePos(0, ' ...
                            num2str(fPos) ');' ...   
                            'g_h.' name '.MoveAbsolute(0, 0);'];
            case 'move home'
                step.cmd = ['g_h.' name '.MoveHome(0,0);'];
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %==============
    % MPB Laser 642
    %==============
    case 'MPB Laser 642'
        name = g_nameMap('MPB Laser 642');
        cmdTerminator = '\r';
        ansTerminator = '\rD >'; % D > indicates a successful cmd
        switch cmd
            case 'turn on'
                step.cmd = ['g_mmc.setSerialPortCommand(''' name ''', ' ...
                            '''SETLDENABLE 1'', sprintf('''             ...
                            cmdTerminator '''));'                       ...
                            'g_mmc.getSerialPortAnswer(''' name  ''', ' ...
                            'sprintf(''' ansTerminator '''));'];
            case 'turn off'
                step.cmd = ['g_mmc.setSerialPortCommand(''' name ''', ' ...
                            '''SETLDENABLE 0'', sprintf('''             ...
                            cmdTerminator '''));'                       ...
                            'g_mmc.getSerialPortAnswer(''' name  ''', ' ...
                            'sprintf(''' ansTerminator '''));'];
            case 'set power'
                power = p.Results.params;
                step.cmd = ['g_mmc.setSerialPortCommand(''' name ''', ' ...
                            '''SETPOWER 0 ' num2str(power) ''', '       ...
                            'sprintf(''' cmdTerminator '''));'          ...
                            'g_mmc.getSerialPortAnswer(''' name  ''', ' ...
                            'sprintf(''' ansTerminator '''));'];
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %===================    
    % ND Filter Commands
    % ==================
    case 'ND Filter'
        name = g_nameMap('ND Filter');
        switch cmd
            case 'move up'
                step.cmd = ['g_mmc.setProperty(''' name ''', ''Label'','...
                            '''ND Filter Up'')'];
            case 'move down'
                step.cmd = ['g_mmc.setProperty(''' name ''', ''Label'','...
                            '''ND Filter Down'')'];
            otherwise
                commandError(p.Results.device, p.Results.command);
        end

    otherwise
        deviceError(p.Results.device);
end

%% Add pauses before and after the command executes if they exist
step.pauseBefore = p.Results.pauseBefore;
step.pauseAfter  = p.Results.pauseAfter;

end

function deviceError(device)
% Raises an error when the device is not recognized.
msg = [device ' is not a recognized device.'];
error(msg)
end

function commandError(device, command)
% Raises an error when a bad command is issued.
msg = [command ' is an unrecognized command for the device ' device];
error(msg)
end
