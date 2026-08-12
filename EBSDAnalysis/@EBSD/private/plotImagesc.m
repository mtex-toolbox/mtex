function h = plotImagesc(pos,d,unitCell,alpha,varargin)
% imagesc backend for a rigid, axis-aligned square EBSD map (fast path)
%
% plotImagesc draws the map with imagesc/image if the grid is
%   (1) axis-aligned: the unit-cell edges are parallel to the data x and y
%       axes (the screen orientation is applied separately by setView), and
%   (2) rigid: pixel positions sit on the ideal lattice within 1% of the cell
%       size.
% Otherwise the grid cannot be an axis-aligned image and plotImagesc hands the
% job over to plotSurf. Screen orientation (flips/rotation of the axes) is done
% by setView(how2plot) in plot, so imagesc plots in true data coordinates.
%
% Options
%  bgColor - rgb colour for cells without a measurement (notIndexed pixels and
%            empty lattice gaps). Default white.

ax = get_option(varargin,'parent');
if isempty(ax), ax=gca; end

% ---- eligibility: axis-aligned + rigid, else hand over to surf ------------
[ok,img] = eligible(pos,unitCell);
if ~ok
  h = plotSurf(pos,d,unitCell,varargin{:});
  return
end

bgColor = get_option(varargin,'bgColor',[1 1 1]);
if ischar(bgColor) || isstring(bgColor), bgColor = str2rgb(char(bgColor)); end
if numel(bgColor) ~= 3, bgColor = [1 1 1]; end

d = reshape(d,size(d,1),[]);
nCh = size(d,2);   % 1 = scalar/indexed, 3 = rgb

if nCh == 3
  % RGB (phase / orientation colour). Cells without a measurement are filled
  % with bgColor; otherwise imagesc would render the NaNs black.
  C = repmat(reshape(bgColor(:).',1,1,3),img.nRows,img.nCols);
  C = reshape(C,img.nRows*img.nCols,3);
  if size(d,1) == 1
    C(img.sub,:) = repmat(d,numel(img.sub),1);
  else
    C(img.sub,:) = d;
  end
  C = reshape(C,[img.nRows,img.nCols,3]);

  % measured cells opaque (honouring an explicit per-pixel faceAlpha),
  % unmeasured cells transparent so the axes background shows through
  A = zeros(img.nRows,img.nCols);
  if numel(alpha) == numel(img.sub) || isscalar(alpha)
    A(img.sub) = alpha;
  else
    A(img.sub) = 1;
  end
  % per-cell NaN test: reduce over the colour channel (dim 3), not columns
  A(any(isnan(C),3)) = 0;

  hG = holdOn(ax); %#ok<NASGU>
  h = image(ax,'XData',img.x,'YData',img.y,'CData',C,...
    'AlphaData',A,'AlphaDataMapping','none');
else
  % scalar data through the colormap: cells without a measurement stay
  % transparent (a scalar CData cannot encode an rgb colour)
  C = nan(img.nRows*img.nCols,1);
  C(img.sub) = d;
  C = reshape(C,[img.nRows,img.nCols]);

  A = zeros(img.nRows,img.nCols);
  if numel(alpha) == numel(img.sub)
    A(img.sub) = alpha;
  elseif ~isempty(alpha)
    A(img.sub) = alpha(1);
  else
    A(img.sub) = 1;
  end
  A(isnan(C)) = 0;

  hG = holdOn(ax); %#ok<NASGU>
  h = imagesc(ax,img.x,img.y,C,'AlphaData',A);
  set(h,'AlphaDataMapping','none');
end

clear hG

h = optiondraw(h,varargin{:});

% Legend: a truecolor image is a poor legend swatch, so when a DisplayName is
% requested (the per-phase phase plot passes one solid colour) add an invisible
% proxy patch carrying that name and colour; the image stays out of the legend.
name = get_option(varargin,'DisplayName');
if ~isempty(name)
  if size(d,1) == 1 && size(d,2) == 3
    swatch = d;
  elseif size(d,2) == 3
    swatch = d(1,:);
  else
    swatch = [0 0 0];
  end
  hG = holdOn(ax); %#ok<NASGU>
  patch('parent',ax,'XData',nan,'YData',nan,...
    'FaceColor',swatch,'EdgeColor','none','DisplayName',name);
  clear hG
end

end

% =========================================================================
function [ok,img] = eligible(pos,unitCell)
% imagesc is possible iff the grid basis is aligned with the data x/y axes and
% the pixels sit on the ideal lattice (rigid). Returns the image layout in true
% data coordinates.

ok = false; img = struct();
if numel(unitCell) ~= 4 || numel(pos) < 2, return; end

% grid basis edge vectors from the unit cell
c   = [unitCell.x(:), unitCell.y(:)];
e1  = c(2,:) - c(1,:);
e2  = c(4,:) - c(1,:);
dxy = max(hypot(e1(1),e1(2)), hypot(e2(1),e2(2)));

% (1) each edge horizontal or vertical in data coordinates
axisAligned = @(e) (abs(e(1)) < 1e-9*dxy) || (abs(e(2)) < 1e-9*dxy);
if ~(axisAligned(e1) && axisAligned(e2)), return; end
dx = max(abs([e1(1) e2(1)]));
dy = max(abs([e1(2) e2(2)]));
if dx <= 0 || dy <= 0, return; end

px = pos.x(:);  py = pos.y(:);
gx = round((px - min(px)) / dx);
gy = round((py - min(py)) / dy);

% (2) rigidity: positions match the ideal lattice within 1% of a cell
idealX = min(px) + gx*dx;
idealY = min(py) + gy*dy;
if max(hypot(px-idealX, py-idealY)) > 0.01*dxy, return; end

img.nRows = max(gy) + 1;
img.nCols = max(gx) + 1;
img.sub   = sub2ind([img.nRows img.nCols], gy+1, gx+1);
img.x     = [min(px), max(px)];
img.y     = [min(py), max(py)];
ok = true;

end


