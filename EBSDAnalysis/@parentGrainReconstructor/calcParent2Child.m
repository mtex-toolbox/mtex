function job = calcParent2Child(job, varargin)
% compute optimal parent to child orientation relationship
%
% The function |calcParent2Child| uses the parent to child orientation
% relationship stored in |job.p2c| as a starting point for an iterative
% process to find a parent to child orientation
% relationship that best possible fits to the child to child
% misorientations in the measured grain data |job.grains|.
%
% Syntax
%
%   % find optimal parent to child orientation relationship
%   job.calcParent2Child
%
%   % display distribtion of the misfit
%   histogram(job.calcGBFit ./ degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.p2c - fitted parent to child orientation relationship
%
% Options
%  c2c - consider only child to child misorientations
%  p2c - consider only parent to child misorientations
%  peakFitting - use peak fitting algorithm
%  quantile  - consider only misorientation within this quantile to the current p2c guess (default 0.9)
%  threshold - only consider misorientations that are within this threshold of the current parent to child OR guess
%
% References
%
% * Tuomo Nyyssönen, <https://www.researchgate.net/deref/http%3A%2F%2Fdx.doi.org%2F10.1007%2Fs11661-018-4904-9?_sg%5B0%5D=gRJGzFvY4PyFk-FFoOIj2jDqqumCsy3e8TU6qDnJoVtZaeUoXjzpsGmpe3TDKsNukQYQX9AtKGniFzbdpymYvzYwhg.5jfOl5Ohgg7pW_6yACRXN3QiR-oTn8UsxZjTbJoS_XqwSaaB7r8NgifJyjSES2iXP6iOVx57sy8HC4q2XyZZaA
% Crystallography, Morphology, and Martensite Transformation of Prior
% Austenite in Intercritically Annealed High-Aluminum Steel>
%
% See also
% calcParent2Child
%

noOpt = ~check_option(varargin,{'p2c','c2c'});
threshold = get_option(varargin,'threshold',5*degree);
quant = get_option(varargin,'quantile',0.5);

if ~isempty(job.p2c), p2c0 = job.p2c; end
p2c0 = getClass(varargin,'orientation',p2c0);

% get p2c from parent 2 child OR
if nnz(job.ebsdPrior.phaseId==job.parentPhaseId) > 0.01 * length(job.ebsdPrior) ...
    && (noOpt || check_option(varargin,'p2c'))
  
  p2cPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));
  
  p2c = inv(job.grains(p2cPairs(:,2)).meanOrientation) .* ...
    job.grains(p2cPairs(:,1)).meanOrientation;
  
  for k = 1:3
    omega = angle(p2c,p2c0);
    ind = omega < min(threshold, quantile(omega, quant));
    p2c0 = mean(p2c(ind));
  end
  
  if check_option(varargin,'peakFitting')    
    mdf = calcDensity(p2c(ind),'halfwidth',1*degree);
    p2c0 = steepestDescent(mdf,p2c0);
  end
  
  p2cData = p2c0;
  
else % some default parent2child orientation relationship
  
  p2cData = [];
  
end

% consider also child to child 
if (noOpt && angle(p2c0)>5*degree) || check_option(varargin,'c2c') 

  % get neighboring grain pairs
  [c2cPairs, oriChild] = getC2CPairs(job, varargin{:});
  
  % compute c2c misorientation
  mori = inv(oriChild(:,1)) .* oriChild(:,2);

  % ignore pairs with misorientation angle smaller then 5 degree
  mori(mori.angle < 5 * degree) = [];
  
  if ~isempty(job.p2c), p2c0 = job.p2c; end
  p2c0 = getClass(varargin,'orientation',p2c0);
  
  % compute an optimal parent to child orientation relationship
  if check_option(varargin,'v3')
    
   p2c = fitP2C(mori,p2c0);
    
  elseif check_option(varargin,'v2')
    
    p2c = calcParent2Child2(mori,p2c0);
    
  else
   
    p2c = calcParent2Child(mori,p2c0,varargin{:});
    
  end
  
  % combine p2c and c2c orientation relationships
  if ~isempty(p2cData) && ~check_option(varargin,'noP2C')
    
    p2c = mean([p2c,p2cData],'weights',[length(c2cPairs),length(p2cPairs)]);
    
  end    
  
else 

  p2c = p2c0;
  
end

% compute new variantMap
if ~isempty(job.p2c) && length(p2c.variants) == length(job.p2c.variants)
  [~,new2old] = min(angle_outer(p2c.variants,job.p2c.variants,'noSym1'),[],2);
  p2c.opt.variantMap = new2old;
end

% update p2c
job.p2c = p2c;

end