function spec = measure(lay,mtexFig)
% read the geometry off the figure, once
%
% Syntax
%   spec = lay.measure(mtexFig)
%
% Output
%  spec - what solveLayout needs, all in pixels
%
% Description
% The only step that touches graphics properties. Everything it reads is
% cached behind a token built from the things the answer depends on, so a
% resize that changes nothing - the common case while dragging a window -
% costs one token comparison and no property access at all.
%
% See also
% mtexLayout/solveLayout mtexLayout/apply

ax = mtexFig.children(:);
ax = ax(isgraphics(ax));

token = validityToken(mtexFig,ax);
if isequal(token,lay.lastToken)
  spec = lay.lastSpec;
  return
end

% everything this class manages is pinned to pixels once and stays there
pin(mtexFig.parent);
pin(ax);
pin(mtexFig.cBarAxis);
pin(mtexFig.legendAxis);

figPos = get(mtexFig.parent,'Position');

spec = struct;
spec.n = numel(ax);
spec.figSize = figPos(3:4);
spec.maxSize = mtexFig.screenExtent;
spec.spacing = mtexFig.innerPlotSpacing;
spec.keepAspectRatio = mtexFig.keepAspectRatio;
spec.fixedAxisHeight = mtexFig.fixedAxisHeight;
spec.layoutMode = mtexFig.layoutMode;
spec.ncols = mtexFig.ncols;
spec.nrows = mtexFig.nrows;
spec.figInset = mtexFig.outerPlotSpacing * [1 1 1 1];

if isempty(ax)
  spec.ratio = 1;
  spec.inset = [0 0 0 0];
  spec.plotBox = [0 0 1 1];
else
  ref = referenceAxes(mtexFig,ax);
  spec.ratio = axesRatio(ax(1));
  spec.inset = axesInset(ref);
  spec.plotBox = plotBoxOf(ref);
end

spec.cBar = colorbarSpec(mtexFig);
spec.legend = legendSpec(mtexFig);

% an sgtitle is drawn above everything and nothing else reserves room for it
h = findobj(mtexFig.parent,'Type','subplottext');
if ~isempty(h)
  spec.figInset(4) = spec.figInset(4) + 2.5*h(1).FontSize;
end

lay.lastToken = token;
lay.lastSpec = spec;

end

% =========================================================================
function token = validityToken(mtexFig,ax)
% the cheap-to-read things the measurement depends on

token = struct;
token.figSize = get(mtexFig.parent,'Position');
token.axes = double(ax);
token.cBar = double(mtexFig.cBarAxis(:));
token.legend = double(mtexFig.legendAxis(:));
token.fontSize = getMTEXpref('FontSize');

% an sgtitle appears without anything else about the figure changing, so
% nothing else in this token would notice it
sg = findobj(mtexFig.parent,'Type','subplottext');
token.sgTitle = [double(sg(:).'), arrayfun(@(h) h.FontSize,sg(:).')];

% a title or an axis label is written into a text object the axes already
% carries, so nothing else here notices the band it asks for
token.text = {};
if ~isempty(ax)
  txt = findall(referenceAxes(mtexFig,ax),'type','text');
  token.text = {double(txt(:).'), get(txt,'String')};
end

token.spacing = mtexFig.innerPlotSpacing;
token.grid = [mtexFig.ncols mtexFig.nrows];
token.mode = mtexFig.layoutMode;
token.ref = double(mtexFig.referenceAxis);
token.aspect = mtexFig.keepAspectRatio;
token.fixedHeight = mtexFig.fixedAxisHeight;

% a camera move reshapes the axes, and the size of an axes decides how many
% tick labels it carries - both change what there is to measure
token.camera = zeros(numel(ax),15);
token.pos = zeros(numel(ax),4);
for k = 1:numel(ax)
  token.camera(k,:) = cameraState(ax(k));
  token.pos(k,:) = get(ax(k),'Position');
end

end

% -------------------------------------------------------------------------
function ref = referenceAxes(mtexFig,ax)
% the axes whose decorations decide the band for all of them
%
% mtexFigure lays out axes of equal size and is used from inside MTEX, where
% they are alike - a figure that mixes a map with a pole figure wants
% tiledlayout, not this. Where the reference guesses low, say which axes to
% take instead: mtexFig.referenceAxis, or 'takeThisAsReference' on drawNow.

ref = mtexFig.referenceAxis;
if isempty(ref) || ~any(ref == ax), ref = ax(1); end

end

% -------------------------------------------------------------------------
function frac = plotBoxOf(ax)
% where the axes draws inside the rectangle it is given, as fractions of it
%
% A 3d axes inscribes its plot box so that no rotation can take it out of the
% rectangle, which leaves a wide margin at any one view. Everything hung on
% the outside of the axes goes on the box rather than on the rectangle, or it
% stands off the plot by that margin.

frac = [0 0 1 1];
if ~isa(ax,'matlab.graphics.axis.Axes'), return; end

pos = get(ax,'Position');
box = tightPosition(ax);
frac = [(box(1:2)-pos(1:2))./pos(3:4), box(3:4)./pos(3:4)];

end

% -------------------------------------------------------------------------
function state = cameraState(ax)
% a polar axes is circular and carries none of these

if isa(ax,'matlab.graphics.axis.PolarAxes')
  state = zeros(1,15);
else
  state = [ax.CameraPosition ax.CameraTarget ax.CameraUpVector ...
    ax.PlotBoxAspectRatio ax.DataAspectRatio];
end

end

% -------------------------------------------------------------------------
function cBar = colorbarSpec(mtexFig)

cBar = struct('n',0,'side','east','thickness',0,'gap',0,'labelRoom',0,'drop',0);

h = mtexFig.cBarAxis;
h = h(isgraphics(h));
if isempty(h), return; end

fs = get(h(1),'FontSize');
pos = get(h(1),'Position');
isVertical = pos(4) > pos(3);

cBar.n = numel(h);
cBar.side = mtexFig.cBarSide;
cBar.thickness = pos(4 - isVertical); % the short side: width if it stands up
cBar.gap = fs / 2;

% room past the bar for its own ticks and label
l = get(h(1),'Label');
if isempty(get(l,'String'))
  ti = [3.5 1.5] * fs;
elseif get(l,'Rotation') == 0
  ti = [3.5 3.5] * fs;
else
  ti = [5.5 1.5] * fs;
end
cBar.labelRoom = ti(2 - isVertical) + fs/2;

% an exponent on the ruler is drawn past the end of the bar
if h(1).Ruler.Exponent ~= 0, cBar.drop = 2*fs; end

end

% -------------------------------------------------------------------------
function lgd = legendSpec(mtexFig)

lgd = struct('size',[],'side',mtexFig.legendSide,'spacing',mtexFig.legendSpacing);

h = mtexFig.legendAxis;
if isempty(h) || ~all(isgraphics(h)), return; end

pos = get(h,'Position');
lgd.size = pos(3:4);

end

% -------------------------------------------------------------------------
function pin(h)
% pixels, once and for good - see the units invariant in plotting/CLAUDE.md

h = h(isgraphics(h));
if ~isempty(h), set(h,'Units','pixels'); end

end
