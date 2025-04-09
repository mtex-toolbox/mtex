function e = eq(tri1,tri2)

e=false;
if length(tri1.vertices)==length(tri2.vertices) && all(tri1.vertices(:)==tri2.vertices(:))
  e = true;
end

end

