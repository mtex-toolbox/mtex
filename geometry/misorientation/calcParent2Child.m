function [p2cOld, omega] = calcParent2Child(mori,p2c,varargin)
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
%  p2c0     - initial guess of the parent to child orientation relationship
%
% Output
%  p2c      - parent to child orientation relationship
%  fit      - disorientation angle between all c2c misorientations and the computed one
%
% Options
%  maxIteration - maximum number of iterations (default - 100)
%  quantile     - consider only misorientation within this quantile to the current p2c guess (default 0.9)
%  threshold    - consider only misorientation within this threshold to the current p2c guess (default - 10*degree)
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
quant = get_option(varargin,'quantile',0.9);
maxIt = get_option(varargin,'maxIterarion',10);

% prepare iterative loop
p2cOld = p2c;
bestFit = inf;

vdisp(' ',varargin{:});
vdisp(' optimizing parent to child orientation relationship',varargin{:});

% iterate
k = 1;
while k <= maxIt
  
  % stop iteration if convergence
  if k>1 && angle(p2c,p2cOld) < 0.1*degree, break; end
      
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
  
  % take only those c2c misorientations that are sufficiently close to the
  % current candidate
  ind = omega < min(threshold, quantile(omega, quant));
  
  % current fit
  misFit = mean(omega(ind));

  if misFit > bestFit
    
    alpha = (alpha + 0.1) * 2;
        
  else
  
    k = k + 1;
    vdisp(['  ' fillStr(char(p2c,'Euler'),22) xnum2str(misFit ./ degree)],varargin{:})
    bestFit = misFit;
    p2cOld = p2c;
  
    % compute p2c misorientations for all variants
    p2cCandidates = [];
    for iv = 1:length(c2c)
    
      if ~any(ind & variant==iv), continue; end
    
      mori_v = project2FundamentalRegion(moriSub(ind & variant==iv), c2c(iv));
    
      p2cCandidates = [p2cCandidates; mori_v * p2c.variants(iv)]; %#ok<AGROW>
      %p2cCandidates(iv) = mean(mori_v * p2c.variants(iv));
    
    end
  end 

  p2c = mean([p2cOld,mean(p2cCandidates)],'weights',[alpha 1]);
  
end

vdisp(' ',varargin{:});
