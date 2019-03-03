function L = logm(F)
% velocity gradient tensor from deformation gradient tensor
%
% Syntax
%   L = expm(F)
%
% Input
%  F - @deformationGradientTensor 
%
% Output
%  L - @velocityGradientTensor
%

if nargin == 1, t = 1; end
L = velocityGradientTensor(logm@tensor(t.*F));

end

