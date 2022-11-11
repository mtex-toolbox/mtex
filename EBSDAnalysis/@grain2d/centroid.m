function c = centroid(grains)
% calculates the barycenters of the grain boundary
%

if dot(grains.N,zvector) ~= 1

  [grains,rot] = rotate2Plane(grains);
  c = centroid(grains);
  c=(rot\c)';

  return

end

% initalize x,y values
x = zeros(size(grains)); y = x;

faceOrder = [grains.poly{:}];

Vx = grains.V(faceOrder,1);
Vy = grains.V(faceOrder,2);

dF = (Vx(1:end-1).*Vy(2:end)-Vx(2:end).*Vy(1:end-1));
cx = (Vx(1:end-1) +Vx(2:end)).*dF;
cy = (Vy(1:end-1) +Vy(2:end)).*dF;

cs = [0; cumsum(cellfun('prodofsize',grains.poly))];

for k=1:numel(x)
  ndx = cs(k)+1:cs(k+1)-1;
  
  a = sum(dF(ndx));
  x(k) = sum(cx(ndx)) / 3 / a;
  y(k) = sum(cy(ndx)) / 3 / a;
end

c=vector3d(x,y,grains.V(1,3));
%compensate that grains are only turned parallel to xy plane, but possebly are situated over or under

end

% some test code
% mtexdata fo
% plot(ebsd)
% grains = calcGrains(ebsd)
% plot(grains(1806))
% [x,y] = centroid(grains(1806));
% hold on, plot(x,y,'o','color','b'); hold off
