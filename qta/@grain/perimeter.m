function  peri = perimeter(grains)
% calculates the perimeter of the grain-polygon, without holes
%
%% Input
%  grains - @grain
%
%% Output
%  peri    - perimeter
%
%% See also
% grain/equivalentperimeter grain/borderlength


lengths = @(xy) sum(sqrt(sum(diff(xy).^2,2)));

%without respect to holes
p = polygon(grains);
peri = zeros(size(grains));
for k=1:length(grains)
  peri(k) = lengths(p(k).xy); 
end
