% Runs an acquisition script.
%
% Author:  Kyle M. Douglass
% E-mail:  kyle.m.douglass@gmail.com
% License: MIT
%
% Copyright (c) 2016 ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE, Switzerland
% Laboratory of Experimental Biophysics (LEB)


classdef scriptEngine < handle
    % stepEngine runs a series of steps in a scripted acquisition.
    
    properties
        script = {};
    end
    
    methods
        function run(obj)
            % Runs the steps in a scripted acquistion.
            if isempty(obj.script)
                error('Error: script attribute is empty.');
            end
            
            % Primary script loop
            for ctr = 1:length(obj.script)
                currStep = obj.script{ctr};
                
                obj.pause(currStep.pauseBefore);
                currStep.cmd();
                obj.pause(currStep.pauseAfter);
                
            end
        end
        
        function pause(obj, time)
            % Overload MATLAB's pause() to convert from millisec. to sec.
            pause(time / 1000);
        end
    end
    
end