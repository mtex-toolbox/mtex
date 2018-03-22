function kappa = curvature(ebsd,varargin)
% computes the incomplete curvature tensor
%
% Syntax
%   kappa = curvature(ebsd)
%
% Input
%  ebsd - @EBSDSquare
%
% Output
%  kappa - @curvatureTensor
 
% set up curvature tensor
% first column is gradients in x-direction in specimen coordiantes
% second column is gradients in y-direction in specimen coordiantes
kappa = dyad(ebsd.gradientX,tensor([1;0;0])) + ...
  dyad(ebsd.gradientY,tensor([0;1;0]));

% third column should be NaN as we have only 2d data
kappa{:,3} = NaN;

% make it a curvature tensor
kappa = curvatureTensor(kappa,'unit',['1/' ebsd.scanUnit]);

end
