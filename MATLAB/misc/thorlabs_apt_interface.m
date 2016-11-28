clear; close all; clc;
global h;

%% Create Matlab Figure Container
fpos    = get(0,'DefaultFigurePosition'); % figure default position
fpos(3) = 650; % figure window size;Width
fpos(4) = 450; % Height
 
f = figure('Position', fpos,...
           'Menu','None',...
           'Name','APT GUI');

h = actxcontrol('MGMOTOR.MGMotorCtrl.1', [20 20 600 400], f);

%% Initialize
% Start Control
h.StartCtrl;
 
% Set the Serial Number
SN = 40866523; % put in the serial number of the hardware
set(h,'HWSerialNum', SN);
 
% Indentify the device
h.Identify;
 
pause(5); % waiting for the GUI to load up;