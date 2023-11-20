function varargout = plot(g3B)

  h = drawMesh(g3B.allV.xyz,g3B.poly);

  if nargout > 0
    varargout = {h};
  end
end