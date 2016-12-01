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
global g_mmc;
global g_gui;

%% Test 1: Set the camera exposure time to 50 ms and then to 10 ms
step = utils.stepFactory('Camera', 'set exposure', 50);
eval(step.cmd);
pause(0.5);
assert(g_mmc.getExposure() == 50);

step = utils.stepFactory('Camera', 'set exposure', 10);
eval(step.cmd);
pause(0.5);
assert(g_mmc.getExposure() == 10);

%% Test 2: Move the filter wheel through its filter positions
fpos647 = 0;
fpos488 = 120;
fpos750 = 240;

step = utils.stepFactory('Filter Wheel', 'move filter', 647);
eval(step.cmd);
pause(2);
currPos = round(g_h.(g_nameMap('Filter Wheel')).GetPosition_Position(0));
assert(currPos == fpos647);

step = utils.stepFactory('Filter Wheel', 'move filter', 488);
eval(step.cmd);
pause(2);
currPos = round(g_h.(g_nameMap('Filter Wheel')).GetPosition_Position(0));
assert(currPos == fpos488);

step = utils.stepFactory('Filter Wheel', 'move filter', 750);
eval(step.cmd);
pause(2);
currPos = round(g_h.(g_nameMap('Filter Wheel')).GetPosition_Position(0));
assert(currPos == fpos750);

%% Test 3: Home the filter wheel
step = utils.stepFactory('Filter Wheel', 'move home', []);
eval(step.cmd);

%% Test 4: Raise and lower the filter wheel
step = utils.stepFactory('ND Filter', 'move up', []);
eval(step.cmd);
pause(2);
currState = g_mmc.getProperty(g_nameMap('ND Filter'), 'Label');
assert(strcmp(currState, 'ND Filter Up'));

step = utils.stepFactory('ND Filter', 'move down', []);
eval(step.cmd);
pause(2);
currState = g_mmc.getProperty(g_nameMap('ND Filter'), 'Label');
assert(strcmp(currState, 'ND Filter Down'));

%% Test 5: Turn on 642 laser, set the power, then turn it off
port = 'COM10';
cmdTerminator = sprintf('\r');
ansTerminator = sprintf('\rD >');

% Turn laser on
step = utils.stepFactory('MPB Laser 642', 'turn on', []);
eval(step.cmd);
pause(8);
g_mmc.setSerialPortCommand(port, 'GETLDENABLE', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
pause(0.05);
assert(str2num(answer) == 1);

% Set power to 300 mW
step = utils.stepFactory('MPB Laser 642', 'set power', 300);
eval(step.cmd);
pause(1);
g_mmc.setSerialPortCommand(port, 'GETPOWER 0', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
assert(str2num(answer) == 300);

% Set power to 200 mW
step = utils.stepFactory('MPB Laser 642', 'set power', 200);
eval(step.cmd);
pause(2);
g_mmc.setSerialPortCommand(port, 'GETPOWER 0', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
assert(str2num(answer) == 200);

% Turn laser off
step = utils.stepFactory('MPB Laser 642', 'turn off', []);
eval(step.cmd);
pause(8);
g_mmc.setSerialPortCommand(port, 'GETLDENABLE', cmdTerminator);
answer = g_mmc.getSerialPortAnswer(port, ansTerminator);
pause(0.05);
assert(str2num(answer) == 0);