function  drawNow(mtexFig, varargin)
% lay the figure out
%
% Options
%  doNotDraw    - return without doing anything
%  position     - [x y w h] to give the figure
%  figSize      - 'huge'|'large'|'normal'|'small'|'tiny' or a fraction of the screen
%  keepAxisSize - keep the axes the size they are and grow the figure instead
%  colorrange   - passed on to setColorRange
%  final        - antialias, when generating the documentation
%  takeThisAsReference - measure the margin on this axes rather than the first
%
% Description
% The margin left around the axes is measured on one of them and used for
% all, which is what mtexFigure is for: axes of equal size, alike enough that
% one stands for the others. Where that guesses low - a longer colorbar label,
% an axis label the first axes does not carry - say which axes to measure:
%
%   plot(...,'takeThisAsReference')

if check_option(varargin,'doNotDraw'), return;end

% a figure whose layout is held is being built, and the drawNow the builder
% ends with does all of this - leave as early as 'doNotDraw' does, so that
% saying so per call buys nothing over holding the figure
if mtexFig.layout.isHeld, return; end

if check_option(varargin,'takeThisAsReference')
  mtexFig.referenceAxis = mtexFig.currentAxes;
end

% update children to be only the axes of mtexFig
mtexFig.children = flipud(getAllAxes(mtexFig.parent));

% every spherical plot gets the same axis height, whatever it contains and
% however many of them share the figure - only the width follows the aspect
% ratio. A size asked for explicitly still wins, see sphericalAxisHeight.
mtexFig.fixedAxisHeight = [];
if ~isempty(mtexFig.children) && isappdata(mtexFig.children(1),'sphericalPlot') ...
    && ~check_option(varargin,'position')
  reqSize = get_option(varargin,'figSize');
  if isempty(reqSize) || isequal(reqSize,getMTEXpref('figSize'))
    mtexFig.fixedAxisHeight = getMTEXpref('sphericalAxisHeight',[]);
  end
end

if getMTEXpref('newLayout',true)
  drawNowLayout(mtexFig,varargin{:});
else
  drawNowLegacy(mtexFig,varargin{:});
end

% update colorrange
if check_option(varargin,'colorrange')
  setColorRange(mtexFig,get_option(varargin,'colorrange'),varargin{:});
end

% update scale bars
for i = 1:numel(mtexFig.children)
  mP = getappdata(mtexFig.children(i),'mapPlot');
  if ~isempty(mP), mP.micronBar.update; end
end

% use antialiasing to generate a nice figure
if check_option(varargin,'final') && getMTEXpref('generatingHelpMode')
  myaa('publish')
end

end

% =========================================================================
function drawNowLayout(mtexFig,varargin)
% size the figure, then hand the layout to @mtexLayout

if isempty(mtexFig.children), return; end

lay = mtexFig.layout;

% a colorbar or a legend put there by a plain colorbar(...) / legend(...) call
% has to be taken over before anything reserves room for it
adoptColorbars(mtexFig);
adoptLegend(mtexFig);

% 'keepAxisSize' means what it says: pin the axes and let the figure grow
% around them. That is the same problem a fixed axis height poses, so it is
% expressed the same way rather than as a branch of its own.
override = struct;
if check_option(varargin,'keepAxisSize') && ~isempty(mtexFig.axisHeight)
  override.fixedAxisHeight = mtexFig.axisHeight;
  override.layoutMode = 'user';
  override.ncols = mtexFig.ncols;
  override.nrows = mtexFig.nrows;
end

% an explicitly requested size is taken as given; a figSize is only the space
% to work in, and the figure is trimmed to what the layout ends up needing
refit = isPinned(mtexFig,override);
if check_option(varargin,'position')
  setFigurePosition(mtexFig,get_option(varargin,'position'));
  refit = false;
elseif check_option(varargin,'figSize') || mtexFig.figSizeFactor > 0
  mtexFig.keepAspectRatio = true;
  % the size asked for is the size of the plot, so the decorations come on top
  % of it - measure them now rather than using what the last layout left behind
  spec = lay.measure(mtexFig);
  setFigurePosition(mtexFig,onScreen(requestedSize(mtexFig,spec,varargin{:})));
  refit = true;
end

plan = lay.resolve(mtexFig,override);

% keeping the aspect ratio leaves space over on one side, and a pinned axis
% size needs more than there is - either way the figure ends up the size the
% layout asked for, so the size the previous plot left behind never carries over
if refit && ~isempty(plan)
  pos = get(mtexFig.parent,'Position');
  if any(abs(plan.figSize - pos(3:4)) > 1)
    setFigurePosition(mtexFig,onScreen(plan.figSize));
    plan = lay.resolve(mtexFig,override);
  end
end

matchPaper(mtexFig.parent);

% while publishing, flush the resize before the snapshot: it puts the paper
% back on auto, and auto reports the size the figure was last drawn at
if getMTEXpref('generatingHelpMode',false), drawnow; end

end

% -------------------------------------------------------------------------
function tf = isPinned(mtexFig,override)
tf = ~isempty(mtexFig.fixedAxisHeight) || isfield(override,'fixedAxisHeight');
end

% -------------------------------------------------------------------------
function figSize = requestedSize(mtexFig,spec,varargin)
% the size 'figSize' asks for, as a fraction of the first monitor

screenExtent = getScreenExtent;
figSize = screenExtent(1,3:4) - [0,120];

switch get_option(varargin,'figSize','','char')
  case 'huge',              fac = 1;
  case 'large',             fac = 0.8;
  case {'normal','medium'}, fac = 0.5;
  case 'small',             fac = 0.35;
  case 'tiny',              fac = 0.25;
  otherwise
    fac = get_option(varargin,'figSize',mtexFig.figSizeFactor,'double');
