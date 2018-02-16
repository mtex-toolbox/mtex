classdef complianceTensor < tensor
  
  methods
    function sT = complianceTensor(varargin)

      sT = sT@tensor(varargin{:},'name','compliance');
      
    end
  end
  
   
  methods (Static = true)
  
  end
end