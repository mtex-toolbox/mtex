classdef strainRateTensor < tensor
  %STRAINRATETENSOR Summary of this class goes here
  %   Detailed explanation goes here
  % 
  % E = 0.5*(J + J^T) % symmetric part
  % R = 0.5*(J - J^T) % rotational part
  %
  
  
  properties
    
  end
  
  methods
    function J = strainRateTensor()
      
      
      
      
    end
    
    function outputArg = method1(obj,inputArg)
      %METHOD1 Summary of this method goes here
      %   Detailed explanation goes here
      outputArg = obj.Property1 + inputArg;
    end
  end
  
  methods (Static=true)
    
    
    function srT = simpleShear(cs)
    end
    
    function srT = pureShear(cs)
    end
    
    
  end
  
  
end

