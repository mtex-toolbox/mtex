function h = plotxyexact(xy,d,unitCell,varargin)

% generate patches
[v faces] = generatePatches(xy,unitCell,varargin{:});

% transfrom coordinates according to options
[v(:,1), v(:,2), lx,ly] = fixMTEXscreencoordinates(v(:,1),v(:,2),varargin{:});

% set color by VertexCData or by FaceColor
if check_option(varargin,'FaceColor')
  options = {};
else
  options = {'FaceVertexCData',d,'FaceColor','flat'};
end

% draw patches
h = patch('Vertices',v,'Faces',faces,'EdgeColor','none',options{:});
optiondraw(h,varargin{:});

% cosmetics
xlabel(lx); ylabel(ly);
fixMTEXplot;
