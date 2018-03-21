classdef dislocationTensor < tensor
% dislocation or   
  
  methods
    function alpha = dislocationTensor(varargin)
      alpha = alpha@tensor(varargin{:});
    end
  end
  
end