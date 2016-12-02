% Moves the ND Filter.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = move(params)
% Moves the ND filter.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name  : string
%   The name of the device in the global handles structure.
% pos   : char array
%   String of either 'up' or 'down'.

global g_gui;
global g_mmc;
global g_acq;
global g_h;

%% Unpack the acquisition parameters from params struct
try
    name  = params.name;
    pos   = params.pos;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['Missing field in params struct for the ND Filter.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: ' name '\n' ...
              'Command: Move']));
    else
        rethrow(ME);
    end
end

if strcmp(pos, 'up')
    pos = 'ND Filter Up';   % Depends on MM hardware configuration.
elseif strcmp(pos, 'down')
    pos = 'ND Filter Down'; % Depends on MM hardware configuration.
else
    error('Variable pos should be either ''up'' or ''down''');
end
%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_mmc.setProperty(name, 'Label', pos);
    end

handle = @() deviceControl();
end