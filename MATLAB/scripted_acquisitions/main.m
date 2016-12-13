% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

% STORM acquisition parameters
acqParams.folder     = 'H:\test';
acqParams.filename   = 'test_acq';
acqParams.numFrames  = 2000;
acqParams.interval   = 0; % time between frames; milliseconds

% Widefield image parameters
wfParams.folder   = acqParams.rootName;
wfParams.filename = [acqParams.dirName '_WF'];

% Select which script will run
script        = scripts.test(acqParams, wfParams);
engine        = scriptEngine();
engine.script = script;

%% Launch acquisition
engine.run()