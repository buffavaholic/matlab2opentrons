classdef Driver
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % Sub classes to populate
        Com
        Deck
        
    end
    
    methods
        
        function LH = Driver
            LH.Com = LiquidHandler.ComDriver;
            
            
        end
    end
    
end

