function kappa = curvature(alpha)
% compute curvature tensor from a (complete) dislocation density tensor
%
% Input
%  alpha  - @dislocationDensityTensor
%
% Output
%  kappa - @curvatureTensor

kappa = curvatureTensor( alpha' - 0.5 * diag(tensor(trace(alpha),'rank',0)));