% Starts a STORM acquisition.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = start_storm_acquisition(params)
% Launches a STORM acquisition.
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

global g_gui
global g_mmc
global g_acq

%% Unpack the acquisition parameters from params struct
try
    folder     = params.folder;
    filename   = params.filename;
    numFrames  = params.numFrames;
    interval   = params.interval;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['The params struct for the STORM '...
               'Acquisition Engine is missing a field.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Acquisition Engine\n' ...
              'Command: Start STORM acquisition']));
    else
        rethrow(ME);
    end
end

p = inputParser;
addRequired(p, 'folder' , @ischar);
addRequired(p, 'filename'  , @ischar);
addRequired(p, 'numFrames', @isnumeric);
addRequired(p, 'interval' , @isnumeric);
parse(p, folder, filename, numFrames, interval);

%% Device control functions
    function ds = deviceControl()
        % Type the hardware and software instructions here
        %
        % Returns
        % -------
        % ds : Datastore
        %
        disp('Starting acquisition...');
        g_acq.setRootName(p.Results.folder);
        g_acq.setDirName(p.Results.filename);
        g_acq.setSaveFiles(true);
        g_acq.setFrames(p.Results.numFrames, p.Results.interval);
        ds = g_acq.acquire();
    end

handle = @() deviceControl();
end

