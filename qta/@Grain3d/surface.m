 function surf = surface(grains)
% calculates the surface of grains
%

n = normal(grains);

surf = sum(cellfun(@(c) sum(sqrt(sum(c.^2,2))),n),2);
surf = reshape(surf,size(grains));