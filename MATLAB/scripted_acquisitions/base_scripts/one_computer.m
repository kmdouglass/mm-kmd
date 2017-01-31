% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Base script for automated acquisitions.
%
% This script snaps a widefield image and then launches a STORM
% acquisition using a single camera and channel.
%
%% Setup the acquisition parameters
% STORM acquisition parameters
acqParams.folder     = 'L:\test';
acqParams.filename   = 'test_acq';
acqParams.numFrames  = 2000;
acqParams.interval   = 0; % time between frames; milliseconds

% Widefield image parameters
wfParams.folder   = acqParams.folder;
wfParams.filename = [acqParams.filename '_WF'];

sf = @utils.stepFactory;

%% Launch the acquisition
step = sf('pgFocus', 'lock focus', struct('lock', true));
step.cmd();
pause(0.02); % Seconds

step = sf('Camera', 'set exposure', struct('expTime', 10));
step.cmd();
pause(0.1);

step = sf('MPB Laser 642', 'turn on', struct());
step.cmd();
pause(10);

step = sf('Shutter', 'open shutter', struct());
step.cmd();
pause(10);

step = sf('Acquisition Engine', 'snap widefield image', wfParams);
step.cmd();

step = sf('ND Filter', 'move', struct('pos', 'down'));
step.cmd();
pause(1);

step = sf('MPB Laser 642', 'set power', struct('power', 300));
step.cmd();
pause(1);

step = sf('Acquisition Engine', 'start STORM acquisition', acqParams);
step.cmd();

step = sf('Acquisition Engine', 'wait for finish', struct());
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
pause(0.5);

step = sf('pgFocus', 'lock focus', struct('lock', false));
step.cmd();
pause(0.02);

% Cleanup
disp('Script finished.');
