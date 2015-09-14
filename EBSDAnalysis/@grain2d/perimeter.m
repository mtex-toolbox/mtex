function  peri = perimeter(grains,varargin)
% calculates the perimeter of a grain without holes
%
% Syntax
%
% grains.perimeter
%
% Input
%  grains - @grain2d
%
% Output
%  peri - perimeter
%
% See also
% grain2d/equivalentPerimeter

% ignore holes
poly = cellfun(@(x) x(1:(1+find(x(2:end) == x(1),1))),grains.poly,'uniformOutput',false);

peri =  cellfun(@(ind) sum(sqrt(sum(diff(grains.V(ind,:)).^2,2))),poly);
  
