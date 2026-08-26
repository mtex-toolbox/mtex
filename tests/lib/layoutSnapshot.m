function s = layoutSnapshot(mtexFig)
% every position @mtexFigure is responsible for, in pixels
%
% Syntax
%   s = layoutSnapshot        % of the current mtexFigure
%   s = layoutSnapshot(mtexFig)
%
% Description
% The before-and-after picture for a layout change: axes, colorbars and an
% outside legend, plus the figure they sit in and the derived quantities the
% layout arrived at. Read in pixels regardless of what the objects carry, so
% two snapshots are comparable.
%
% See also
% layoutFixtures

if nargin == 0, mtexFig = gcm; end

s = struct;

fig = mtexFig.parent;
u = fig.Units; fig.Units = 'pixels';
s.figure = fig.Position;
fig.Units = u;

s.axes = readPos(mtexFig.children);
s.colorbar = readPos(mtexFig.cBarAxis);
s.legend = readPos(mtexFig.legendAxis);

s.ncols = mtexFig.ncols;
s.nrows = mtexFig.nrows;
s.axisWidth = mtexFig.axisWidth;
s.axisHeight = mtexFig.axisHeight;
s.tightInset = mtexFig.tightInset;
s.figTightInset = mtexFig.figTightInset;
s.cBarSide = mtexFig.cBarSide;
s.legendSide = mtexFig.legendSide;

end

% -------------------------------------------------------------------------
function pos = readPos(h)
% n x 4 of pixel positions, empty when there is nothing to read

pos = zeros(0,4);
if isempty(h), return; end

h = h(isgraphics(h));
if isempty(h), return; end

old = get(h,{'Units'});
set(h,'Units','pixels');
pos = cell2mat(get(h(:),{'Position'}));
set(h,{'Units'},old);

end
