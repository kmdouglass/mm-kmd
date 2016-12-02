% Snaps a widefield image.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = snap_widefield_image(params)
% Snaps a widefield image.
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
    filename = params.filename;
    folder   = params.folder;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['The params struct for the snapping a '...
               'widefield image is missing a field.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Acquisition Engine\n' ...
              'Command: Snap widefield image']));
    else
        rethrow(ME);
    end
end

%% Device control functions
    function deviceControl()%% Device control functions
        acqName=char(g_gui.getUniqueAcquisitionName(filename));
        % false, true -> show acquisition is false, save to disk is true
        g_gui.openAcquisition(acqName, folder, 1,1,1,1, false, true);
        g_gui.snapAndAddImage(acqName,0,0,0,0);
        g_gui.closeAcquisition(acqName);
    end

handle = @() deviceControl();
end