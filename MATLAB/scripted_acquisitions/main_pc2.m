% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Prototyping pc2 scripting... this is not an important script
%

global g_comBuffer;
g_comBuffer = [];

sf = @utils.stepFactory;

% Poll the com folder for the data from the other computer
step = sf('Acquisition Engine', 'poll com folder',           ...
          struct('comFolder', 'E:\com_folder',               ...
                 'comFilename', [PRIMARY_PCID '.mat'],       ...
                 'timeout', 60000));   % timeout in milliseconds
step.cmd();
pause(step.pauseAfter/ 1000);

% Set the exposure time of the camera
step = sf('Camera', 'set exposure',                          ...
          struct('expTime', g_comBuffer.expTime),            ...
          'pauseAfter', 100);
step.cmd();
pause(step.pauseAfter / 1000);

% Start the acquisition and have camera wait on the trigger signal
step = sf('Acquisition Engine', g_comBuffer.message, g_comBuffer.acqParams);
step.cmd();
pause(step.pauseAfter);

% Send notice that the acquisition is ready
step = sf('Acquisition Engine', 'send acq data',             ... 
          struct('comFolder', 'E:\com_folder',               ...
                 'comFilename', [PCID '.mat'],               ...
                 'pcID', PCID,                               ...
                 'message', 'Ready to acquire',              ...
                 'expTime', [],                              ...
                 'acqParams', []));
step.cmd();
pause(step.pauseAfter/ 1000);

% Wait for the acquisition to finish
step = sf('Acquisition Engine', 'wait for finish', struct());
step.cmd();
pause(step.pauseAfter/ 1000);

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
pause(step.pauseAfter/ 1000);
             
% Clear the com buffer
step = sf('Acquisition Engine', 'clear com buffer', struct());
step.cmd();
pause(step.pauseAfter / 1000);