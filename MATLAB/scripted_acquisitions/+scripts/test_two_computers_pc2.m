% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Test script for automated acquisitions across two computers.
% 
% This test script is intended for the secondary acquisition computer. It
% reads the information sent from the primary acquisition computer and
% starts acquisitions based on it.

function script = test_two_computers_pc2(acqParams, wfParams, PCID, PRIMARY_PCID)
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

global g_comBuffer;

sf = @utils.stepFactory;

script = {

% Poll the com folder for the data from the other computer
sf('Acquisition Engine', 'poll com folder',           ...
   struct('comFolder', 'E:\com_folder',               ...
          'comFilename', [PRIMARY_PCID '.mat'],       ...
          'timeout', 60000));   % timeout in milliseconds

% Set the exposure time of the camera
sf('Camera', 'set exposure',                          ...
   struct('expTime', g_comBuffer.expTime),            ...
   'pauseAfter', 100);

% Start the acquisition and have camera wait on the trigger signal
sf('Acquisition Engine', g_comBuffer.message, g_comBuffer.acqParams);

% Send notice that the acquisition is ready
sf('Acquisition Engine', 'send acq data',             ... 
   struct('comFolder', 'E:\com_folder',               ...
          'comFilename', [PCID '.mat'],               ...
          'pcID', PCID,                               ...
          'message', 'Ready to acquire'));

% Wait for the acquisition to finish
sf('Acquisition Engine', 'wait for finish', struct())

% Once finished report that the acquisition has finished
% Send notice that the acquisition is ready
sf('Acquisition Engine', 'send acq data',             ... 
   struct('comFolder', 'E:\com_folder',               ...
          'comFilename', [PCID '.mat'],               ...
          'pcID', PCID,                               ...
          'message', 'Acquisition finished'));

% Clear the com buffer
sf('Acquisition Engine', 'clear com buffer', struct());

};

end