classdef strainRateTensor < velocityGradientTensor
  % strainRateTensor is the symmetric part of a velocity gradient tensor
    
  
  properties
    
  end
  
  methods

    function E = strainRateTensor(varargin)
            
      E = E@velocityGradientTensor(varargin{:},'rank',2);
      
      % ensure it is antisymmetric
      E.M = 0.5*(E.M + E.M');
      
    end
    

  end
     
  
end

