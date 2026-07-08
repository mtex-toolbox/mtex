function h = plotUnitCells(ebsd,d,varargin)
% low level plotting routine for EBSD maps - dispatches to a backend
%
% Backend (option 'backend', 'imagesc'|'surf'|'patch'):
%  * automatic (default): a square grid is sent to imagesc, which draws it
%    directly if the grid is axis-aligned and rigid and otherwise hands over
%    to surf; a hexagonal grid (or a 'unitCell'/'points' request) goes to
%    patch.
%  * an explicit 'backend' overrides the routing.
%
% See also
% EBSD/plot EBSD/private/plotImagesc EBSD/private/plotSurf EBSD/private/plotPatch

unitCell = ebsd.unitCell;
pos = ebsd.pos;
alpha = get_option(varargin,'faceAlpha');

% region crop (kept here so the backends receive already-cropped data)
if check_option(varargin,'region')
  reg = get_option(varargin,'region');
  ind = pos.x > reg(1) & pos.x < reg(2) & pos.y > reg(3) & pos.y < reg(4);
  pos = pos(ind,:);
  if numel(d) == numel(ind) || numel(ind) == size(d,1), d = d(ind,:); end
  if numel(alpha) == numel(ind), alpha = alpha(ind); end  
end

% convert a color name to rgb (backend-agnostic)
d = get_option(varargin,'FaceColor',d);
varargin = delete_option(varargin,'FaceColor',1);
if ischar(d) || isstring(d)
  if d == "none", d = nan(1,3); else, d = str2rgb(d); end
end

% determine the default backend
if numel(unitCell)~=4 || check_option(varargin,'unitCell')
  backend = 'patch';
elseif ~all(unitCell.z==0) || ...
    min(angle(unitCell(2)-unitCell(1),[xvector,yvector]))>1e-2
  backend = 'surf';
else
  backend = 'imagesc';
end

backend = get_option(varargin,'backend',backend);
switch lower(backend)
  case 'patch'
    h = plotPatch(pos,d,unitCell,alpha,varargin{:});
  case 'surf'
    h = plotSurf(pos,d,unitCell,varargin{:});
  case 'imagesc'
    h = plotImagesc(pos,d,unitCell,alpha,varargin{:});
  otherwise
    error('wrong backendname')
end

if nargout == 0, clear h; end

end