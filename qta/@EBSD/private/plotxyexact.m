function plotxyexact(x,y,d,varargin)

[v faces rind] = spatialdecomposition([x y],'faces',varargin{:});
[x,y, lx,ly] = fixMTEXscreencoordinates(v(:,1),v(:,2),varargin{:});

xy = [x y];

if iscell(faces)
  h = zeros(size(faces));
  for k=1:numel(faces)
    h(k)= patch('Vertices',xy,'Faces',faces{k},'FaceVertexCData',d(rind{k},:),...
      'FaceColor','flat','EdgeColor','none');
  end
else
  h = patch('Vertices',xy,'Faces',faces,'FaceVertexCData',d,...
    'FaceColor','flat','EdgeColor','none');
end
  
optiondraw(h,varargin{:});

xlabel(lx); ylabel(ly);
fixMTEXplot;
