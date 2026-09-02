function check_nextAxis
% check that nextAxis decides which axes the next plot lands in
%
% nextAxis selects a cell of a multiplot. The plot that follows paints that
% cell and leaves the rest of the arrangement alone - whether the cell was
% empty or already occupied. Only a plot that nobody selected an axes for
% replaces the whole figure.
%
% See also
% nextAxis newMtexFigure mtexFigure

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

checkRepaintsSelectedCell
checkHoldOnOverlays
checkSelectionIsConsumed
checkUnselectedPlotReplacesFigure

disp('check_nextAxis: passed');

end

% =========================================================================
function checkRepaintsSelectedCell
% a selected cell is repainted, the gallery around it survives

gallery
nextAxis(2,3); plot(vector3d(1,-1,1),'upper','doNotDraw');

assertLayout('repaint');
assertPoints(6,1,'repaint: the selected cell');
assertPoints(1,3,'repaint: an untouched cell');

end

% =========================================================================
function checkHoldOnOverlays
% hold on still draws on top of what the cell holds

gallery
nextAxis(2,3); hold on; plot(vector3d(1,-1,1),'upper','doNotDraw'); hold off

assertLayout('hold on');
assertPoints(6,[5 1],'hold on: the selected cell');

end

% =========================================================================
function checkSelectionIsConsumed
% the selection lasts for one plot, so the next one opens a new figure

gallery
nextAxis(2,3); plot(vector3d(1,-1,1),'upper','doNotDraw');
plot(vector3d(0,0,1),'upper','doNotDraw');

f = gcm;
if numel(f.children) ~= 1
  error('check_nextAxis: a second plot stayed in the gallery, %d axes',numel(f.children));
end

end

% =========================================================================
function checkUnselectedPlotReplacesFigure
% without a nextAxis the multiplot is replaced, as a plot command always did

gallery
plot(vector3d(0,0,1),'upper','doNotDraw');

f = gcm;
if numel(f.children) ~= 1
  error('check_nextAxis: an unselected plot kept %d axes',numel(f.children));
end

end

% =========================================================================
function gallery
% a 2x3 layout with the first and the last cell painted

close all
newMtexFigure('layout',[2,3]);
plot([xvector,yvector,zvector],'upper','doNotDraw');
nextAxis(2,3); plot(vector3d.rand(5),'upper','doNotDraw');

end

% =========================================================================
function assertLayout(tag)
% the gallery is still a 2x3 layout the user fixed

f = gcm;
if numel(f.children) ~= 6 || f.nrows ~= 2 || f.ncols ~= 3 || ~strcmp(f.layoutMode,'user')
  error('check_nextAxis: %s left %d axes, layout [%d %d], mode %s', ...
    tag,numel(f.children),f.nrows,f.ncols,f.layoutMode);
end

end

% =========================================================================
function assertPoints(id,n,tag)
% the number of data points each scatter of one cell holds

f = gcm;
s = findobj(f.children(id),'Type','scatter');
found = sort(arrayfun(@(h) numel(h.XData),s));

if ~isequal(reshape(found,1,[]),sort(reshape(n,1,[])))
  error('check_nextAxis: %s holds [%s] points, expected [%s]', ...
    tag,num2str(reshape(found,1,[])),num2str(sort(reshape(n,1,[]))));
end

end

% =========================================================================
function cleanup(oldVis)

close all
set(0,'DefaultFigureVisible',oldVis);

end
