function bl = borderlength(grains,varargin)
% returns the borderlength of grain-polygon
%
%% Input
%  grains - @grain
%
%% Output
%  bl   - borderlength
%% Options
%  COUNT - return number of border elements

bordersize = @(xy) sum(sqrt(sum(diff(xy).^2,2)));

nc = length(grains);
bl = zeros(size(grains));

if check_option(varargin,'count');  
  p = polygon(grains);
  bl = cellfun('length',{p.xy});
else
  for k=1:nc
    xy = grains(k).polygon.xy; 
    bl(k) = bordersize(xy);
    
    for l=1:length(grains(k).polygon.hxy)
      xy = grains(k).polygon.hxy{l};
      bl(k) = bl(k) + bordersize(xy);
    end
  end
end
