function b = ispolyeder(p)
% checks whether the polytope is a polyeder

if size(p(1).Vertices,2) == 3,
  b = true; 
else
  b = false;
end
