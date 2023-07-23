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

  [grains.id, ~, IB] = union(grains.id, ng.id);
  ng=subSet(ng,IB);
  
  grains.phaseId = [grains.phaseId; ng.phaseId];
  grains.grainSize = [grains.grainSize; ng.grainSize];

  [grains.boundary, IA_poly, IC_poly ] = cat(1,grains.boundary, ng.boundary);

  grains.I_CF = [grains.I_CF , zeros(size(grains.I_CF, 1),size(ng.I_CF,2))];
  grains.I_CF = [grains.I_CF ; ...
    [zeros(size(ng.I_CF,1),(size(grains.I_CF,2)-size(ng.I_CF,2))) , ng.I_CF]];
  for i = size(ng.I_CF,2):size(grains.I_CF,2)
    if (IC_poly(i)~=i)
      grains.I_CF(:,IC_poly(i)) = grains.I_CF(:,IC_poly(i))+grains.I_CF(:,i);
    end
  end
  grains.I_CF=grains.I_CF(:,IA_poly);

end
end

