% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Run this file with the command
%
%   result = runtests('utils.stepFactory_test');
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

%% Test 1: Set the camera exposure time to 50 ms and then to 10 ms
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

%% Test 2: Move the filter wheel through its filter positions
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
params.rootName  = ['H:\test_' num2str(randi([1e5, 999999]))];
params.dirName   = 'test_acq';
params.numFrames = 50;
params.interval  = 20; % milliseconds

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
% params.folder   = ['C:\Users\laboleb\Desktop\delete_me_' ...
%                    num2str(randi([1e5, 999999]))];
% params.filename = 'WF_test';
% 
% step = utils.stepFactory(...
%     'Acquisition Engine','snap widefield image', params);
% step.cmd();
% 
% % Check that the file exists
% imgData = fullfile(params.folder, [params.filename '_1' ], ...
%                    [params.filename '_1_MMStack_Pos0.ome.tif']);
% fileExists = logical(exist(imgData, 'file'));
% assert(fileExists)