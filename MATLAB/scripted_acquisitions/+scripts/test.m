% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Test script for automated acquisitions.

function script = test()

acqParams.rootName  = 'H:\test';
acqParams.dirName   = 'test_acq';
acqParams.numFrames = 50;
acqParams.interval  = 0; % milliseconds

sf = @utils.stepFactory;

script = {

sf('pgFocus', 'lock focus', struct('lock', true), 'pauseAfter', 20);
sf('Camera', 'set exposure', struct('expTime', 10), 'pauseAfter', 100)
sf('ND Filter', 'move', struct('pos', 'down'), 'pauseAfter', 1000)
sf('MPB Laser 642', 'turn on', struct(), 'pauseAfter', 10000);
sf('MPB Laser 642', 'set power', struct('power', 300), 'pauseAfter', 1000)
sf('Acquisition Engine', 'start STORM acquisition', acqParams)
sf('Acquisition Engine', 'wait for finish', struct())
sf('MPB Laser 642', 'set power', struct('power', 200), 'pauseAfter', 1000)
sf('MPB Laser 642', 'turn off', struct(), 'pauseAfter', 500)
sf('ND Filter', 'move', struct('pos', 'up'), 'pauseAfter', 0)
sf('pgFocus', 'lock focus', struct('lock', false), 'pauseAfter', 20);

};

end