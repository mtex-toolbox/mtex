classdef stiffnessTensor < tensor
  
  methods
    function sT = stiffnessTensor(varargin)

      varargin = set_default_option(varargin,{},'unit','GPa');
      sT = sT@tensor(varargin{:},'name','stiffness');
      sT.doubleConvention = false;
      
    end
  end
  
   
  methods (Static = true)
  
  end
end