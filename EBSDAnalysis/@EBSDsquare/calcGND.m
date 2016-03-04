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

  % the first two columns of the dislocation tensor are just
  % the texture gradients
  kappa(1,:) = gX(i,:);
  kappa(2,:) = gY(i,:);

  % as we do not know the texture gradient with respect to the z-direction
  % we should add least guaranty that the trace of the tensor is zero, i.e.,
  % it is volume preserving
  % TODO!!!
  % alpha = kappa - trace(kappa)*eye(3);
  kappa(3,3) = - kappa(1,1) - kappa(2,2);
    
  gnd(i) = norm(alpha,2);
  
end
