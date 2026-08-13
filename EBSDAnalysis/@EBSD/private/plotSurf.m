function h = plotSurf(pos,d,uC,varargin)
% plot EBSD map through surf
%
% Accepts a flat pos/d (one entry per pixel) and builds the grid itself via
% calcMesh, so it can be called directly with ebsd.pos like the other backends.
% If pos is already a 2-D grid it is used as is.
%
% Option 'isCell' marks the cells that carry a measurement. The surface has
% to cover the full lattice raster, but a gridded map is padded out to that
% raster - see EBSD/extent - and on a lattice rotated against the map axes
% the padding reaches far beyond the measurements. Those cells are painted
% NaN and are invisible, yet axis tight still followed them, leaving the map
% a small island in a much larger axis. Their corners are therefore dropped
% below. Without the option every cell counts.

ax = get_option(varargin,'parent');
if isempty(ax), ax=gca; end

alpha = get_option(varargin,'faceAlpha');

% build the (m x n) grid of pixel positions from a flat list
isCell = get_option(varargin,'isCell',[]);

if size(pos,2) == 1 || isvector(pos)
  [mesh,ind] = calcMesh(pos,uC,varargin{:});

  % the mesh is the raster completed around the points we were given, so
  % the cells that carry a measurement are exactly the ones it filled
  isCell = false(size(mesh)); isCell(ind) = true;

  d = reshape(d,size(d,1),[]);
  dMesh = nan([numel(mesh),size(d,2)]);
  if size(d,1) == 1
    dMesh(ind,:) = repmat(d,nnz(ind),1);
  else
    dMesh(ind,:) = d;
  end
  d   = reshape(dMesh,[size(mesh),size(d,2)]);
  if numel(alpha) > 1
    meshAlpha = ones(size(mesh)); meshAlpha(ind) = alpha;
    varargin = set_option(varargin,'faceAlpha',meshAlpha);
  end
  pos = mesh;
else
  d = reshape(d,size(pos,1),size(pos,2),[]);
end

% For surf we need an (m+1) x (n+1) grid of cell CORNERS: surf draws m x n
% faces and colours face (i,j) with d(i,j), taking the colour from the face's
% lower-index corner. Each corner is the local average of its (up to) four
% neighbouring pixel centres, so every face is centred on its pixel.
%
% Corners are built from local neighbours only, not a single grid-wide step
% vector: the centre grid is first padded by one row/column on every side via
% local linear extrapolation (each padded value uses only its two nearest
% neighbours), then every corner is the average of the four centres around
% it. This is exact for a rigid grid (equivalent to the previous du/dv/2
% shift) and, unlike a single global step, also tracks a locally varying
% step - e.g. a distorted, non-rigid grid - since each corner only depends on
% its immediate neighbourhood.
if size(pos,1) >= 2
  topPad = 2*pos(1,:) - pos(2,:);
  botPad = 2*pos(end,:) - pos(end-1,:);
else
  topPad = pos(1,:); botPad = pos(1,:);
end
posPad = [topPad; pos; botPad];

if size(pos,2) >= 2
  leftPad  = 2*posPad(:,1) - posPad(:,2);
  rightPad = 2*posPad(:,end) - posPad(:,end-1);
else
  leftPad = posPad(:,1); rightPad = posPad(:,1);
end
posPad = [leftPad, posPad, rightPad];

posExt = (posPad(1:end-1,1:end-1) + posPad(1:end-1,2:end) + ...
          posPad(2:end,1:end-1)   + posPad(2:end,2:end)) / 4;

% keep only the corners that a measured cell touches, so that the padding
% of a gridded map does not enter the axis limits. Every corner of a drawn
% face survives, hence nothing visible is lost - the faces that lose a
% corner are the ones painted NaN anyway.
if ~isempty(isCell) && ~all(isCell(:))

  keep = false(size(pos)+2);
  keep(2:end-1,2:end-1) = reshape(isCell,size(pos));
  keep = keep(1:end-1,1:end-1) | keep(1:end-1,2:end) | ...
    keep(2:end,1:end-1) | keep(2:end,2:end);

  posExt.x(~keep) = NaN; posExt.y(~keep) = NaN; posExt.z(~keep) = NaN;

end

% extent data
dExt = [d,d(:,end,:)]; dExt = [dExt;dExt(end,:,:)];

% extent alpha
alpha = get_option(varargin,'faceAlpha');
if numel(alpha) == numel(pos)
  alpha = [alpha,alpha(:,end)]; alpha = [alpha;alpha(end,:)];
  opt = {'alphaData',alpha,'FaceAlpha','flat'};
  varargin = delete_option(varargin,'faceAlpha',1);
else
  opt = {};
end

hG = holdOn(ax); %#ok<NASGU>

h = optiondraw(surf(posExt.x,posExt.y,posExt.z,dExt(:,:,:),'parent',ax,...
  'EdgeColor','none',opt{:}),varargin{:});

clear hG

if ~check_option(varargin,'DisplayName')
  h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

end