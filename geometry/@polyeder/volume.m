function vol = volume( p )
% calculates the volume of a polyeder
%
%% Input
%  p - @polyeder / @grain
%
%% Output
%  V  - volume of polyeder
%
% working rigth only if all triangles/quadrilateral have same orientation!
%

p = polyeder(p); % could be a grain

n = normal(p);

vol = zeros(size(p));
for k=1:numel(p)
  
  v = p(k).Vertices;
  f = p(k).Faces;
  
  c = cellfun(@times,g(v,f),n(k,:),'UniformOutput',false);
  c = vertcat(c{:});
  vol(k) = sum(c(:))/2;
  
end


function m = g(v,f)

m{1} = mean(reshape(v(f(:,1:3),:),[],3,3),3);
if size(f,2)>3
  m{2} = mean(reshape(v(f(:,[3 4 1]),:),[],3,3),3);
end
