function grains = cat(~,varargin)
% implements [grain1, grain2]
%
% Syntax
%   g = [grains_1, grains_2, grains_n]
%   g = [grains('fe') grains('mg')]
%   g = [grains(1:100) grains(500:end)]
%
% Input
%  grains - @grain3d
%

grains = cat@dynProp(1,varargin{:});

for k = 2:numel(varargin)

  ng = varargin{k};

  if isempty(ng), continue; end

  [grains.id, ~, IB] = union(grains.id, ng.id, 'stable');
  ng=subSet(ng,IB);

  grains.I_CF = [grains.I_CF ; ng.I_CF];
  grains.phaseId = [grains.phaseId; ng.phaseId];
  grains.grainSize = [grains.grainSize; ng.grainSize];

  grains.boundary = cat(1,grains.boundary, ng.boundary);

end
end

