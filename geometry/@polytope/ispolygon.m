function b = ispolygon(p)
% checks whether the polytope is a polygon

if size(p(1).Vertices,2) == 2,
  b = true; 
else
  b = false;
end
