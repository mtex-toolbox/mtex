function  peri = hullperimeter(grains)
% returns the perimeter of grain polygon, without holes
%
%% Input
%  grains - @grain
%
%% Output
%  peri   - perimeter
%
%% See also
% grain/borderlength 
%

lengths = @(xy) sum(sqrt(sum(diff(xy).^2,2)));

nc = length(grains);
peri = zeros(size(grains));

%without respect to holes
p = polygon(grains);
for k=1:nc
  xy = p(k).xy;
  K = convhull(xy(:,1),xy(:,2));
  peri(k) = lengths(xy(K,:)); 
end