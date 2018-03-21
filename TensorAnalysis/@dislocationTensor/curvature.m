function kappa = curvature(alpha)
% compute curvature tensor from a complete dislocation tensor
%
% Input
%  alpha  - @NyeTensor
%
% Output
%  kappa - @curvatureTensor

kappa = curvatureTensor(alpha' - 0.5 * diag(tensor(trace(alpha),'rank',0)));