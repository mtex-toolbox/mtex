function check_publishedFigure
% what a figure has to satisfy for MATLAB's publish to capture it faithfully
%
% The documentation is built by snapshotting figures on screen, so a figure
% that does not fit the screen, that is still moving, or that draws outside
% itself reaches the published page cropped, squeezed or missing its labels.
% Every check here is one of those, as seen on a page:
%
%  * a grid of sections whose top row was cut off
%  * a pole figure gallery whose titles and row labels were sliced away
%  * axes jumping while the snapshot was taken
%  * a single pole figure printed into the frame of the two before it
%
% See also
% mtexFigure/drawNow mtexLayout/solveLayout check_mtexLayout

oldVis = get(0,'DefaultFigureVisible');
oldPrefs = {getMTEXpref('screenSize'), getMTEXpref('sphericalAxisHeight'), ...
  getMTEXpref('generatingHelpMode')};
cleanUp = onCleanup(@() cleanup(oldVis,oldPrefs)); %#ok<NASGU>

set(0,'DefaultFigureVisible','off');

% the documentation build pins the screen, so a figure that outgrows it is the
% same here as there. The height of a spherical plot is pinned per check: it
% is what makes a grid overflow, and what stops an axes following a resize.
setMTEXpref('screenSize',[1920 1080]);

cs = crystalFrame('432');
odf = unimodalODF(orientation.byEuler(10*degree,20*degree,30*degree,cs), ...
  'halfwidth',15*degree);

checkNothingOutside(odf);
checkBandsReserved(odf,cs);
checkResizeReLaysOut(odf,cs);
checkCaptureIsFaithful(odf,cs);

disp('check_publishedFigure: passed');

end

% =========================================================================
function checkNothingOutside(odf)
% twelve pinned sections fit into their figure, and the figure onto the screen

close all
setMTEXpref('sphericalAxisHeight',370);
unpin = onCleanup(@() setMTEXpref('sphericalAxisHeight',[])); %#ok<NASGU>

plotSection(odf,'sigma','sections',12,'layout',[3,4]);
mtexColorbar
drawnow

[figSize,pos] = geometry;
bound = getMTEXpref('screenSize');

assert(all(figSize <= bound + 1), ...
  'check_publishedFigure: figure %s does not fit the screen %s', ...
  mat2str(round(figSize)),mat2str(bound))

assertInside(pos,figSize,'twelve sigma sections');

end

% -------------------------------------------------------------------------
function checkBandsReserved(odf,cs)
% a title above a spherical plot and a row label beside it stay in the figure
%
% Both hang off an axes that is invisible, so MATLAB reports no TightInset for
% them and the layout has to measure them itself.

% a grid of pinned plots fills the screen, so the top row's title has nowhere
% to go unless the band was reserved for it
close all
setMTEXpref('sphericalAxisHeight',370);
unpin = onCleanup(@() setMTEXpref('sphericalAxisHeight',[])); %#ok<NASGU>

mtexFig = newMtexFigure('layout',[4,4]);
h = Miller({1,0,0},{1,1,1},cs);

for i = 1:8
  plotPDF(odf,h,'doNotDraw');
  mtexTitle(['$\varepsilon = ' num2str(i) '$'])
  ylabel(mtexFig.children(end-1),'row label');
  if i < 8, nextAxis; end
end
mtexFig.drawNow
drawnow

[figSize,pos] = geometry;
ax = mtexFig.children;

for i = 1:numel(ax)
  for h = [ax(i).Title, ax(i).YLabel]
    if isempty(h.String), continue; end
    box = extentInFigure(h,pos(i,:));
    assertInside(box,figSize,sprintf('%s of axes %d',h.Type,i));
  end
end

end

% -------------------------------------------------------------------------
function checkResizeReLaysOut(odf,cs)
% the axes follow a resize, and ignore the nudge a print gives the figure

close all
plotPDF(odf,Miller({1,0,0},{1,1,1},cs));
drawnow

f = gcf;
before = get(gca,'Position');
p = get(f,'Position');

