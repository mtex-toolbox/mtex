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
%
% A figure whose layout is held is being built, and the drawNow the builder
% ends with does all of this.

if check_option(varargin,'doNotDraw') || mtexFig.layout.isHeld, return; end

if check_option(varargin,'takeThisAsReference')
  mtexFig.referenceAxis = mtexFig.currentAxes;
end

% update children to be only the axes of mtexFig
mtexFig.children = flipud(getAllAxes(mtexFig.parent));

if ~isempty(mtexFig.children), layout(mtexFig,varargin{:}); end

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
function layout(mtexFig,varargin)
% size the figure, then hand the layout to @mtexLayout

lay = mtexFig.layout;

% a colorbar or a legend put there by a plain colorbar(...) / legend(...) call
% has to be taken over before anything reserves room for it
adoptColorbars(mtexFig);
adoptLegend(mtexFig);

% an axis is sized from a preference rather than from the screen: a spherical
% plot by one height, everything else by a box it has to fit into, so that the
% dimension which binds is the one the plot is long in. A figSize asked for
% scales that size rather than replacing it, so 'large' stays a fixed multiple
% of the page and not a fraction of whichever monitor built it.
mtexFig.fixedAxisHeight = [];
if ~check_option(varargin,'position')

  if isappdata(mtexFig.children(1),'sphericalPlot')
    pinned = getMTEXpref('sphericalAxisHeight',[]);
  else
    pinned = boxedHeight(axesRatio(mtexFig.children(1)));
  end

  % a plot that asks for no size at all is the size the preference asks for
  ref = figSizeFactor(getMTEXpref('figSize'));
  fac = figSizeFactor(get_option(varargin,'figSize',mtexFig.figSizeFactor),ref);

  if ~isempty(pinned) && ref > 0
    mtexFig.fixedAxisHeight = pinned * fac / ref;
  end
end

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
refit = ~isempty(mtexFig.fixedAxisHeight) || isfield(override,'fixedAxisHeight');
if check_option(varargin,'position')
  lay.resize(mtexFig,get_option(varargin,'position'));
  refit = false;
elseif check_option(varargin,'figSize') || mtexFig.figSizeFactor > 0
  mtexFig.keepAspectRatio = true;
  % the size asked for is the size of the plot, so the decorations come on top
  % of it - measure them now rather than using what the last layout left behind
  lay.resize(mtexFig,requestedSize(mtexFig,lay.measure(mtexFig),varargin{:}));
  refit = true;
end

lay.resolve(mtexFig,override,refit);

% while publishing, flush the resize before the snapshot: it puts the paper
% back on auto, and auto reports the size the figure was last drawn at
if getMTEXpref('generatingHelpMode',false), drawnow; end

end

% -------------------------------------------------------------------------
function h = boxedHeight(ratio)
% the tallest axes of this ratio that fits the box and stays within the area
%
% Three bounds, whichever bites first: a wide axes is stopped by the width, a
% tall one by the height, and one that is neither by the area it may cover.

h = [];
box = getMTEXpref('axisBox',[]);
area = getMTEXpref('axisArea',[]);
if isempty(box) && isempty(area), return; end

w = inf;
if ~isempty(box), w = min(box(1),box(2) / ratio); end
if ~isempty(area), w = min(w,sqrt(area / ratio)); end

h = w * ratio;

end

% -------------------------------------------------------------------------
function figSize = requestedSize(mtexFig,spec,varargin)
% the size 'figSize' asks for, as a fraction of the first monitor

figSize = mtexFig.screenExtent - [0,120];

fac = figSizeFactor(get_option(varargin,'figSize',mtexFig.figSizeFactor), ...
  mtexFig.figSizeFactor);
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
