function h = plotSurf(pos,d,uC,varargin)
% plot EBSD map through surf
%
% Accepts a flat pos/d (one entry per pixel) and builds the grid itself via
% calcMesh, so it can be called directly with ebsd.pos like the other backends.
% If pos is already a 2-D grid it is used as is.

ax = get_option(varargin,'parent');
if isempty(ax), ax=gca; end

alpha = get_option(varargin,'faceAlpha');

% build the (m x n) grid of pixel positions from a flat list
if size(pos,2) == 1 || isvector(pos)
  [mesh,ind] = calcMesh(pos,uC,varargin{:});
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
% lower-index corner. We therefore extend the centre grid by one node and shift
% it by half a cell so every face is centred on its pixel.
%
% The grid steps are taken from the actual pixel positions rather than from the
% unit-cell corner indices. The previous version used uC(4)-uC(1), uC(2)-uC(1)
% and shifted by uC(1), which silently assumed a particular ordering of the
% unit-cell corners; unit cells stored in a different corner order (as some
% importers produce) then displaced the whole map by one pixel. Reading the
% step from pos is ordering-independent and also tolerates slightly deformed
% grids.
if size(pos,2) >= 2, du = pos(1,2) - pos(1,1); else, du = uC(1)-uC(1); end
if size(pos,1) >= 2, dv = pos(2,1) - pos(1,1); else, dv = uC(1)-uC(1); end

% extend by one node on the high side ...
posExt = [pos, pos(:,end) + du];
posExt = [posExt; posExt(end,:) + dv];
% ... and shift back by half a cell so faces are centred on the pixels. The
% half-cell offset is the pixel-centre-to-corner vector -(du+dv)/2, which is
% independent of how the unit-cell corners happen to be ordered.
posExt = posExt - (du + dv) ./ 2;

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

holdState = ishold(ax);
hold(ax,"on")

h = optiondraw(surf(posExt.x,posExt.y,posExt.z,dExt(:,:,:),'parent',ax,...
  'EdgeColor','none',opt{:}),varargin{:});

if ~holdState, hold(ax,"off"); end

if ~check_option(varargin,'DisplayName')
  h.Annotation.LegendInformation.IconDisplayStyle = 'off';
end

end