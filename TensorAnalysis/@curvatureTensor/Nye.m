function alpha = dislocationTensor(kappa)
% compute the tensor from a complete curvature tensor
%
% Syntax
%   alpha = NyeTensor(kappa)
%
% Input
%  kappa - complete curvature tensor
%
% Output
%  alpha - 

alpha = dislocationTensor( -trace(kappa) * tensor.eye + kappa');
