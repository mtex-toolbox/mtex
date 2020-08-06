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
if alpha > 0, weights = [alpha,ones(1,length(mori))./length(mori)]; end

% do some iterations
for k = 1:6

  % child to child misorientation variants
  c2c = p2c * inv(p2c.variants); %#ok<MINV>

  % misorientation to c2c variants
  omega = angle_outer(mori, c2c);
  
  [omega, variant] = min(omega,[],2);
  
  ind = omega < min(5*degree, quantile(omega, 0.9));
  
  if alpha > 0
    fcc2bccCandidate = [];   
  else
    fcc2bccCandidate = p2c;
  end
  
  for iv = 1:length(c2c)
    
    if ~any(ind & variant==iv), continue; end
    
    mori_v = project2FundamentalRegion(mori(ind & variant==iv), c2c(iv));
    
    fcc2bccCandidate = [fcc2bccCandidate,mean(mori_v * p2c.variants(iv))]; %#ok<AGROW>
    
  end
  
  % compute weighted mean if required
  if alpha > 0
    p2c = mean(fcc2bccCandidate,'weigths',weights);
  else
    p2c = mean(fcc2bccCandidate);
  end

end
