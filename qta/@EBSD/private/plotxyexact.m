function h = plotxyexact(xy,d,varargin)

[v faces rind] = spatialdecomposition(xy,'plot',varargin{:});
[v(:,1), v(:,2), lx,ly] = fixMTEXscreencoordinates(v(:,1),v(:,2),varargin{:});

if check_option(varargin,'FaceColor')
  h = zeros(size(faces));
  for k=1:numel(faces)
    h(k)= patch('Vertices',v,'Faces',faces{k},'EdgeColor','none');
  end
else
  h = zeros(size(faces));
  for k=1:numel(faces)
    h(k)= patch('Vertices',v,'Faces',faces{k},'FaceVertexCData',d(rind{k},:),...
      'FaceColor','flat','EdgeColor','none');
  end
end

optiondraw(h,varargin{:});

xlabel(lx); ylabel(ly);
fixMTEXplot;
