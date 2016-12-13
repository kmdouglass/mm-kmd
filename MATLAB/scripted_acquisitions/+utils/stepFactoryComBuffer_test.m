% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% This file contain tests specific to passing information between the
% acquisition control computers during a scripted acquisition. Each test
% needs to be run separately and in the sequence indicated below because
% the global variable g_comBuffer is not actually updated during MATLAB
% unit tests.
%
% Tests in this file may be executed only after initiating the scripted
% acquisition engine with init.m.
%
% Run individual tests in this file with the command
%
%   result = runtests(
%     'utils.stepFactoryComBuffer_test',
%     'Name',
%     'utils.stepFactoryComBuffer_test/Test1_SetCameraExposureTime');
%
% Replace the name with the name of desired test, dropping all spaces and
% replacing the ':' character with '_'. The first letter of each name
% should be capitalized when running select tests, even if it's not
% capitalized in this file.
%
% A full list of names for the tests is obtained with the command
%
%   tests = testsuite('utils.stepFactory_test');
%
% Wilcards may be used, but with care. For example, the command
%
%   result = runtests(
%     'utils.stepFactoryComBuffer_test', 'Name', '*Test1*');
%
% will run tests 1, 10, 100, etc.
%
% Helper code to run all tests. Change the range of ctr to the number of
% tests in this file.
%
% for ctr = 1:8
%   testNum = ['*Test' num2str(ctr) '_*'];
%   result = runtests('utils.stepFactoryComBuffer_test', 'Name', testNum);
% end

global g_h;
global g_nameMap;
global g_gui;
global g_mmc;
global g_acq;
global g_comBuffer;

% Shared variables
params = struct(); % Is reset for each new test

%% Test 1: Poll Folder
% Polls a selected folder for a com file.

% Empty the buffer
g_comBuffer = [];

% Place a test com file in the folder before checking for it
comFolder   = userpath;
comFilename = 'testPC.mat';
pcID        = 'testPC'; % Name to insert into the pcID field of g_comBuffer
acqParams   = [];
message     = [];

filename = fullfile(comFolder, comFilename); % File to poll for
save(filename, 'pcID', 'acqParams', 'message');

% Setup and launch the polling step
params.comFolder   = comFolder;
params.comFilename = comFilename;
params.timeout     = 10000; % milliseconds
step = utils.stepFactory('Acquisition Engine', 'poll com folder', params);
step.cmd();

% Verify that the file was deleted.
assert(exist(filename, 'file') == 0); % 0 -> does not exist

%% Test 2: Test Poll Folder
% This actually verifies the outcome of the Test 10 because the copy of
% g_comBuffer available to the testsuite is not updated until after the
% test completes, which would cause the assertion below to fail if grouped
% with the Test 10 code.

% Verify that the buffer contains the 'sending' PC's identifier
assert(strcmp('testPC', g_comBuffer.pcID));

% Empty the buffer
g_comBuffer = [];

%% Test 3: Poll Folder Timeout
% The polling function times out if no file is found.

% Empty the buffer
g_comBuffer = [];

% Place a test com file in the folder before checking for it
comFolder   = userpath;
comFilename = 'testPC.mat';

% Setup and launch the polling step
params.comFolder   = comFolder;
params.comFilename = comFilename;
params.timeout     = 5000; % milliseconds
step = utils.stepFactory('Acquisition Engine', 'poll com folder', params);

try
    step.cmd();
catch ME
    if ME.identifier == 'AquisitionEngine:PollingTimeout'
        disp('Polling timeout error successfully caught.');
    else
        rethrow(ME);
    end
end

assert(isempty(g_comBuffer)); % Buffer is empty due to timeout

%% Test 4: Clear Com Buffer
% First, fill the com buffer with test data
params.pcID      = 'testPC';
params.acqParams = [];
params.message   = [];

g_comBuffer = [];
g_comBuffer.pcID      = params.pcID;
g_comBuffer.acqParams = params.acqParams;
g_comBuffer.message   = params.message;

assert(strcmp(g_comBuffer.pcID, params.pcID));

step = utils.stepFactory('Acquisition Engine', 'clear com buffer', params);
step.cmd();

%% Test 5: Test Clear Com Buffer
% Tests the outcome of test 13 by circumventing the unit test bug described
% in Test 11.
assert(~isstruct(g_comBuffer));

%% Test 6: Send Acq. Data
% Sends acquisition data by placing a .mat file in the com folder.

% Empty the buffer
g_comBuffer = [];

% Place a test com file in the folder before checking for it
params.comFolder   = userpath;
params.comFilename = 'testPC.mat';
params.pcID        = 'testPC'; % pcID field of g_comBuffer
params.acqParams   = struct('folder', 'C:\', ...
                            'filename', 'test_acq', ...
                            'numFrames', 500, ...
                            'interval', 0);
params.message     = 'hello there';


% Send the acquisition parameters to a .mat file in the com folder
step = utils.stepFactory('Acquisition Engine', 'send acq data', params);
step.cmd();

% Read out the buffer
params.timeout     = 10000; % milliseconds
step = utils.stepFactory('Acquisition Engine', 'poll com folder', params);
step.cmd();

%% Test 7: Test Send Acq. Data
% Tests the outcome of test 15 by circumventing the unit test bug described
% in Test 11.
params.comFolder   = userpath;
params.comFilename = 'testPC.mat';
params.pcID        = 'testPC'; % pcID field of g_comBuffer
params.acqParams   = struct('folder', 'C:\', ...
                            'filename', 'test_acq', ...
                            'numFrames', 500, ...
                            'interval', 0);
params.message     = 'hello there';

assert(strcmp(g_comBuffer.pcID, params.pcID));
assert(strcmp(g_comBuffer.message, params.message));
assert(strcmp(g_comBuffer.acqParams.folder, 'C:\'));
assert(strcmp(g_comBuffer.acqParams.filename, 'test_acq'));
assert(g_comBuffer.acqParams.numFrames == 500);
assert(g_comBuffer.acqParams.interval == 0);

%% Test 8: Empty the buffer as the last step
step = utils.stepFactory('Acquisition Engine','clear com buffer',struct());
step.cmd();