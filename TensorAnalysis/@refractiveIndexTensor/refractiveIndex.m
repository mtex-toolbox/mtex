function n = refractiveIndex(varargin)
% refractive index with respect to a propagation direction
%
% Syntax
%   n = refractiveIndex(rI,vProp)
%   n = refractiveIndex(rI)
%
% Input
%  rI - @reactiveIndexTensor
%  vProp - propagation direction @vector3d
%
% Output
%  n - refractive index
%  n - @S2FunHarmonic

n = directionalMagnitude(varargin{:});

end
