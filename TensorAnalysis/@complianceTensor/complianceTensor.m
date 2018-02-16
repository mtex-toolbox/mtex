classdef complianceTensor < tensor
  
  methods
    function sT = complianceTensor(varargin)
      
      varargin = set_default_option(varargin,{},'unit','1/GPa','doubleConvention',true);
      sT = sT@tensor(varargin{:},'name','compliance');
      
    end
  end
  
   
  methods (Static = true)
  
  end
end