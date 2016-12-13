% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Tests in this file may be executed only after initiating the scripted
% acquisition engine with init.m.
%
% Run all tests in this file with the command
%
%   result = runtests('utils.stepFactory_test');
%
% Run individual tests in this file with the command
%
%   result = runtests(
%     'utils.stepFactory_test',
%     'Name', 'utils.stepFactory_test/Test1_SetCameraExposureTime');
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
%   result = runtests('utils.stepFactory_test', 'Name', '*Test1*');
%
% will run tests 1, 10, 100, etc.
%
% This test is specific to the Micro-Manager configuration file
% ht-main_Prime.cfg. Any changes to the hardware will likely require
% changes to the tests. To run these tests, the the full script engine and
% Micro-Manager environment should be loaded. One way to do this is to
% execute init.m.

global g_h;
global g_nameMap;
global g_gui;
global g_mmc;
global g_acq;
global g_comBuffer;

%% Test 1: Set Camera Exposure Time
% Set the camera exposure time to 50 ms and then to 10 ms
clear params
params.expTime = 50;
step = utils.stepFactory('Camera', 'set exposure', params);
step.cmd()
pause(0.5);
assert(g_mmc.getExposure() == 50);

params.expTime = 10;
step = utils.stepFactory('Camera', 'set exposure', params);
step.cmd()
pause(0.5);
assert(g_mmc.getExposure() == 10);

%% Test 2: Move Filter Wheel
% Move the filter wheel through its filter positions
clear params
fpos647 = 0;
fpos488 = 120;
fpos750 = 240;

params.filterWavelength = 647;
step = utils.stepFactory('Filter Wheel', 'move filter', params);
step.cmd();
pause(2);
currPos = round(g_h.(g_nameMap('Filter Wheel')).GetPosition_Position(0));
assert(currPos == fpos647);

params.filterWavelength = 488;
step = utils.stepFactory('Filter Wheel', 'move filter', params);
step.cmd();
pause(2);
currPos = round(g_h.(g_nameMap('Filter Wheel')).GetPosition_Position(0));
assert(currPos == fpos488);

params.filterWavelength = 750;
step = utils.stepFactory('Filter Wheel', 'move filter', params);
step.cmd();
pause(2);
currPos = round(g_h.(g_nameMap('Filter Wheel')).GetPosition_Position(0));
assert(currPos == fpos750);

%% Test 3: Home the filter wheel
step = utils.stepFactory('Filter Wheel', 'move home', []);
step.cmd();

%% Test 4: Raise and lower the ND filter
params.pos = 'up';
step = utils.stepFactory('ND Filter', 'move', params);
step.cmd();
pause(2);
currState = g_mmc.getProperty(g_nameMap('ND Filter'), 'Label');
assert(strcmp(currState, 'ND Filter Up'));

params.pos = 'down';
step = utils.stepFactory('ND Filter', 'move', params);
step.cmd();
pause(2);
currState = g_mmc.getProperty(g_nameMap('ND Filter'), 'Label');
assert(strcmp(currState, 'ND Filter Down'));

params.pos = 'up';
step = utils.stepFactory('ND Filter', 'move', params);
step.cmd();
pause(2);
currState = g_mmc.getProperty(g_nameMap('ND Filter'), 'Label');
assert(strcmp(currState, 'ND Filter Up'));

%% Test 5: Turn on 642 laser, set the power, then turn it off
port = 'COM10';
cmdTerminator = sprintf('\r');
ansTerminator = sprintf('\rD >');

