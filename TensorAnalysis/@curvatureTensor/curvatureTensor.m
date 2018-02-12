classdef curvatureTensor < tensor
  
  methods
    function kappa = curvatureTensor(varargin)
      kappa = kappa@tensor(varargin{:});
    end
  end
  
end