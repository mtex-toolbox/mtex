classdef stiffnessTensor < tensor
  
  methods
    function sT = stiffnessTensor(varargin)

      varargin = set_default_option(varargin,{},'unit','GPa');
      sT = sT@tensor(varargin{:},'rank',4);
      sT.doubleConvention = false;
      
      if ~sT.isSymmetric, warning('Tensor is not symmetric!'); end
      lambda = eig(sT);
      if ~all(lambda(:) > 0), warning('Tensor is not positive definite'); end

    end
  end
  
   
  methods (Static = true)
    function C = load(fname,varargin)
      if ~exist(fname,'file')
        fname = [mtexDataPath filesep 'stiffnessTensor' filesep fname];
      end
      T = load@tensor(fname,varargin{:});
      C = stiffnessTensor(T);
    end
    
    function C = eye(varargin)
      
      C = stiffnessTensor(tensor.eye(varargin{:},'rank',4));
      
    end
    
  end
end