function plotxyexact(x,y,d,varargin)

[v faces] = spatialdecomposition([x y],'faces',varargin{:});
[x,y, lx,ly] = fixMTEXscreencoordinates(v(:,1),v(:,2),varargin{:});

h = patch('Vertices',[x y],'Faces',faces,'FaceVertexCData',d,...
  'FaceColor','flat','EdgeColor','none');
  
optiondraw(h,varargin{:});

xlabel(lx); ylabel(ly);
fixMTEXplot;
