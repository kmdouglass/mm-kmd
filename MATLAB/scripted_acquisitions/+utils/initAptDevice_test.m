% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)
%
% Run this file with the command
%
%   result = runtests('utils.launchAptDevice_test');
%
% This test requires that an APT simulation environment be enabled with a
% simulated BSC 101 stepper driver whose serial number is 40001010. For
% more information on how to enable this environment in APT Config, see
% <https://www.thorlabs.com/tutorials/APT%20Config/APT%20Config%20-%20Simulator%20Setup/APT%20Config%20-%20Simulator%20Setup.htm>

% preconditions
progid = 'MGMOTOR.MGMotorCtrl.1';
serialNumber = 40001010;

close all

%% Test 1: Load APT Device and move it 25 units
[h, ~] = utils.launchAptDevice(progid, serialNumber);
h.SetJogStepSize(0, 25);
h.MoveJog(0,1);
pause(5); % Wait for jog
assert(h.GetPosition_Position(0) == 25);

close all
clear h

%% Test 2: Load the APT Device and home it on initialization
[~, ~] = utils.launchAptDevice(...
    progid, serialNumber, 'initFunc', 'MoveHome(0,0)');

close all

%% Test 3: Set the figure name to 'Motor'
[~, f] = utils.launchAptDevice(...
    progid, serialNumber, 'figName', 'Motor');
assert(strcmp(get(f, 'Name'), 'Motor'));

close all
clear f

%% Test 4: Set figure position to 200, 250 and the width/height to 300/200
[~, f] = utils.launchAptDevice(...
    progid, serialNumber, 'fpos', [200, 250, 300, 200]);
fpos = get(f, 'Position');
assert(all(fpos == [200, 250, 300, 200]));

close all
clear f

%% Test 5: Launch device with all optional parameters
[~, f] = utils.launchAptDevice(                         ...
    progid, serialNumber, 'fpos', [200, 250, 300, 200], ...
    'initFunc', 'MoveHome(0,0)', 'figName', 'Motor');

assert(strcmp(get(f, 'Name'), 'Motor'));

fpos = get(f, 'Position');
assert(all(fpos == [200, 250, 300, 200]));

close all
clear f