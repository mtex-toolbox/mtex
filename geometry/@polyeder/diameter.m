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

p = polyeder(p);

d = zeros(size(p));
for k=1:numel(p)

  nv = size(p(k).Vertices,1);
  
  if nv > 20  
    s = unique(convhulln(p(k).Vertices));    
    V = p(k).Vertices(s,:);
    nv = numel(s);
  else
    V = p(k).Vertices;
  end

  diffv = bsxfun(@minus,reshape(V,[nv,1,3]),reshape(V,[1,nv,3]));
  diffv = sum(diffv.^2,3);
    
  d(k) = sqrt(max(diffv(:)));
end
