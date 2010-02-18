function p = polygon(grains)
% returns the polygon of grains as struct
%
%% Input
%  grains - @grain
%
%% Output
%  p.xy    - border 
%  p.hxy   - struct of holes
%

% p = [grains.polygon];

p = repmat(struct( grains(1).polygon),size(grains));
for k=1:length(p)
  p(k) = grains(k).polygon;
end
