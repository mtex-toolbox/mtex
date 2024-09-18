function h = plotUnitCells(ebsd,d,varargin)
% low level plotting routine for EBSD maps
%

unitCell = ebsd.unitCell;

pos = ebsd.pos;
if check_option(varargin,'region')
  
  reg = get_option(varargin,'region');
    
  ind = pos.x > reg(1) & pos.x < reg(2) & pos.y > reg(3) & pos.y < reg(4);
  
  pos = pos(ind,:);
  
  if numel(d) == numel(ind) || numel(ind) == size(d,1)
    d = d(ind,:);
  end
    
end

ax = get_option(varargin,'parent',gca);

if ~isempty(unitCell)
  
  type = get_flag(varargin,{'unitcell','points','measurements'},'unitcell');
  
else
  
  type = 'points';
  
end

if numel(d) == length(pos) || numel(d) == 3*length(pos)

  obj.FaceVertexCData = reshape(d,length(pos),[]);
  
  if check_option(varargin,{'transparent','translucent','faceAlpha'})
  
    s = get_option(varargin,{'transparent','translucent','faceAlpha'},1,'double');
    varargin = delete_option(varargin,'faceAlpha');
  
    if size(d,2) == 3 % rgb
      obj.FaceVertexAlphaData = s.*(1-min(d,[],2));
    else
      obj.FaceVertexAlphaData = s.*d./max(d);
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
