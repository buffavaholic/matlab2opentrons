classdef LiquidHandler < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Sub classes to populate
        Com
        Deck
        
    end
    
    methods
        
        function LH = LiquidHandler
            LH.Com = ComDriver;
            
            
        end
    end
    
end

