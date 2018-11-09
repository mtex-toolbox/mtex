classdef deformationGradientTensor < tensor
  
  methods
    function F = deformationGradientTensor(varargin)
      F = F@tensor(varargin{:},'rank',2);
    end       
  end

end

