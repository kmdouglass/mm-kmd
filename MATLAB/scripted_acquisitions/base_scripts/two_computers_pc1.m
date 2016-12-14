% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Base script for automated acquisitions across two computers.
% 
% This base script is intended for the primary acquisition computer. It
% will send the acquisition information to the secondary which controls
% only a camera and minor peripherals computer.
%
%% Setup the acquisition parameters
% STORM acquisition parameters
acqParams.folder     = 'H:\test';
acqParams.filename   = 'test_acq';
acqParams.numFrames  = 2000;
acqParams.interval   = 0; % time between frames; milliseconds

% Widefield image parameters
wfParams.folder   = acqParams.folder;
wfParams.filename = [acqParams.filename '_WF'];

sf = @utils.stepFactory;

%% Launch the acquisition
step = sf('pgFocus', 'lock focus', struct('lock', true));
step.cmd()
pause(0.02);

step = sf('Camera', 'set exposure', struct('expTime', 10));
step.cmd();
pause(0.1);

step = sf('MPB Laser 642', 'turn on', struct());
step.cmd()
pause(10);

step = sf('Shutter', 'open shutter', struct());
step.cmd()

% TODO: send info to other computer for snapping a widefield image
step = sf('Acquisition Engine', 'snap widefield image', wfParams);
step.cmd();

step = sf('ND Filter', 'move', struct('pos', 'down'));
step.cmd();
pause(1);

step = sf('MPB Laser 642', 'set power', struct('power', 300));
step.cmd()
pause(1);

% Prepare the acquisition on the other computer
step = sf('Acquisition Engine', 'clear com buffer', struct());
step.cmd();

step = sf('Acquisition Engine', 'send acq data',             ... 
          struct('comFolder', 'V:\com_folder',               ...
                 'comFilename', [PCID '.mat'],               ...
                 'pcID', PCID,                               ...
                 'message', 'start STORM acquisition',       ...
                 'acqParams', acqParams,                     ...
                 'expTime', 10));
step.cmd();


% Poll the com folder for the response from the other computer
step = sf('Acquisition Engine', 'poll com folder',           ...
          struct('comFolder', 'V:\com_folder',               ...
                 'comFilename', [SECONDARY_PCID '.mat'],     ...
                 'timeout', 10000));   % timeout in milliseconds
step.cmd();
          
% Once the response file appears, go ahead and start the acquisition
step = sf('Acquisition Engine', 'start STORM acquisition', acqParams);
step.cmd();

step = sf('Acquisition Engine', 'wait for finish', struct());
step.cmd();

% Check to see whether the other computer has finished
step = sf('Acquisition Engine', 'clear com buffer', struct());
step.cmd();

step = sf('Acquisition Engine', 'poll com folder',           ...
          struct('comFolder', 'V:\com_folder',               ...
                 'comFilename', [SECONDARY_PCID '.mat'],     ...
                 'timeout', 60000));   % timeout in milliseconds
step.cmd();


step = sf('Shutter', 'close shutter', struct());
step.cmd();

step = sf('MPB Laser 642', 'set power', struct('power', 200));
step.cmd();
pause(1);

step = sf('MPB Laser 642', 'turn off', struct());
step.cmd();
pause(0.5);

step = sf('ND Filter', 'move', struct('pos', 'up'));
step.cmd();

step = sf('pgFocus', 'lock focus', struct('lock', false));
step.cmd();
pause(0.02);

% Cleanup
disp('Script finished.');