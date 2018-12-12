classdef complianceTensor < tensor
  
  methods
    function sT = complianceTensor(varargin)
      
      varargin = set_default_option(varargin,{},'unit','1/GPa','doubleConvention');
      sT = sT@tensor(varargin{:},'rank',4);
      
    end
  end
  
   
  methods (Static = true)
    function C = load(varargin)
      T = load@tensor(varargin{:});
      C = complianceTensor(T);
    end
  end
end