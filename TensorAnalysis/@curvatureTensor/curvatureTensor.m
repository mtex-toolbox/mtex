classdef curvatureTensor < tensor
  
  methods
    function kappa = curvatureTensor(varargin)
      kappa = kappa@tensor(varargin{:},'rank',2);
    end
  end
  
end