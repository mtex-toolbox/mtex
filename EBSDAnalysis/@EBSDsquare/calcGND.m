function gnd = calcGND(ebsd,varargin)
% compute the geometrically necessary dislocation
%
% Formulae are taken from the paper
% Resolving the geometrically necessary dislocation content by
% conventional electron backscattering diffraction
% authors: Pantleon
% Scripta Materialia, 2008
%
% Syntax
%   gnd = calcGND(ebsd)
%
% Input
%  ebsd - @EBSDSquare
%
% Output

% compute the gradients
gX = double(ebsd.gradientX(:));
gY = double(ebsd.gradientY(:));

% initialize an empty matrix for the dislocation tensor
kappa = zeros(3,3);

% initalize the ouput
gnd = nan(size(ebsd));

% compute the GND
for i = 1:length(ebsd)
  
  kappa(1,:) = gX(i,:);
  kappa(2,:) = gY(i,:);

  alpha = kappa - trace(kappa)*eye(3);
    
  gnd(i) = norm(alpha,2);
  
end
