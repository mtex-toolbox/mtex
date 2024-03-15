function varargout = plot(g3B,varargin)

  h = optiondraw(drawMesh(g3B.allV.xyz,g3B.F),varargin{:});

  if nargout > 0
    varargout = {h};
  end
end