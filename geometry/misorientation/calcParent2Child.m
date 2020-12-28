function [p2c, omega] = calcParent2Child(mori,p2c,varargin)
%
% Syntax
%
%   p2c = calcParent(childOri,p2c0)
%
%   p2c = calcParent(c2c,p2c0)
%   p2c = calcParent(c2c,p2c0,'dampingFactor',alpha)
%
%   [p2c, fit] = calcParent(c2c,p2c0)
%
% Input
%  childOri - child @orientation
%  c2c      - child to child mis@orientation
%  p2c0     - initial guess of the parent to child orienation relationship
%
% Output
%  p2c      - parent to child orienation relationship
%  fit      - disorientation angle between all c2c misorientations and the computed one
%
% Options
%  maxIteration - maximum number of iterations (default - 100)
%  threshold    - consider only misorientation within the threshold to the initial p2c (default - 10*degree)
%  dampingFactor - default - 1/numVariants
%
% References
%
% * Tuomo Nyyssönen, <https://www.researchgate.net/deref/http%3A%2F%2Fdx.doi.org%2F10.1007%2Fs11661-018-4904-9?_sg%5B0%5D=gRJGzFvY4PyFk-FFoOIj2jDqqumCsy3e8TU6qDnJoVtZaeUoXjzpsGmpe3TDKsNukQYQX9AtKGniFzbdpymYvzYwhg.5jfOl5Ohgg7pW_6yACRXN3QiR-oTn8UsxZjTbJoS_XqwSaaB7r8NgifJyjSES2iXP6iOVx57sy8HC4q2XyZZaA
% Crystallography, Morphology, and Martensite Transformation of Prior
% Austenite in Intercritically Annealed High-Aluminum Steel>
%

% compute misorientations if pairs of orientations are given
if isa(mori.SS, 'specimenSymmetry'), mori = inv(mori(:,1)) .* mori(:,2); end

% extract options
alpha = get_option(varargin,'dampingFactor', 1/numSym(p2c.CS));
threshold = get_option(varargin,'threshold',inf);
maxIt = get_option(varargin,'maxIterarion',10);

% prepare iterative loop
diso = nan(maxIt,1);
p2cOld = p2c;

disp(' ');
disp(' searching orientation relationship');

% iterate until convergance
for k = 1:maxIt
  
  diso(k) = angle(p2c,p2cOld)/degree;
  p2cOld = p2c;
    
  %check for convergence
  if k>5 && median(diso(k-5:k)) < 0.5, break; end
  
  % child to child misorientation variants
  c2c = p2c * inv(p2c.variants); %#ok<MINV>
  
  if length(mori) > 50000
    moriSub = discreteSample(mori,50000);
  else
    moriSub = mori;
  end
  
  % misorientation to c2c variants
  omega = angle_outer(moriSub, c2c);
  
  % compute best fitting variant
  [omega, variant] = min(omega,[],2);  
  
  % take only those c2c misorientations that are suffiently close to the
  % current candidate
  ind = omega < min(threshold, quantile(omega, 0.5));
  
  % current fit
  disp(['  ' char(p2c) ' ' xnum2str(mean(omega(ind)) ./ degree)])
  
  % comute p2c misorientations for all variants
  p2cCandidates = [];
  for iv = 1:length(c2c)
    
    if ~any(ind & variant==iv), continue; end
    
    mori_v = project2FundamentalRegion(moriSub(ind & variant==iv), c2c(iv));
    
    p2cCandidates = [p2cCandidates; mori_v * p2c.variants(iv)]; %#ok<AGROW>
    %p2cCandidates(iv) = mean(mori_v * p2c.variants(iv));
    
  end
  
  p2c = mean([p2c,mean(p2cCandidates)],'weights',[alpha 1]);
  
end

disp(' ');
