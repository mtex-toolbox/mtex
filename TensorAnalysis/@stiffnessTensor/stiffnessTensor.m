classdef stiffnessTensor < tensor
  
  methods
    function sT = stiffnessTensor(varargin)

      sT = sT@tensor(varargin{:},'name','stiffness');
      
    end
  end
  
   
  methods (Static = true)
  
  end
end