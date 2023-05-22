classdef strainTensor < tensor

  properties (SetAccess=protected)
    type % 'Lagrange' % 'Euler'
  end  
    
  methods
    function sT = strainTensor(varargin)
      if ~check_option(varargin,'type')
         varargin = set_option(varargin,'type','Lagrange');
      end
      sT = sT@tensor(varargin{:},'rank',2);
      if ~sT.isSymmetric, warning('Tensor is not symmetric!'); end
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

