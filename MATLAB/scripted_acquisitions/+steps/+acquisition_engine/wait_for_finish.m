% Blocks further script execution until an acqusition finishes.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = wait_for_finish(params)
% Blocks further script execution until an acquisition finishes.
%
% params is a struct whose fields are described below.
%
% Parameters
% ----------
% name      : string
%   The name of the device in the global handles structure.
%
% Returns
% -------
% handle : function handle
%   A pointer to a function that executes the desired hardware commands.

global g_gui
global g_mmc
global g_acq

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        disp('Acquisition is running.');
        while g_acq.isAcquisitionRunning()
            pause(1);
            continue;
        end
        disp('Acquisition finished.');
    end

handle = @() deviceControl();
end

