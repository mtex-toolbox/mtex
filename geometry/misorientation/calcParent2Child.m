function [p2c, omega] = calcParent2Child(mori,p2c,varargin)
%
% Syntax
%
%   p2c = calcParent(childOri,p2c)
%
%   p2c = calcParent(mori,p2c)
%
%   [p2c, fit] = calcParent(mori,p2c)
%
% Input
%  childOri - child @orientation
%  c2c_mori - child to child mis@orientation
%  p2c      - initial gues of the parent to child mis@orientation
%
% Output
%  p2c      - parent to child mis@orientation
%  fit      - disorientation angle between all c2d misorientations and the computed one
%
% Description
%
%

if isa(mori.SS, 'specimenSymmetry')
  mori = inv(mori(:,1)) .* mori(:,2);
end

% do some iterations
for k = 1:10

  % child to child misorientation variants
  c2c = p2c * inv(p2c.variants); %#ok<MINV>

  % misorientation to c2c variants
  omega = angle_outer(mori, c2c);
  
  [omega, variant] = min(omega,[],2);
  
  ind = omega < min(5*degree, quantile(omega, 0.9));
  
  fcc2bccCandidate = [];
  for iv = 1:length(c2c)
    
    if ~any(ind & variant==iv), continue; end
    
    mori_v = project2FundamentalRegion(mori(ind & variant==iv), c2c(iv));
    
    fcc2bccCandidate = [fcc2bccCandidate,mean(mori_v * p2c.variants(iv))]; %#ok<AGROW>
    
  end
  
  p2c = mean(fcc2bccCandidate);
   
end
