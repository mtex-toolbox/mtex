function [x,y] = centroid(grains)
% calculates the barycenter of the grain-polygon, with respect to its holes
%

c = zeros(numel(grains),2);

isHole = hasHole(grains);

if any(isHole)
  
  [cH,a] = cellCentroid(grains.V,[grains.poly{isHole}]);

  cs = [0; cumsum(cellfun('prodofsize',grains.poly(isHole)))];

  % for each cell
  for k=1:nnz(isHole)
    ndx = cs(k)+1:cs(k+1);
    % sort after area 
    at = a(ndx);
    ct =  cH(ndx,:);

    % the centroid is sum(C.*A)/sum(A) where, A = [a1 -a2 -a3];
    cH(ndx(1),:) = (ct(1,:).*at(1) - sum(bsxfun(@times,ct(2,:),at(2:end)),1))./(at(1)-sum(at(2:end)));
  end

  c(isHole,:) = cH(cs(1:end-1)+1,:);
end
c(~isHole,:) = cellCentroid(grains.V,grains.poly(~isHole));

if nargout == 2
  x = c(:,1);
  y = c(:,2);
else
  x = c;
end
  
function [v,a] = cellCentroid(V,D)

D = D(:);
a = zeros(size(D));
cHx = zeros(size(D));
cHy = zeros(size(D));

faceOrder = [D{:}];

x = V(faceOrder,1);
y = V(faceOrder,2);

dF = (x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1));
cx = (x(1:end-1)+x(2:end)).*dF;
cy = (y(1:end-1)+y(2:end)).*dF;

cs = [0; cumsum(cellfun('prodofsize',D))];

for k=1:numel(D)
  ndx = cs(k)+1:cs(k+1)-1;
  
  a(k) =   sum(dF(ndx));
  cHx(k) = sum(cx(ndx));
  cHy(k) = sum(cy(ndx));
end

v =  [cHx./(3*a) cHy./(3*a)] ;
% v = bsxfun(@rdivide,[cHx cHy],3*a);
a = abs(a*.5);