% Turn laser on
params = struct();
step = utils.stepFactory('MPB Laser 642', 'turn on', params);
step.cmd();
pause(8);
g_mmc.setSerialPortCommand(port, 'GETLDENABLE', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
pause(0.05);
assert(str2num(answer) == 1);

% Set power to 300 mW
params.power = 300;
step = utils.stepFactory('MPB Laser 642', 'set power', params);
step.cmd();
pause(1);
g_mmc.setSerialPortCommand(port, 'GETPOWER 0', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
assert(str2num(answer) == 300);

% Set power to 200 mW
params.power = 200;
step = utils.stepFactory('MPB Laser 642', 'set power', params);
step.cmd();
pause(2);
g_mmc.setSerialPortCommand(port, 'GETPOWER 0', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
assert(str2num(answer) == 200);

% Turn laser off
step = utils.stepFactory('MPB Laser 642', 'turn off', []);
step.cmd();
pause(8);
g_mmc.setSerialPortCommand(port, 'GETLDENABLE', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
pause(0.05);
assert(str2num(answer) == 0);

%% Test 6: Run a test STORM acquisition
params = struct();
params.folder     = ['H:\test_' num2str(randi([1e5, 999999]))];
params.filename   = 'test_acq';
params.numFrames  = 50;
params.interval   = 20; % milliseconds

% Make the directory if it doesn't exist
[s, mess, messid] = mkdir(params.rootName);
step = utils.stepFactory(...
    'Acquisition Engine','start STORM acquisition', params);
step.cmd();

acqName = char(g_gui.getAcquisitionNames());
disp('Test acquisition is running.');

% Wait for the acquisition to finish
while g_acq.isAcquisitionRunning()
    disp('Test acquisition is still running.');
    pause(1);
    continue;
end
disp('Test acquisition has finished.');
pause(2);
g_gui.closeAcquisitionWindow(acqName);

% Assert that the folder exists and contains image data.
% This assumes that MM has appended a '_1' to the dirName.
fullDir      = fullfile(params.rootName, [params.dirName '_1']);
folderExists = logical(exist(fullDir, 'dir'));
assert(folderExists);

imgData    = fullfile(fullDir, [params.dirName '_1_MMStack_Pos0.ome.tif']);
fileExists = logical(exist(imgData, 'file'));
assert(fileExists);

% 's' argument deletes folder and contents.
[status, message, messageid] = rmdir(params.rootName,'s');

%% Test 7: Snap a test widefield image
% NOTE: MM does not release handles to single images that have been
% snapped. The test image therefore needs to be deleted after this session
% of MM has been closed.

clear params
% The folder is given a random name because widefield images cannot be
% deleted until MM is closed. By giving it a random name, we (most likely)
% save the image data into a fresh folder so that MM won't automatically
% append a number to the filename's prefix.
params.folder   = ['C:\Users\laboleb\Desktop\Temp\delete_me_' ...
                   num2str(randi([1e5, 999999]))];
params.filename = 'WF_test';

step = utils.stepFactory(...
    'Acquisition Engine','snap widefield image', params);
step.cmd();

% Check that the file exists
% There is a bug in MM+MATLAB that does not prepend the acquisition name
% (called "Prefix" in the MM metadata) to the file the first time an image
% is snapped for a given prefix. We therefore check for an image named
% 'MMStack_Pos0.ome.tif'.
imgData = fullfile(params.folder, [params.filename '' ], ...
                   'MMStack_Pos0.ome.tif');
fileExists = logical(exist(imgData, 'file'));
assert(fileExists)

%% Test 8: Open and close the shutter
% I don't ask the device itself for confirmation that the shutter is open
% because the APT ActiveX method SC_GetOPState() requires a pointer as the
% second argument. MATLAB however thinks it requires an integer and thus
% throws an error indicating that the matching method signature cannot be
% found.

clear params
params = struct();
step = utils.stepFactory('Shutter', 'open shutter', params);
step.cmd();
button = questdlg('Is the shutter open?');
assert(strcmp(button, 'Yes'));

step = utils.stepFactory('Shutter', 'close shutter', params);
step.cmd();
button = questdlg('Is the shutter closed?');
assert(strcmp(button, 'Yes'));

%% Test 9: Lock and unlock the pgFocus
clear params
params.lock = true;
step = utils.stepFactory('pgFocus', 'lock focus', params);
step.cmd()
pause(1);
currState = g_mmc.getProperty(g_nameMap('pgFocus'), 'Focus Mode');
% Uncomment this line if the pgFocus can actually be locked, i.e. there is
% a coverslip with glass and the return laser beam is clean.
% assert(strcmp(currState, 'Lock Focus'));

params.lock = false;
step = utils.stepFactory('pgFocus', 'lock focus', params);
step.cmd()
pause(1);
currState = g_mmc.getProperty(g_nameMap('pgFocus'), 'Focus Mode');
assert(strcmp(currState, 'Unlock Focus'));

%% Test 10: Poll Folder
% Polls a selected folder for a com file.
clear params

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

pause(2);
% Verify that the buffer contains the 'sending' PC's identifier
disp('is this even reached?');

% Empty the buffer
g_comBuffer = [];

%% Test 11: Poll Folder Timeout
% The polling function times out if no file is found.
clear params

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
step.cmd();

assert(isempty(g_comBuffer)); % Buffer is empty due to timeout