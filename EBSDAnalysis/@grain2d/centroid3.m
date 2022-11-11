function c = centroid3(grains)
% calculates the barycenters of the grain boundary
%

faceOrder = [grains.poly{:}];
if size(grains.V,2)==2
  V=vector3d(grains.V(:,1), grains.V(:,2),zeros(length(grains.V),1));
else
  V=vector3d(grains.V(:,1), grains.V(:,2), grains.V(:,3));
end
V=V(faceOrder);

dF= dot(cross(V(1:end-1),V(2:end)),grains.N);
a=dF.*(V(1:end-1)+V(2:end));

cs = [0; cumsum(cellfun('prodofsize',grains.poly))];

%for k=1:numel(c)
for k=1:length(grains)
  ndx = cs(k)+1:cs(k+1)-1;
  c(k)  = sum(a(ndx)) / 3 / sum(dF(ndx));
end

% some test code
% mtexdata fo
% plot(ebsd)
% grains = calcGrains(ebsd)
% plot(grains(1806))
% [x,y] = centroid(grains(1806));
% hold on, plot(x,y,'o','color','b'); hold off