% the callback is what a window manager calls, and a session without a display
% never calls it - so check that it is installed and then do its job
onResize = get(f,'ResizeFcn');
assert(~isempty(onResize), ...
  'check_publishedFigure: the figure has no resize callback, so it cannot re-flow')

set(f,'Position',[p(1:2) round(p(3:4)*1.4)]); onResize(f,[]); drawnow
grown = get(gca,'Position');

assert(grown(4) > before(4) + 1, ...
  'check_publishedFigure: the figure grew by 40 percent and the axes stayed at %g', ...
  before(4))

set(f,'Position',[p(1:2) round(p(3:4)*0.7)]); onResize(f,[]); drawnow
shrunk = get(gca,'Position');

assert(shrunk(4) < grown(4) - 1, ...
  'check_publishedFigure: the figure shrank and the axes stayed at %g',grown(4))

% two pixels is a print rearranging the window, not a user resizing it
settled = get(f,'Position');
set(f,'Position',settled + [0 0 2 2]); onResize(f,[]); drawnow

assert(isequal(round(get(gca,'Position')),round(shrunk)), ...
  'check_publishedFigure: a two pixel nudge moved the axes from %s to %s', ...
  mat2str(round(shrunk)),mat2str(round(get(gca,'Position'))))

end

% -------------------------------------------------------------------------
function checkCaptureIsFaithful(odf,cs)
% while publishing, a print reproduces the figure it is given
%
% Two pole figures, then one into the same figure: the shape changes, and a
% snapshot that prints the previous geometry draws the disc as an ellipse.

close all
setMTEXpref('generatingHelpMode',true);

plotPDF(odf,Miller({1,0,0},{1,1,1},cs));
plotPDF(odf,Miller(1,0,0,cs));
drawnow

f = gcf;

assert(isempty(findall(f,'type','uimenu','label','MTEX')), ...
  'check_publishedFigure: a published figure carries the MTEX menu, which makes MATLAB show a menu bar')

file = [tempname '.png'];
delFile = onCleanup(@() delete(file)); %#ok<NASGU>
print(f,file,'-dpng','-r0');

img = size(imread(file),[1 2]);
figSize = subsref(get(f,'Position'),substruct('()',{[3 4]}));

assert(all(abs(img([2 1]) - figSize) <= 2), ...
  'check_publishedFigure: a %s figure printed as %s', ...
  mat2str(round(figSize)),mat2str(img([2 1])))

setMTEXpref('generatingHelpMode',false);

end

% =========================================================================
function [figSize,pos] = geometry

f = gcf;
figSize = subsref(get(f,'Position'),substruct('()',{[3 4]}));
mtexFig = gcm;
pos = cell2mat(get(mtexFig.children,{'Position'}));

end

% -------------------------------------------------------------------------
function box = extentInFigure(h,axesPos)
% where a text sits in the figure, whatever units it was placed in

u = h.Units; h.Units = 'pixels'; e = h.Extent; h.Units = u;
box = [axesPos(1:2) + e(1:2), e(3:4)];

end

% -------------------------------------------------------------------------
function assertInside(pos,figSize,what)

assert(all(pos(:,1) >= -1) && all(pos(:,2) >= -1), ...
  'check_publishedFigure: %s starts off the figure at %s',what, ...
  mat2str(round(min(pos(:,1:2),[],1))))

right = max(pos(:,1)+pos(:,3));
top = max(pos(:,2)+pos(:,4));

assert(right <= figSize(1)+1 && top <= figSize(2)+1, ...
  'check_publishedFigure: %s reaches [%.0f %.0f] in a %s figure', ...
  what,right,top,mat2str(round(figSize)))

end

% =========================================================================
function cleanup(oldVis,oldPrefs)

close all
setMTEXpref('screenSize',oldPrefs{1});
setMTEXpref('sphericalAxisHeight',oldPrefs{2});
setMTEXpref('generatingHelpMode',oldPrefs{3});
set(0,'DefaultFigureVisible',oldVis);

end
