function h = plotUnitCells(ebsd,d,varargin)
% low level plotting routine for EBSD maps
%

unitCell = ebsd.unitCell;
pos = ebsd.pos;
alpha = get_option(varargin,'faceAlpha');

if check_option(varargin,'region')
  
  reg = get_option(varargin,'region');
    
  ind = pos.x > reg(1) & pos.x < reg(2) & pos.y > reg(3) & pos.y < reg(4);
  
  pos = pos(ind,:);
  
  if numel(d) == numel(ind) || numel(ind) == size(d,1)
    d = d(ind,:);
  end
  
  if numel(alpha) == numel(ind)
    alpha = alpha(ind);
  end
end



if numel(unitCell)==4 && ~check_option(varargin,'unitCell')
  
  % convert string to color if required
  d = get_option(varargin,'FaceColor',d);
  varargin = delete_option(varargin,'FaceColor',1);
  if ischar(d) || isstring(d)
    if d == "none"
      d = nan(1,3);
    else
      d = str2rgb(d);
    end
  end

  [mesh,ind] = calcMesh(pos,unitCell,varargin{:});

  % transform data to mesh
  d = reshape(d,size(d,1),[]);
  dMesh = nan([numel(mesh),size(d,2)]);
  if size(d,1) == 1
    dMesh(ind,:) = repmat(d,nnz(ind),1);
  else
    dMesh(ind,:) = d;
  end
  
  dMesh = reshape(dMesh,[size(mesh),size(d,2)]);

  % transform alpha to mesh  
  if numel(alpha) > 1
    meshAlpha = ones(size(mesh));
    meshAlpha(ind) = alpha;
    varargin = set_option(varargin,'faceAlpha',meshAlpha);  
  end

  h = plotSurf(mesh,dMesh,ebsd.unitCell,varargin{:});
  return
end


ax = get_option(varargin,'parent');
if isempty(ax), ax=gca; end

if ~isempty(unitCell)
  
  type = get_flag(varargin,{'unitcell','points','measurements'},'unitcell');
  
else
  
  type = 'points';
  
end

if numel(d) == length(pos) || numel(d) == 3*length(pos)

  obj.FaceVertexCData = reshape(d,length(pos),[]);
  
  if numel(alpha) == numel(pos)
    
    varargin = delete_option(varargin,'faceAlpha');
  
    if size(d,2) == 3 % rgb
      obj.FaceVertexAlphaData = alpha.*(1-min(d,[],2));
    else
      obj.FaceVertexAlphaData = alpha.*d./max(d);
    end
    obj.AlphaDataMapping = 'none';
    obj.FaceAlpha = 'flat';  
  end
  obj.FaceColor = 'flat';  
else
  obj.FaceColor = d;
end

obj.EdgeColor = 'none';

switch lower(type)
  case 'unitcell'
    
    % generate patches
    [obj.Vertices, obj.Faces] = generateUnitCells(pos,unitCell,varargin{:});
    
  case {'points','measurements'}
    
    obj.Vertices = [pos.x(:),pos.y(:),pos.z(:)];
    obj.Faces    = (1:length(pos))';
    
    obj.FaceColor = 'none';
    obj.EdgeColor = 'flat';
    obj.Marker = '.';
    obj.MarkerFaceColor = 'flat';
    
end

h = optiondraw(patch(obj,'parent',ax),varargin{:});

if ~check_option(varargin,'DisplayName')
  h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

if nargout == 0, clear h;end
