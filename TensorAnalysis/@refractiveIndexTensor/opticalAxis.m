function oA = opticalAxis(rI)
% optical axis or axes for a refractive index tensor
%
% Syntax
%   oA = opticalAxis(rI)
%
% Input
%  rI - @refractiveIndexTensor
%
% Output
%  oA - @vector3d
%

[lambda,v] = eig3(rI());


