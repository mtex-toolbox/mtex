classdef strainRateTensor < velocityGradientTensor
  % strainRateTensor is the symmetric part of a velocity gradient tensor
    
  
  properties
    
  end
  
  methods

    function E = strainRateTensor(varargin)
            
      E = E@velocityGradientTensor(varargin{:},'rank',2);
      
      % ensure it is antisymmetric
      E.M = 0.5*(E.M + permute(E.M,[2 1 3:ndims(E.M)]));
      
    end
    

  end
     
  
end

