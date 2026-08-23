classdef strainTensor < tensor
% class representing a strain tensor
%
% The strain tensor is the symmetric rank 2 tensor describing a finite
% deformation. Depending on whether it is referred to the undeformed or
% the deformed configuration it is of type Lagrange, the default, or of
% type Euler. The constructor warns if the matrix is not symmetric.
%
% Syntax
%   eps = strainTensor(M)
%   eps = strainTensor(M,cs)
%   eps = strainTensor(M,'type','Euler')
%
% Input
%  M  - 3x3 matrix
%  cs - crystal @symmetry
%
% Output
%  eps - @strainTensor
%
% Options
%  type - 'Lagrange' or 'Euler'
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  type - 'Lagrange' or 'Euler', read only
%  CS   - @symmetry the coefficients refer to
%
% Example
%
%   eps = strainTensor(diag([1 0 -1]))
%
% See also
% tensor strainRateTensor stressTensor
%

  properties (SetAccess=protected)
    type % 'Lagrange' % 'Euler'
  end  
    
  methods
    function sT = strainTensor(varargin)
      if ~check_option(varargin,'type')
         varargin = set_option(varargin,'type','Lagrange');
      end
      sT = sT@tensor(varargin{:},'rank',2);
      if ~all(sT.isSymmetric), warning('Tensor is not symmetric!'); end
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

