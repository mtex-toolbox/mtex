function  peri = perimeter(grains,varargin)
% calculates the perimeter of a grain without or without inclusions
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

poly = grains.poly;

% remove inclusions
if ~check_option(varargin,'withInclusion')
  incl = grains.inclusionId;
  for i = find(incl>0).'
    poly{i} = poly{i}(1:end-incl(i));
  end
end

V = grains.V;
peri =  cellfun(@(ind) sum(sqrt(sum(diff(V(ind,:)).^2,2))),poly);
