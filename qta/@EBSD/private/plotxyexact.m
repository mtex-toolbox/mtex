function h = plotxyexact(xy,d,varargin)

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
