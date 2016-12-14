% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Test script for automated acquisitions across two computers.
% 
% This test script is intended for the primary acquisition computer. It
% will send the acquisition information to the secondary which controls
% only a camera and minor peripherals computer.

function script = test_two_computers_pc1(acqParams, wfParams, PCID, SECONDARY_PCID)
% Defines a sequence of hardware steps for a STORM acquisition.
%
% Parameters
% ----------
% acqParams.folder
% acqParams.filename
% acqParams.numFrames
% acqParams.interval
% wfParams.folder
% wfParams.filename
%
% Returns
% script : cell array of steps

% TODO: Use input parser and varargin for passing comm params

sf = @utils.stepFactory;

script = {

sf('pgFocus', 'lock focus', struct('lock', true), 'pauseAfter', 20);
sf('Camera', 'set exposure', struct('expTime', 10), 'pauseAfter', 100)
sf('MPB Laser 642', 'turn on', struct(), 'pauseAfter', 10000)
sf('Shutter', 'open shutter', struct())

% TODO: send info to other computer for snapping a widefield image
sf('Acquisition Engine', 'snap widefield image', wfParams)
sf('ND Filter', 'move', struct('pos', 'down'), 'pauseAfter', 1000)
sf('MPB Laser 642', 'set power', struct('power', 300), 'pauseAfter', 1000)

% Prepare the acquisition on the other computer
sf('Acquisition Engine', 'clear com buffer', struct());
sf('Acquisition Engine', 'send acq data',             ... 
   struct('comFolder', 'V:\com_folder',               ...
          'comFilename', [PCID '.mat'],               ...
          'pcID', PCID,                               ...
          'message', 'start STORM acquisition',       ...
          'acqParams', acqParams,                     ...
          'expTime', 10));

% Poll the com folder for the response from the other computer
sf('Acquisition Engine', 'poll com folder',           ...
   struct('comFolder', 'V:\com_folder',               ...
          'comFilename', [SECONDARY_PCID '.mat'],                   ...
          'timeout', 10000));   % timeout in milliseconds
          
% Once the response file appears, go ahead and start the acquisition
sf('Acquisition Engine', 'start STORM acquisition', acqParams)
sf('Acquisition Engine', 'wait for finish', struct())

% Check to see whether the other computer has finished
sf('Acquisition Engine', 'clear com buffer', struct());
sf('Acquisition Engine', 'poll com folder',           ...
   struct('comFolder', 'V:\com_folder',               ...
          'comFilename', [SECONDARY_PCID '.mat'],                   ...
          'timeout', 60000));   % timeout in milliseconds

sf('Shutter', 'close shutter', struct())
sf('MPB Laser 642', 'set power', struct('power', 200), 'pauseAfter', 1000)
sf('MPB Laser 642', 'turn off', struct(), 'pauseAfter', 500)
sf('ND Filter', 'move', struct('pos', 'up'), 'pauseAfter', 0)
sf('pgFocus', 'lock focus', struct('lock', false), 'pauseAfter', 20);

};

end