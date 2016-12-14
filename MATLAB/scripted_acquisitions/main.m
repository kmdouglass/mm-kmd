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
wfParams.folder   = acqParams.folder;
wfParams.filename = [acqParams.filename '_WF'];

% Select which script will run
script        = scripts.test_two_computers_pc2(...
                    acqParams, wfParams, PCID, PRIMARY_PCID);
engine        = scriptEngine();
engine.script = script;

%% Launch acquisition
engine.run()