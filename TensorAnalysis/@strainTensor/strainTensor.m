classdef strainTensor < tensor

  properties (SetAccess=protected)
    type = 'Lagrange' % 'Euler'
  end  
    
  methods
    function sT = strainTensor(varargin)
      sT = sT@tensor(varargin{:},'rank',2);
    end
  end


  methods (Static = true)

    function eps = load(varargin)
      T = load@tensor(varargin{:});
      eps = strainTensor(T);
    end

    function eps = rand(varargin)
      t = tensor.rand(varargin{:},'rank',2);
      eps = strainTensor(t.sym);
    end

  end
end

