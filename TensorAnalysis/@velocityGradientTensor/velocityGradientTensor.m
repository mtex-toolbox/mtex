classdef velocityGradientTensor < tensor
% class representing a velocity gradient tensor
%
% The velocity gradient L is the rank 2 tensor of the spatial derivatives
% of the velocity field. Its symmetric part is the @strainRateTensor, its
% skew symmetric part the @spinTensor. Since solids are not compressible
% all velocity gradient tensors have trace 0.
%
% Syntax
%   L = velocityGradientTensor(M)
%   L = velocityGradientTensor.uniaxial(d,e)
%   L = velocityGradientTensor.simpleShear(d,n,e)
%   L = velocityGradientTensor.pureShear(exp,comp,e)
%
% Input
%  M       - 3x3 matrix
%  d, n    - @vector3d
%  e       - strain rate
%  exp     - extension direction, @vector3d
%  comp    - compression direction, @vector3d
%
% Output
%  L - @velocityGradientTensor
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  CS   - @symmetry the coefficients refer to
%
% Example
%
%   L = velocityGradientTensor.simpleShear(vector3d.X,vector3d.Z)
%
% See also
% tensor strainRateTensor spinTensor
%

  methods
    function L = velocityGradientTensor(varargin)
      L = L@tensor(varargin{:},'rank',2);
    end    

    function E = sym(L)
      E = strainRateTensor(sym@tensor(L));
    end
    
    function R = antiSym(L)
      R = spinTensor(antiSym@tensor(L));
    end

  end
  
   
  methods (Static = true)
    
    
    L = uniaxial(d,e)
    
    L = pureShear(exp,comp,e)

    L = simpleShear(d,n,e)
    
    
    % TODO    
    %function L = planeStrain(v1,v2,gamma)      
    %  
    %  L = velocityGradientTensor();
    %end

    function L = spin(varargin)
      % define a spin tensor
      
      L = spinTensor(varargin{:});

    end
  end
end
