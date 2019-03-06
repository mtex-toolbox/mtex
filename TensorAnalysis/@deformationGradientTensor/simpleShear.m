function F = simpleShear(d,n,gamma)
% simple shear deformation tensor
%
% Syntax
%   gamma = 45*degree;
%   F = deformationGradientTensor.simpleShear(d,n,gamma)
%
% Input
%  d - shearing direction @vector3d
%  n - normal or compression direction @vector3d
%  gamma - shearing angle, default are 45 degree
%
% Output
%  L - @deformationGradientTensor
%

if nargin < 2, gamma = 45*degree; end

F = deformationGradientTensor(tan(gamma) .* dyad(d.normalize,n.normalize)) + ...
  tensor.eye;

end
