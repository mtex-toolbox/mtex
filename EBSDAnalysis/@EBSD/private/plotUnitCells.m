function h = plotUnitCells(xy,d,unitCell,varargin)

ax = get_option(varargin,'parent',gca);

if ~isempty(unitCell)
  
  type = get_flag(varargin,{'unitcell','points','measurements'},'unitcell');
  
else
  
  type = 'points';
  
end

if numel(d) == size(xy,1) || numel(d) == 3*size(xy,1)

  obj.FaceVertexCData = reshape(d,size(xy,1),[]);
  %if size(d,2) == 3, set(get(ax,'parent'),'renderer','opengl');end
  
  if check_option(varargin,{'transparent','translucent','faceAlpha'})
  
    s = get_option(varargin,{'transparent','translucent','faceAlpha'},1,'double');
  
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
    [obj.Vertices, obj.Faces] = generateUnitCells(xy,unitCell,varargin{:});
    
  case {'points','measurements'}
    
    obj.Vertices = xy;
    obj.Faces    = (1:size(xy,1))';
    
    obj.FaceColor = 'none';
    obj.EdgeColor = 'flat';
    obj.Marker = '.';
    obj.MarkerFaceColor = 'flat';
    
end

h = optiondraw(patch(obj,'parent',ax),varargin{:});

if ~check_option(varargin,'DisplayName')
  set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
end

if nargout == 0, clear h;end



