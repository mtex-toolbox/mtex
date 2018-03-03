classdef refractiveIndexTensor < tensor
  
  
  methods
    
    
    function rI = refractiveIndexTensor(varargin)
      rI = rI@tensor(varargin{:});
    end
    
    
  end
  
  
  methods (Static = true)
    function rI = calcite
      cs = crystalSymmetry('-3m1',[5,5,17],'mineral','Calcite','X||a');
      rI = refractiveIndexTensor(diag([1.66 1.66 1.486]),cs);
    end
    
    function test
      rI = refractiveIndexTensor.calcite;
      
      vprop = plotS2Grid;
      
      n = rI.birefringence(vprop);
      
      plot3d(vprop,n)
      
    end
  end

end