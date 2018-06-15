function alpha = dislocationDensity(kappa)
% compute the dislocationDensity tensor from a curvature tensor
%
% Syntax
%   alpha = dislocationDensity(kappa)
%
% Input
%  kappa - @curvatureTensor
%
% Output
%  alpha - @dislocationDensityTensor
%

alpha = kappa' - diag(tensor(trace(kappa),'rank',0));

% in the special case of 2d data where the last column is NaN we can still
% recover the entry for alpha(3,3)
if all(isnan(alpha.M(3,3,:)))
  alpha.M(3,3,:,:,:) = -kappa.M(1,1,:,:,:) - kappa.M(2,2,:,:,:);
end

% turn it into a dislocation density tensor
alpha = dislocationDensityTensor(alpha);
