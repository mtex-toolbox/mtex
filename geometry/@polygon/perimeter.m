function  peri = perimeter(p)
% calculates the perimeter of the grain-polygon, without Holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  peri    - perimeter
%
%% See also
% polygon/equivalentperimeter polygon/borderlength

p = polygon(p);

lengths = @(Vertices) sum(sqrt(sum(diff(Vertices).^2,2)));

peri = zeros(size(p));
for k=1:numel(p)
  peri(k) = lengths(p(k).Vertices); 
end
