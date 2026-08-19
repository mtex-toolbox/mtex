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

if numel(d) == numel(pos) || numel(d) == 3*numel(pos)

  obj.FaceVertexCData = reshape(d,numel(pos),[]);

  if numel(alpha) == numel(pos)
    varargin = delete_option(varargin,'faceAlpha');

    % both of these have to be read off the RESHAPED data, not off d: on a
    % gridded map a per pixel quantity arrives with the shape of the map, so
    % d is (r x c) or (r x c x 3) and alpha is (r x c), while
    % FaceVertexAlphaData is a column. Taken from d directly, size(d,2) is
    % the number of map columns and the rgb test below picks the wrong
    % branch, and the product mixes an (r x c) with an (r*c x 1).
    cData = obj.FaceVertexCData;
    alpha = reshape(alpha,[],1);

    if size(cData,2) == 3 % rgb
      obj.FaceVertexAlphaData = alpha.*(1-min(cData,[],2));
    else
      obj.FaceVertexAlphaData = alpha.*cData./max(cData);
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
    % welding (shared corners) is only needed when edges are drawn or faces are
    % partly transparent; otherwise skip it for speed. Edges are on if the
    % caller overrides the default EdgeColor='none' via varargin; transparency
    % is on if a per-face alpha was set above.
    edgeColor = get_option(varargin,'EdgeColor','none');
    hasEdges  = ~(ischar(edgeColor) || isstring(edgeColor)) || ~strcmpi(edgeColor,'none');
    hasAlpha  = isfield(obj,'FaceVertexAlphaData');
    if ~hasEdges && ~hasAlpha
      varargin = [varargin,{'noWeld'}];
    end
    [obj.Vertices, obj.Faces] = generateUnitCells(pos,unitCell,varargin{:});

    % generateUnitCells may return triangulated faces (noWeld fast path):
    % N*nT triangle rows instead of N polygon rows. Per-face flat colour and
    % alpha are given per cell (N rows), so replicate them to match the face
    % count. The triangle layout is block-wise ([all cells tri1; tri2; ...]),
    % so repmat(...,nT,1) lines up row-for-row.
    nF = size(obj.Faces,1);
    if isfield(obj,'FaceVertexCData') && strcmpi(obj.FaceColor,'flat') ...
        && size(obj.FaceVertexCData,1) == numel(pos) ...
        && nF > numel(pos) && mod(nF,numel(pos)) == 0
      nT = nF / numel(pos);
      obj.FaceVertexCData = repmat(obj.FaceVertexCData, nT, 1);
      if isfield(obj,'FaceVertexAlphaData')
        obj.FaceVertexAlphaData = repmat(obj.FaceVertexAlphaData, nT, 1);
      end
    end
  case {'points','measurements'}
    obj.Vertices = [pos.x(:),pos.y(:),pos.z(:)];
    obj.Faces    = (1:numel(pos))';
    obj.FaceColor = 'none';
    obj.EdgeColor = 'flat';
    obj.Marker = '.';
    obj.MarkerFaceColor = 'flat';
end

h = optiondraw(patch(obj,'parent',ax),varargin{:});

end