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
else
  spec.ratio = lay.ratioOf(ax(1));
  spec.inset = zeros(numel(ax),4);
  for k = 1:numel(ax), spec.inset(k,:) = lay.insetOf(ax(k)); end
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
token.spacing = mtexFig.innerPlotSpacing;
token.grid = [mtexFig.ncols mtexFig.nrows];
token.mode = mtexFig.layoutMode;
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
try
  ti = get(h(1),'TightInset');
  ti = ti(1:2) + ti(3:4);
catch
  l = get(h(1),'Label');
  if isempty(get(l,'String'))
    ti = [3.5 1.5] * fs;
  elseif get(l,'Rotation') == 0
    ti = [3.5 3.5] * fs;
  else
    ti = [5.5 1.5] * fs;
  end
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
