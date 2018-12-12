classdef stiffnessTensor < tensor
  
  methods
    function sT = stiffnessTensor(varargin)

      varargin = set_default_option(varargin,{},'unit','GPa');
      sT = sT@tensor(varargin{:},'rank',4);
      sT.doubleConvention = false;
      
    end
  end
  
   
  methods (Static = true)
    function C = load(varargin)
      T = load@tensor(varargin{:});
      C = stiffnessTensor(T);
    end
  end
end