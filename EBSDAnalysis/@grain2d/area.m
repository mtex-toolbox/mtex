function A = area(grains,varargin)
% calculates the area of a polygon (with Holes)
%
% Input
%  grains - @Grain2d
%
% Output
%  A  - double list with area of polygon
%
% See also
%

isc = cellfun('isclass',grains.poly,'cell');

A = zeros(size(grains));

if any(isc)
  A(isc) = cellfun(@(x) 2*max(x) -sum(x),...
    mat2cell(cellArea(grains.V, [grains.poly{isc}]),...
    cellfun('prodofsize',grains.poly(isc))));
end

A(~isc) = cellArea(grains.V,grains.poly(~isc));


function A = cellArea(V,D)

D = D(:);
A = zeros(size(D));

faceOrder = [D{:}];

x = V(faceOrder,1);
y = V(faceOrder,2);

dF = full(x(1:end-1).*y(2:end)-x(2:end).*y(1:end-1));

cs = [0; cumsum(cellfun('prodofsize',D))];
for k=1:numel(D)
  ndx = cs(k)+1:cs(k+1)-1;
  A(k) = abs(sum(dF(ndx))*0.5);  
end
