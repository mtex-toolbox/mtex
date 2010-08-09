function  peri = perimeter(p)
% calculates the perimeter of the grain-polygon, without holes
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

lengths = @(xy) sum(sqrt(sum(diff(xy).^2,2)));

peri = zeros(size(p));
for k=1:numel(p)
  peri(k) = lengths(p(k).xy); 
end
