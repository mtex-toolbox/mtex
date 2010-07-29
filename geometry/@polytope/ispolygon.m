function b = ispolyeder(p)


if size(p(1).Vertices,2) == 2,
  b = true; 
else
  b = false;
end