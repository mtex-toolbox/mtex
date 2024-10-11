classdef stressTensor < tensor
%
% The class |stressTensor| describes a (list) of stress tensors.
%
% Syntax
%
%   % specify stress tensor by matrix
%   M = [1 0 0; 0 0 0; 0 0 0];
%   sigma = stressTensor(M)
%
%   % uniaxial stress in direction v
%   sigma = stressTensor.uniaxial(v)
%
% Input
%  M - 3x3 symmetric matrix
%  v - @vector3d
%
% Output
%  sigma - @stressTensor
%
% See also
% slipSystem.SchmidFactor
%

  methods
    function sT = stressTensor(varargin)

      sT = sT@tensor(varargin{:},'rank',2);
      if ~sT.isSymmetric, warning('Tensor is not symmetric!'); end

    end
  end
  
   
  methods (Static = true)

    function sigma = load(varargin)
      T = load@tensor(varargin{:});
      sigma = stressTensor(T);
    end
    
    function sigma = uniaxial(v)
      % define uniaxial stress tensor
      %
      % Syntax
      %   sigma = stressTensor.uniaxial(v)
      %
      % Input
      %  v - @vector3d loading direction
      %
      % Output
      %  sigma - @stressTensor
      %
           
      sigma = stressTensor(dyad(v,2));

    end
   
    function sigma = rand(varargin)
      t = tensor.rand(varargin{:},'rank',2);
      sigma = stressTensor(t.sym);
    end

  end
end