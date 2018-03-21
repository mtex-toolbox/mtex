function alpha = dislocationTensor(kappa)
% compute the tensor from a curvature tensor
%
% Syntax
%   alpha = dislocationTensor(kappa)
%
% Input
%  kappa - @curvatureTensor
%
% Output
%  alpha - @dislocationTensor
%

alpha = diag(tensor(-trace(kappa),'rank',0)) + kappa';

% in the special case of 2d data where the last column is NaN we can still
% recover the entry for alpha(3,3)
if all(isnan(alpha.M(3,3,:)))
  alpha{3,3} = -kappa.M(1,1,:,:,:) - kappa.M(2,2,:,:,:);
end

% turn it into a dislocation tensor
alpha = dislocationTensor(alpha);