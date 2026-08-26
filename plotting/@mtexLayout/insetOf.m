function inset = insetOf(lay,ax)
% the decoration band of one axes, remembered until that axes changes
%
% Syntax
%   inset = lay.insetOf(ax)
%
% Description
% Measuring costs a forced relayout per axes, and @mtexFigure calls drawNow
% at the end of every plot command - so building a pole figure grid measures
% the same unchanged axes again and again. This keeps the answer until
% something it depends on moves.
%
% The key is the axes **size**, not its position: how much room the
% decorations need depends on how many tick labels fit across it, not on
% where it sits. That is what makes trimming the figure to the size the
% layout asked for cheap - the axes keep their size, so nothing is remeasured.
%
% See also
% mtexLayout/measure axesInset

key = insetKey(ax);

hit = lay.insetAxes == ax;
if any(hit) && isequal(lay.insetKey{hit},key)
  inset = lay.insetValue(hit,:);
  return
end

inset = axesInset(ax);

if any(hit)
  lay.insetKey{hit} = key;
  lay.insetValue(hit,:) = inset;
else
  lay.insetAxes = [lay.insetAxes; ax];
  lay.insetKey = [lay.insetKey; {key}];
  lay.insetValue = [lay.insetValue; inset];
end

% drop entries whose axes have gone
alive = isgraphics(lay.insetAxes);
if ~all(alive)
  lay.insetAxes = lay.insetAxes(alive);
  lay.insetKey = lay.insetKey(alive);
  lay.insetValue = lay.insetValue(alive,:);
end

end

% -------------------------------------------------------------------------
function key = insetKey(ax)
% everything the measurement depends on that can be read without forcing a
% relayout - which is what makes the key cheaper than the measurement

pos = get(ax,'Position');
key = struct('size',pos(3:4),'class',class(ax));

if isa(ax,'matlab.graphics.axis.PolarAxes')
  key.font = get(ax,'FontSize');
  return
end

key.font = get(ax,'FontSize');
key.visible = char(get(ax,'Visible'));
key.xcolor = mat2str(get(ax,'XColor'));
key.noTicks = all(get(ax,'ticklength') == 0);
key.camera = [ax.CameraPosition ax.CameraTarget ax.CameraUpVector ...
  ax.PlotBoxAspectRatio ax.DataAspectRatio ...
  double(strcmp(ax.CameraPositionMode,'manual')) ...
  double(strcmp(ax.PlotBoxAspectRatioMode,'manual'))];

% tick labels and axis labels are what the band is mostly made of
key.ticks = [numel(get(ax,'XTick')) numel(get(ax,'YTick'))];
key.tickLabels = [flat(get(ax,'XTickLabel')) flat(get(ax,'YTickLabel'))];
key.labels = [flat(ax.XLabel.String) '|' flat(ax.YLabel.String) '|' ...
  flat(ax.ZLabel.String) '|' flat(ax.Title.String)];

% text placed in data units sticks out of the axes and is measured too
txt = findall(ax,'type','text','unit','data');
key.text = '';
if ~isempty(txt)
  key.text = [flat(get(txt,'string')) mat2str(cell2mat(ensurecell(get(txt,'position'))))];
end

end

% -------------------------------------------------------------------------
function s = flat(c)
% any of MATLAB's string shapes as one char row

if isempty(c), s = ''; return; end
if ~iscell(c), c = ensurecell(c); end
c = cellfun(@(x) char(string(x)),c,'UniformOutput',false);
s = strjoin(reshape(c,1,[]),char(1));

end
