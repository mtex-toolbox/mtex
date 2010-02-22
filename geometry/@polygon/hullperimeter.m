function  peri = hullperimeter(p)
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

p = polygon(p);

lengths = @(xy) sum(sqrt(sum(diff(xy).^2,2)));

nc = length(p);
peri = zeros(size(p));

%without respect to holes
pxy = {p.xy};
for k=1:nc
  xy = pxy{k};
  K = convhull(xy(:,1),xy(:,2));
  peri(k) = lengths(xy(K,:)); 
end