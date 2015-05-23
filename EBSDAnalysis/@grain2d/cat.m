function grains = cat(dim,varargin)
% concatenation of grains from the same GrainSet
%
% Syntax
%   g = [grains_1, grains_2, grains_n]
%
% Example
%   g = [grains('fe') grains('mg')]
%   g = [grains(1:100) grains(500:end)]
%
% See also
% GrainSet/vertcat

grains = cat@dynProp(1,varargin{:});

for k = 2:numel(varargin)

  ng = varargin{k};
  
  grains.id = [grains.id; ng.id];
  grains.phaseId = [grains.phaseId; ng.phaseId];
  grains.grainSize = [grains.grainSize; ng.grainSize];
  grains.poly = [grains.poly; ng.poly];
  grains.boundary = [grains.boundary; ng.boundary];
  grains.innerBoundary = [grains.innerBoundary; ng.innerBoundary];
  
end
