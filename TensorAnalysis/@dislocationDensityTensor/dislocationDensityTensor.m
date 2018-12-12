classdef dislocationDensityTensor < tensor
% dislocation density or Nye tensor
  
  methods
    function alpha = dislocationDensityTensor(varargin)
      alpha = alpha@tensor(varargin{:},'rank',2);
    end
  end
  
end