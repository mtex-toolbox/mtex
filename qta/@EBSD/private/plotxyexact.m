function h = plotxyexact(xy,d,unitCell,varargin)

if check_option(varargin,'voronoi')
  
  [v faces rind] = spatialdecomposition(xy,'plot',varargin{:});
  [v(:,1), v(:,2), lx,ly] = fixMTEXscreencoordinates(v(:,1),v(:,2),varargin{:});

  h = zeros(size(faces));
  for k=1:numel(faces)
    h(k)= patch('Vertices',v,'Faces',faces{k},'FaceVertexCData',d(rind{k},:),...
      'FaceColor','flat','EdgeColor','none');
  end
  
  optiondraw(h,varargin{:});

  xlabel(lx); ylabel(ly);
  fixMTEXplot;

  return
  
end

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
