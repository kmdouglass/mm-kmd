% Polls the com folder for a new file and reads it.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = poll_com_folder(params)
% Polls the com folder for a new file and reads it.
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
% timeOut     : uint
%   The amount of time in milliseconds to wait until a timeout occurs.
%
% Returns
% -------
% handle : function handle
%   A pointer to a function that executes the desired hardware commands.

global g_comBuffer

%% Unpack the acquisition parameters from params struct
try
    comFolder   = params.comFolder;
    comFilename = params.comFilename;
    timeout     = params.timeout;
catch ME
    if strcmp(ME.identifier, 'MATLAB:nonExistentField')
        error(['The params struct for the polling the com folder '...
               'in the Acquisition Engine is missing a field.']);
    elseif strcmp(ME.identifier, 'MATLAB:structRefFromNonStruct')
        error(sprintf(['This step requires a struct as '...
              'a parameter.\n'...
              'Device: Acquisition Engine\n' ...
              'Command: Poll com folder']));
    else
        rethrow(ME);
    end
end

p = inputParser;
addRequired(p, 'comFolder' , @ischar);
addRequired(p, 'comFilename'  , @ischar);
addRequired(p, 'timeout', @isnumeric);
parse(p, comFolder, comFilename, timeout);

filename = fullfile(p.Results.comFolder, p.Results.comFilename);

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_comBuffer = []; % buffer cleared
        disp('Begin polling com folder...');
        tic
        while true
            % Break out of the loop if timeout is reached
            elapsedTime = toc;
            if (elapsedTime * 1000 >= p.Results.timeout) % timeout in ms!
                error('AquisitionEngine:PollingTimeout', ...
                      'Polling the com folder timed out.');
            end
            
            % Check whether the com file exists; if yes, read contents of
            % .mat com file, delete it, and break out of loop.
            if (exist(filename, 'file') == 2) % 2 --> file exists
                readFields  = {'pcID', 'acqParams', 'message'};
                g_comBuffer = load(filename, readFields{:});
                delete(filename);
                disp('Message received.');
                break;
            end
            % Continue back to top of loop
        end
    end

handle = @() deviceControl();
end

