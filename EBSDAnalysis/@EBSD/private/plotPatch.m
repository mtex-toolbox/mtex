function h = plotPatch(pos,d,unitCell,alpha,varargin)
% patch backend for EBSD maps: draws each cell as a real polygon (true squares
% or hexagons). Also handles the 'points'/'measurements' display.

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

end