% Clears the com buffer.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)

function handle = clear_com_buffer(~)
% Clears the com buffer.
%
% params is a struct whose fields are described below.
%
% Returns
% -------
% handle : function handle
%   A pointer to a function that executes the desired hardware commands.

global g_comBuffer

%% Device control functions
    function deviceControl()
        % Type the hardware and software instructions here
        g_comBuffer = [];
    end

handle = @() deviceControl();
end

