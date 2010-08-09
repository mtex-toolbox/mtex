function A = area(p)
% calculates the area of a polygon (with holes)
%
%% Input
%  p - @polygon / @grain
%
%% Output
%  A  - area of polygon
%
%% See alsoe
% polygon/hullarea  grain/grainsize

p = polygon(p); % could be a grain

A = zeros(size(p));

hole = hashole(p);
pxy = {p.xy};

for k=1:length(p)
  
  xy = pxy{k};
  x = xy(:,1);
  y = xy(:,2);
  
  cr = x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1);

  A(k) = abs(sum(cr)*0.5);
  
  if hole(k)
    A(k) = A(k) - sum(area(p(k).holes));
  end
  
end