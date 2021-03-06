% Creates a single step to perform during a scripted acquisition.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function step = stepFactory(device, command, params)
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
%   command, then pass an empty struct.
%
% Returns
% -------
% step : struct
%   A structure with the fields specified in initScriptEngine.m in the
%   g_stepFields array.

global g_nameMap;
global g_gui;
global g_mmc;
global g_acq;
global g_comBuffer;

%% Parse the input arguments
% Attach the device name to the params struct
params.name = g_nameMap(device);

p = inputParser;
addRequired(p, 'device', @ischar);
addRequired(p, 'command', @ischar);
addRequired(p, 'params');
parse(p, device, command, params);

%% Convert the command into one that is executable
% Make input command case insensitive
cmd = lower(p.Results.command);
switch p.Results.device
    %======================================================================
    % Acquisition Engine
    %
    % The Acquisition Engine is an abstraction layer for any
    % non-device-specific software that controls data acquisition on the
    % microscope. It includes, for example, launching Multi-D acquisitions
    % in Micro-Manager and two-way communications between computers, which
    % do not directly control any hardware.
    %======================================================================
    case 'Acquisition Engine'
        switch cmd
            case 'clear com buffer'
                % Clears the com buffer of data
                step.cmd = steps.acquisition_engine.clear_com_buffer(...
                    p.Results.params);
                
            case 'poll com folder'
                % Polls the com folder for a new file
                step.cmd = steps.acquisition_engine.poll_com_folder(...
                    p.Results.params);
                
            case 'send acq data'
                % Sends acquisition data for another computer to read
                step.cmd = steps.acquisition_engine.send_acq_data(...
                    p.Results.params);
                
            case 'start storm acquisition'
                % Launch the acquisition
                step.cmd = steps.acquisition_engine.start_storm_acquisition(...
                    p.Results.params);
            
            case 'snap widefield image'
                % Snap the image and save it to disk
                step.cmd = steps.acquisition_engine.snap_widefield_image(...
                    p.Results.params);
                
            case 'wait for finish'
                step.cmd = steps.acquisition_engine.wait_for_finish(...
                    p.Results.params);
                    
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
    
    %======================================================================
    % Camera
    %======================================================================
    case 'Camera'
        switch cmd
            case 'set exposure'
                step.cmd = steps.camera.set_exposure(p.Results.params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================================================================
    % Filter Wheel Commands
    %======================================================================
    case 'Filter Wheel'
        switch cmd
            case 'move filter'
                step.cmd = steps.filter_wheel.move_filter(params);
            case 'move home'
                step.cmd = steps.filter_wheel.move_home(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================================================================
    % MPB Laser 642
    %======================================================================
    case 'MPB Laser 642'
        switch cmd
            case 'turn on'
                step.cmd = steps.mpb_laser_642.turn_on(params);
            case 'turn off'
                step.cmd = steps.mpb_laser_642.turn_off(params);
            case 'set power'
                step.cmd = steps.mpb_laser_642.set_power(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================================================================
    % MPB Laser 750
    %======================================================================
    case 'MPB Laser 750'
        switch cmd
            case 'turn on'
                step.cmd = steps.mpb_laser_750.turn_on(params);
            case 'turn off'
                step.cmd = steps.mpb_laser_750.turn_off(params);
            case 'set power'
                step.cmd = steps.mpb_laser_750.set_power(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================================================================    
    % ND Filter Commands
    %======================================================================
    case 'ND Filter'
        switch cmd
            case 'move'
                step.cmd = steps.nd_filter.move(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end

    %======================================================================
    % pgFocus
    %======================================================================
    case 'pgFocus'
        switch cmd
            case 'lock focus'
                step.cmd = steps.pgfocus.lock_focus(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================================================================
    % Sapphire Laser 488
    %======================================================================
    case 'Sapphire Laser 488'
        switch cmd
            case 'turn on'
                step.cmd = steps.sapphire_laser_488.turn_on(params);
            case 'turn off'
                step.cmd = steps.sapphire_laser_488.turn_off(params);
            case 'set power'
                step.cmd = steps.sapphire_laser_488.set_power(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    %======================================================================
    % Shutter
    %======================================================================
    case 'Shutter'
        switch cmd
            case 'open shutter'
                step.cmd = steps.shutter.open_shutter(params);
            case 'close shutter'
                step.cmd = steps.shutter.close_shutter(params);
            otherwise
                commandError(p.Results.device, p.Results.command);
        end
        
    otherwise
    deviceError(p.Results.device);
end
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
