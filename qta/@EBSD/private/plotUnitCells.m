function h = plotUnitCells(xy,d,unitCell,varargin)


if ~isempty(unitCell)
  
  [unitCell(:,1), unitCell(:,2)] = fixMTEXscreencoordinates(unitCell(:,1),unitCell(:,2),varargin{:});
  
  type = get_flag(varargin,{'unitcell','voronoi','points','measurements'},'unitcell');
  
else
  
  type = 'points';
  
end

[xy(:,1), xy(:,2), lx, ly]     = fixMTEXscreencoordinates(xy(:,1),xy(:,2),varargin{:});

obj.FaceVertexCData = d;
obj.FaceColor = 'flat';
obj.EdgeColor = 'none';

switch lower(type)
  case 'unitcell'
    
    % generate patches
    [obj.Vertices obj.Faces] = generateUnitCells(xy,unitCell,varargin{:});
    
  case 'voronoi'
    
    [obj.Vertices,faces]     = spatialdecomposition(xy,unitCell,varargin{:});
    
    p = cellfun('prodofsize',faces);
    obj.Faces = NaN(numel(faces),max(p));
    for k=1:numel(faces)
      obj.Faces(k,1:p(k)) = faces{k};
    end
    
  case {'points','measurements'}
    
    obj.Vertices = xy;
    obj.Faces    = (1:size(xy,1))';
    
    obj.FaceColor = 'none';
    obj.EdgeColor = 'flat';
    obj.Marker = '.';
    obj.MarkerFaceColor = 'flat';
    
end

h = optiondraw(patch(obj),varargin{:});

% cosmetics
xlabel(lx); ylabel(ly);



