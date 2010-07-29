function b = ispolyeder(p)


if size(p(1).Vertices,2) == 3,
  b = true; 
else
  b = false;
end