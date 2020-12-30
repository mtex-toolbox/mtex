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
%   histogram(job.fit ./ degree)
%
% Input
%  job - @parentGrainReconstructor
%
% Output
%  job.p2c - fitted parent to child orientation relationship
%  job.fit - fit between the c2c misorientations to the fitted p2c
%
% Options
%  noC2C - do not consider child to child misorientations
%  noP2C - do not consider parent to child misorientations
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

% get p2c from parent 2 child OR
if nnz(job.ebsd.phaseId==job.parentPhaseId) > 0.01 * length(job.ebsd)
  
  p2cPairs = neighbors(job.grains(job.csParent),job.grains(job.csChild));

  p2cData = mean(inv(job.grains(p2cPairs(:,2)).meanOrientation) .* job.grains(p2cPairs(:,1)).meanOrientation,'robust');
  p2c0 = p2cData;
  
else % some default parent2child orientation relationship
  
  p2cData = [];
  p2c0 = orientation.KurdjumovSachs(job.csParent,job.csChild);
  
end

if check_option(varargin,'noC2C')

  job.p2c = p2c0;
  
else % consider also child to child 
  
  % get neighbouring grain pairs
  c2cPairs = job.grains(job.csChild).neighbors;

  if ~isempty(job.p2c), p2c0 = job.p2c; end
  p2c0 = getClass(varargin,'orientation',p2c0);

  oriChild = reshape(job.grains('id',c2cPairs).meanOrientation,[],2);
  mori = inv(oriChild(:,1)).*oriChild(:,2);

  % ignore pairs with misorientation angle smaller then 5 degree
  mori(mori.angle < 5 * degree) = [];
    
  % compute an optimal parent to child orientation relationship
  if check_option(varargin,'v3')
    
   job.p2c = fitP2C(mori,p2c0);
    
  elseif check_option(varargin,'v2')
    
    [job.p2c, job.fit] = calcParent2Child2(mori,p2c0);
    
  else
   
    [job.p2c, job.fit] = calcParent2Child(mori,p2c0,varargin{:});
    
  end
  
  % combine p2c and c2c orientation relationships
  if ~isempty(p2cData) && ~check_option(varargin,'noP2C')
    
    job.p2c = mean([job.p2c,p2cData],'weights',[length(c2cPairs),length(p2cPairs)]);
    
  end
    
end
   
end