function  peri = perimeter(grains,varargin)
% calculates the perimeter of a grain, without holes
%
% Input
%  grains - @grain2d
%
% Output
%  peri - perimeter
%
% Syntax
%   peri = grains.perimeter
%
% See also
% grain2d/equivalentperimeter


% reduce to first loop
poly = cellfun(@(x) x(1:find(x(2:end) == x(1),1)),grains.poly,'uniformOutput',false);

peri =  cellfun(@(ind) sum(sqrt(sum(diff(grains.V(ind,:)).^2,2))),poly);
  
