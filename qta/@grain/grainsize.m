function s = grainsize(grains,varargin)
% returns the size of a grain
%
%% Input
%  grains - @grain
%
%% Output
%  s   - size
%
%% Options
% AREA  - return the area
% HULL  - return the area of convex hull
%
%% See also
% grain/area grain/hullarea

nc = length(grains);
s = zeros(size(grains));

area = @(x,y) abs(0.5.*sum(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1)));

if check_option(varargin,'area')
%   p =  polygon(grains);
  for k=1:nc     
    p = grains(k).polygon;
    xy = p.xy;
    s(k) = area(xy(:,1),xy(:,2));
  
    hxy = p.hxy;
    for l=1:length(hxy)
      xy = hxy{l};
      s(k) =  s(k) -  area(xy(:,1),xy(:,2));
    end    
  end  
elseif check_option(varargin,'hull')
  for k=1:nc
    xy = grains(k).polygon.xy;
    K = convhulln(xy);
    xy = xy([K(:,1); K(1,1)],:);
    s(k) = area(xy(:,1),xy(:,2));
  end  
else
  s = cellfun('prodofsize',{grains.cells});
end


