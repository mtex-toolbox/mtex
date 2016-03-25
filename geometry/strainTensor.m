classdef strainTensor < tensor
  
  methods
    function sT = strainTensor(varargin)

      sT = sT@tensor(varargin{:},'name','strain');
      
    end
  end
  
   
  methods (Static = true)
    
  end
end