classdef curvatureTensor < tensor
% class representing the lattice curvature tensor
%
% The curvature tensor collects the spatial derivatives of the orientation
% field. In MTEX it is computed from an @EBSD map or from a list of grains
% by the method curvature, and is the quantity the
% @dislocationDensityTensor is derived from.
%
% Since a two dimensional EBSD map gives no derivative in z direction, the
% third column of the tensor is NaN there.
%
% Syntax
%   kappa = curvatureTensor(M,cs)
%
% Input
%  M  - 3x3 matrix
%  cs - crystal @symmetry
%
% Output
%  kappa - @curvatureTensor
%
% Class Properties
%  M    - the tensor coefficients
%  rank - always 2
%  CS   - @symmetry the coefficients refer to
%
% See also
% tensor dislocationDensityTensor EBSD.curvature
%

  methods
    function kappa = curvatureTensor(varargin)
      kappa = kappa@tensor(varargin{:},'rank',2);
    end
  end
  
end