function [fit, pairs] = calcGBFit(job,varargin)
% fit between child to child misorientations and job.p2c
%
% Syntax
%
%   [fit, pairs] = job.calcGBFit
%
%   % visualize the result
%   [gB, pairId] = job.grains.boundary.selectByGrainId(pairs);
%   plot(gB, fit(pairId) ./ degree, 'linewidth',2);
%   setColorRange([2,8])
%   mtexColorMap white2black
%
%   % consider only P2C neighbors
%   [fit, p2cPairs] = job.calcGBFit('p2c')
%
%   % consider only C2C neighbors
%   [fit, c2cPairs] = job.calcGBFit('c2c')
%s
% Input
%  job - @parentGrainReconstructor
%
% Output
%  fit   - fit between the grain boundary misorientations and job.p2c
%  pairs - list of grainId of the neighboring grains
%

noOpt = ~check_option(varargin,{'p2c','c2c'});

% parent to child neighbors
if noOpt || check_option(varargin,'p2c')
  
  % extract all parent to child neighbors
  [pairs, oriParent, oriChild] = getP2CPairs(job, varargin{:});
  
  % compute the misorientation
  mori = inv(oriChild).*oriParent;
  
  % compute the fit
  fit = angle(mori, job.p2c);
  
else
  
  fit = []; 
  pairs = [];
  
end
  
if noOpt || check_option(varargin,'c2c')

  % extract all child to child neighbors
  [c2cPairs, oriChild] = getC2CPairs(job, varargin{:});
  pairs = [pairs;c2cPairs];
  
  % compute the corresponding misorientations
  mori = inv(oriChild(:,1)).*oriChild(:,2);
  
  % misorientation to c2c variants
  fit = [fit;min(angle_outer(mori, job.c2c),[],2)];
  
end