function  peri = perimeter(grains,varargin)
% calculates the perimeter of a grain with or without inclusions
%
% Syntax
%
%   grains.perimeter
%   perimter(grains)
%   perimter(grains,'withInclusions')
%
% Input
%  grains - @grain2d
%
% Output
%  peri - perimeter (in measurement units)
%
% See also
% grain2d/equivalentPerimeter


if check_option(varargin,'withInclusion')
  
  bnd = grains.boundary;
  grainId = bnd.grainId;
  segLength = bnd.segLength;

  isGrain1 = grainId(:,1)>0;
  isGrain2 = grainId(:,2)>0;
  peri = accumarray(grainId(isGrain1,1),segLength(isGrain1),[max(grainId(:)),1]) ...
    + accumarray(grainId(isGrain2,2),segLength(isGrain2),[max(grainId(:)),1]);

  peri = peri(grains.id);

else
  
  poly = grains.poly;

  % remove inclusions
  incl = grains.inclusionId;
  for i = find(incl>0).'
    poly{i} = poly{i}(1:end-incl(i));
  end

  V = grains.V;

  peri =  cellfun(@(ind) sum(sqrt(sum(diff(V(ind,:)).^2,2))),poly);
  
end
