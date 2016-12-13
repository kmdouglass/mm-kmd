% Sends acquisition information for the second PC to the com folder.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = send_acq_data(params)
% Sends acquisition information for the second PC to the com folder.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name        : string
%   The name of the device in the global handles structure.
% comFolder   : char array
%   The folder containing communications files.
% comFileName : char array
%   The name of the file to poll for.
% pcID        : char array
%   The ID of the PC sending the information.
% message     : char array
%   Message passed between the PC's.
% acqParams   : struct
%   Parameters required for to start an acquisition on a remote computer.
%
% Returns
% -------
% handle : function handle
%   A pointer to a function that executes the desired hardware commands.

%% Unpack the acquisition parameters from params struct
try
    comFolder   = params.comFolder;
    comFilename = params.comFilename;
    pcID        = params.pcID;
    message     = params.message;
    acqParams   = params.acqParams;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['The params struct for the sending acquisition data to '...
               'the com folder is missing a field.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Acquisition Engine\n' ...
              'Command: Send acq data']));
    else
        rethrow(ME);
    end
end

p = inputParser;
addRequired(p, 'comFolder', @ischar);
addRequired(p, 'comFilename', @ischar);
addRequired(p, 'pcID', @ischar);
parse(p, comFolder, comFilename, pcID);

filename = fullfile(p.Results.comFolder, p.Results.comFilename);

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        save(filename, 'pcID', 'message', 'acqParams');
    end

handle = @() deviceControl();
end

