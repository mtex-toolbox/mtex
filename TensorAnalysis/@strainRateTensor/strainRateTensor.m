classdef strainRateTensor < velocityGradientTensor
% class representing a strain rate tensor
%
% The strain rate tensor is the symmetric part of a
% @velocityGradientTensor. Whatever matrix is passed in, the constructor
% keeps only that symmetric part.
%
% Syntax
%   E = strainRateTensor(M)
%   E = strainRateTensor(L)
%
% Input
%  M - 3x3 matrix
%  L - @velocityGradientTensor
%
% Output
%  E - @strainRateTensor
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  CS   - @symmetry the coefficients refer to
%
% Example
%
%   E = strainRateTensor(velocityGradientTensor.uniaxial(vector3d.Z,1))
%
% See also
% tensor velocityGradientTensor strainTensor
%

  
  properties
    
  end
  
  methods

    function E = strainRateTensor(varargin)
            
      E = E@velocityGradientTensor(varargin{:},'rank',2);
      
      % ensure it is antisymmetric
      E.M = 0.5*(E.M + permute(E.M,[2 1 3:ndims(E.M)]));
      
    end
    

  end
     
  
end

