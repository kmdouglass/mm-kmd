% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Base script for automated acquisitions across two computers.
% 
% This base script is intended for the secondary acquisition computer. It
% will continuously wait for a signal from the primary computer to begin
% acquiring. When the signal is received, it sets up its acquisition and
% replies to the primary computer that it is ready. It also tells the
% primary computer when it is finished acquiring.

global g_comBuffer;
g_comBuffer = [];

rootDrive = 'E:\'; % The drive letter where data will be stored;
                   % This replaces the drive sent from the primary PC.

sf = @utils.stepFactory;
%% Begin polling the com folder for the signal to start
% Press CTRL-C to manually stop loop
while true

% Poll the com folder for the data from the other computer
step = sf('Acquisition Engine', 'poll com folder',           ...
          struct('comFolder', 'E:\com_folder',               ...
                 'comFilename', [PRIMARY_PCID '.mat'],       ...
                 'timeout', 60000));   % timeout in milliseconds
try
    step.cmd();
catch ME
    if strcmp(ME.identifier, 'AquisitionEngine:PollingTimeout')
        disp('Polling timed out. Looping back to beginning...');
        continue;
    end
end

% Set the exposure time of the camera
step = sf('Camera', 'set exposure',                          ...
          struct('expTime', g_comBuffer.expTime));
step.cmd();
pause(0.1);

% Change the drive letter of the acquisition folder. Do this because the
% drives are named differently on the two computers.
g_comBuffer.acqParams.folder(1:length(rootDrive)) = rootDrive;

% Start the acquisition and have camera wait on the trigger signal
step = sf('Acquisition Engine', g_comBuffer.message, g_comBuffer.acqParams);
step.cmd();

% Send notice that the acquisition is ready
step = sf('Acquisition Engine', 'send acq data',             ... 
          struct('comFolder', 'E:\com_folder',               ...
                 'comFilename', [PCID '.mat'],               ...
                 'pcID', PCID,                               ...
                 'message', 'Ready to acquire',              ...
                 'expTime', [],                              ...
                 'acqParams', []));
step.cmd();

% Wait for the acquisition to finish
step = sf('Acquisition Engine', 'wait for finish', struct());
step.cmd();

% Once finished report that the acquisition has finished
% Send notice that the acquisition is ready
step = sf('Acquisition Engine', 'send acq data',             ... 
          struct('comFolder', 'E:\com_folder',               ...
                 'comFilename', [PCID '.mat'],               ...
                 'pcID', PCID,                               ...
                 'message', 'Acquisition finished',          ...
                 'expTime', [],                              ...
                 'acqParams', []));
step.cmd();
             
% Clear the com buffer
step = sf('Acquisition Engine', 'clear com buffer', struct());
step.cmd();

end