end
figSize = figSize .* fac;

n = numel(mtexFig.children);
if isappdata(mtexFig.children(1),'sphericalPlot')
  figSize = figSize .* min([1 1]./fac,0.75*[n/(1+(n>4)), (1 + (n>4))]);
elseif isappdata(mtexFig.children(1),'mapPlot')
  figSize = figSize .* min([1 1]./fac,[mtexFig.nrows mtexFig.ncols]);
end

% the decorations come on top of the plot, not out of it
inset = max(spec.inset,[],1);
figSize(1) = figSize(1) + spec.figInset(1) + spec.figInset(3) + ...
  mtexFig.ncols * (inset(1) + inset(3));
figSize(2) = figSize(2) + spec.figInset(2) + spec.figInset(4) + ...
  mtexFig.nrows * (inset(2) + inset(4));

end

% -------------------------------------------------------------------------
function position = onScreen(figSize)
% centred on the first monitor, and no larger than the area a figure may have
%
% This is where the layout decides a size rather than being given one, so it is
% where the bound belongs. It is the same bound the solver lays out under, see
% getScreenExtent: the caller resolves again against the size it gets, and a
% figure larger than the screen is one the window manager shrinks and the
% snapshot then squeezes.

screenExtent = getScreenExtent;
figSize = min(figSize,screenExtent(1,3:4));
position = [(screenExtent(1,3)-figSize(1))/2, ...
  (screenExtent(1,4)-figSize(2))/2, figSize];

end

% -------------------------------------------------------------------------
function setFigurePosition(mtexFig,position)
% resize without the resize callback coming straight back round
%
% onCleanup rather than a plain restore: an error in between used to leave the
% figure with no ResizeFcn at all, i.e. permanently deaf to being resized.

if mtexFig.parent.WindowStyle == "docked", return; end

if numel(position) == 2
  pos = get(mtexFig.parent,'Position');
  position = [pos(1:2) position];
end

fig = mtexFig.parent;
old = fig.ResizeFcn;
fig.ResizeFcn = [];
restore = onCleanup(@() set(fig,'ResizeFcn',old)); %#ok<NASGU>

fig.Position = position;

% the space to lay out in just changed
mtexFig.layout.invalidate;

end

% =========================================================================
function drawNowLegacy(mtexFig,varargin)
% the layout as it was before @mtexLayout, kept for setMTEXpref('newLayout',false)

set(mtexFig.children,'units','pixel');

% this seems to be necessary to get tight inset right
if ~check_option(varargin,'keepAxisSize')
  updateLayout(mtexFig);
end

% take over a legend outside the axes, updateLayout is skipped with 'keepAxisSize'
adoptLegend(mtexFig);

% compute surrounding box of each axis in pixel
[mtexFig.tightInset,mtexFig.figTightInset] = calcTightInset(mtexFig);

% determine preliminary figure size
if check_option(varargin,'position')

  position = get_option(varargin,'position');
  figSize = position(3:4);

elseif check_option(varargin,'figSize') || mtexFig.figSizeFactor > 0

  screenExtent = getScreenExtent;

  mtexFig.keepAspectRatio = true;
  figSize = screenExtent(1,3:4) - [0,120]; % consider only the first monitor

  switch get_option(varargin,'figSize','','char')
    case 'huge'
      fac = 1;
    case 'large'
      fac = 0.8;
    case {'normal','medium'}
      fac = 0.5;
    case 'small'
      fac = 0.35;
    case 'tiny'
      fac =  0.25;
    otherwise
      fac = get_option(varargin,'figSize',mtexFig.figSizeFactor,'double');
  end
  figSize = figSize .* fac;

  n = numel(mtexFig.children);
  if isappdata(mtexFig.children(1),'sphericalPlot')
    figSize = figSize .* min([1 1]./fac,0.75*[n/(1+(n>4)), (1 + (n>4))]);
  elseif isappdata(mtexFig.children(1),'mapPlot')
    figSize = figSize .* min([1 1]./fac,[mtexFig.nrows mtexFig.ncols]);
  end

  % try to compensate tight inset
  figSize(1) = figSize(1) + sum(mtexFig.figTightInset([1,3])) + ...
    mtexFig.ncols * sum(mtexFig.tightInset([1,3]));
  figSize(2) = figSize(2) + sum(mtexFig.figTightInset([2,4])) + ...
    mtexFig.nrows * sum(mtexFig.tightInset([2,4]));

else

  position = get(mtexFig.parent,'Position');
  figSize = position(3:4);

end

figSize = figSize - sum(reshape(mtexFig.figTightInset,2,2),2).';

% compute layout
if check_option(varargin,'figSize') ||...
    ~check_option(varargin,'keepAxisSize') || isempty(mtexFig.axisWidth)
  [mtexFig.ncols,mtexFig.nrows] = calcPartition(mtexFig,figSize);
  [mtexFig.axisWidth,mtexFig.axisHeight] = calcAxesSize(mtexFig,figSize);
else
  screenExtent = getScreenExtent;
end

% resize figure - a fixed axis height grows the figure to fit, so the size the
% previous plot left behind never enters
if ~isempty(mtexFig.fixedAxisHeight) || exist('screenExtent','var')
  screenExtent = getScreenExtent;
  width = mtexFig.axesWidth;
  height = mtexFig.axesHeight;
  position = [(screenExtent(1,3)-width)/2,(screenExtent(1,4)-height)/2,width,height];
end

% draw layout
mtexFig.parent.ResizeFcn = [];
if mtexFig.parent.WindowStyle~="docked", mtexFig.parent.Position = position; end
updateLayout(mtexFig);
mtexFig.parent.ResizeFcn = @(src,evt) updateLayout(mtexFig);

end
