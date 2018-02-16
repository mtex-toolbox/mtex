classdef ChristoffelTensor < tensor
  
  methods
    function sT = ChristoffelTensor(varargin)

      sT = sT@tensor(varargin{:},'name','Chistoffel');
      
    end
  end
  
   
  methods (Static = true)
  
  end
end