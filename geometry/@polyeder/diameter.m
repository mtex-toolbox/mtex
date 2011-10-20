function  d = diameter(p)
% calculates the diameter of the grain-polygon, without Holes
%
%% Input
%  p - @grain / @polygon
%
%% Output
%  d    - diameter
%
%% See also
% polygon/equivalentperimeter polygon/borderlength

p = polygon(p);

d = zeros(size(p));
for k=1:numel(p)

  nv = size(p(k).Vertices,1);
  diffv = bsxfun(@minus,reshape(p(k).Vertices,[nv,1,3]),reshape(p(k).Vertices,[1,nv,3]));
  diffv = sum(diffv.^2,3);
    
  d(k) = sqrt(max(diffv(:)));
end
