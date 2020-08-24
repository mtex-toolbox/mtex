function [p2c, omega] = calcParent2Child(mori,p2c,alpha,varargin)
%
% Syntax
%
%   p2c = calcParent(childOri,p2c)
%
%   p2c = calcParent(c2c,p2c)
%   p2c = calcParent(c2c,p2c,alpha)
%
%   [p2c, fit] = calcParent(c2c,p2c)
%
% Input
%  childOri - child @orientation
%  c2c      - child to child mis@orientation
%  p2c      - initial gues of the parent to child mis@orientation
%  alpha    - damping factor
%
% Output
%  p2c      - parent to child mis@orientation
%  fit      - disorientation angle between all c2cs misorientations and the computed one
%
% Description
%
%

% compute misorientations if pairs of orientations are given
if isa(mori.SS, 'specimenSymmetry'), mori = inv(mori(:,1)) .* mori(:,2); end

% third input is damping factor
if nargin<3, alpha = 0; end

% prepare iterative loop
maxIt = 100;
diso = nan(maxIt,1);
p2cOld = p2c;

% iterate until convergance
for k = 1:maxIt
  
  diso(k) = angle(p2c,p2cOld)/degree;
  p2cOld = p2c;
  
  %check for convergence
  if k>5 && norm(diso(k-5:k)) < 0.1, break; end
  
  % child to child misorientation variants
  c2c = p2c * inv(p2c.variants); %#ok<MINV>

  % misorientation to c2c variants
  omega = angle_outer(mori, c2c);
  
  % compute best fitting variant
  [omega, variant] = min(omega,[],2);  
  
  % take only those c2c misorientations that are suffiently close to the
  % current candidate
  ind = omega < min(5*degree, quantile(omega, 0.9));
  
  % comute p2c misorientations for all variants
  p2cCandidates = [];
  for iv = 1:length(c2c)
    
    if ~any(ind & variant==iv), continue; end
    
    mori_v = project2FundamentalRegion(mori(ind & variant==iv), c2c(iv));
    
    p2cCandidates = [p2cCandidates, mori_v * p2c.variants(iv)]; %#ok<AGROW>
    
  end
  
  % compute damped mean if required
  if alpha > 0
    
    weights = [alpha,ones(1,length(p2cCandidates)) ./ length(p2cCandidates)];
    
    p2c = mean([p2c,p2cCandidates],'weigths',weights);
  else
    p2c = mean(p2cCandidates);
  end

end

if k<maxIt
  fprintf('-> Convergence reached after %.0f iterations\n',k);
else
  fprintf('-> Refinement stopped at maximum number of iterations: %.0f without convergence \n',maxIt);
end