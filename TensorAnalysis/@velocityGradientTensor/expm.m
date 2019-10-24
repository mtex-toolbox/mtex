function F = expm(L,t)
% deformation gradient tensor from velocity gradient tensor
%
% Syntax
%   F = expm(L)
%   F = expm(L,t)
%
% Input
%  L - @velocityGradientTensor
%  t - time
%
% Output
%  F - @deformationGradientTensor
%

if nargin == 1, t = 1; end
F = deformationGradientTensor(expm@tensor(t.*L));

end

