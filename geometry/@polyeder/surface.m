 function surf = surface(p)
% calculates the area of the surface
%


n = normal(p);

surf = sum(cellfun(@(c) sum(sqrt(sum(c.^2,2))),n),2);
surf = reshape(surf,size(p));