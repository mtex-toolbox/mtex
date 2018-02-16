classdef ChristoffelTensor < tensor
  
  methods
    function sT = ChristoffelTensor(varargin)

      sT = sT@tensor(varargin{:},'name','Christoffel');
      
    end
  end
  
   
  methods (Static = true)
  
  end
end