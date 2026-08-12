function check_holdState
% check the incremental (nesting aware) hold mechanism
%
% Verifies that
%
% * a holdOn guard holds the axes and restores it when the guard dies -
%   also on an early return or an exception
% * nested guards compose, only the outermost one actually releases
% * an explicit hold off by the caller wins over a pending guard
% * the exact NextPlot value is restored, not just 'replace'
% * arrays of axes and deleted axes are handled
% * the MTEX plot functions leave the hold state of their caller untouched
%   and do not print anything to the command window
%
% See also
% holdOn holdRelease copyHoldState

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

% ---------------------------------------------------------------- 1 basics
ax = freshAxes;
if takeAndDrop(ax) == false
  error('check_holdState: the guard did not hold the axes');
end
if ishold(ax)
  error('check_holdState: hold was not released when the guard died');
end

% --------------------------------------------------------------- 2 nesting
ax = freshAxes;
hOuter = holdOn(ax); %#ok<NASGU>
if ~ishold(ax), error('check_holdState: the outer guard did not hold'); end
takeAndDrop(ax);
if ~ishold(ax)
  error('check_holdState: an inner guard released a hold it did not take');
end
clear hOuter
if ishold(ax)
  error('check_holdState: the outer guard did not release after nesting');
end

% ---------------------------------------------------------- 3 error safety
ax = freshAxes;
try
  throwWhileHolding(ax);
  error('check_holdState: throwWhileHolding did not throw');
catch ME
  if ~strcmp(ME.identifier,'MTEX:test:boom'), rethrow(ME); end
end
if ishold(ax)
  error('check_holdState: hold survived an exception');
end

% ----------------------------------------------------------- 4 early return
ax = freshAxes;
returnEarly(ax);
if ishold(ax)
  error('check_holdState: hold survived an early return');
end

% ------------------------------------------------- 5 explicit hold off wins
ax = freshAxes;
hG = holdOn(ax); %#ok<NASGU>
hold(ax,'off');
clear hG
if ishold(ax)
  error('check_holdState: the guard switched hold back on after hold off');
end
% and the axes has to be usable again afterwards
hG = holdOn(ax); %#ok<NASGU>
if ~ishold(ax)
  error('check_holdState: holdOn does not work after an explicit hold off');
end
clear hG

% ---------------------------------------------- 6 exact NextPlot round trip
for state = {'replace','replaceChildren','add'}
  ax = freshAxes;
  ax.NextPlot = state{1};
  before = ax.NextPlot; % MATLAB lower cases the value it stores
  hG = holdOn(ax); %#ok<NASGU>
  clear hG
  if ~strcmp(ax.NextPlot,before)
    error('check_holdState: NextPlot ''%s'' was restored as ''%s''',...
      before, ax.NextPlot);
  end
end

% -------------------------------------------------- 7 arrays, deleted axes
f = figure; ax = [subplot(1,2,1,'parent',f), subplot(1,2,2,'parent',f)];
hG = holdOn(ax); %#ok<NASGU>
if ~all(arrayfun(@ishold,ax))
  error('check_holdState: not all axes of the array were held');
end
clear hG
if any(arrayfun(@ishold,ax))
  error('check_holdState: not all axes of the array were released');
end

f = figure; ax = axes(f);
hG = holdOn(ax); %#ok<NASGU>
close(f)
try
  clear hG
catch ME
  error('check_holdState: releasing a deleted axes failed - %s',ME.message);
end

% ------------------------------------------------- 8 bare statement warning
ax = freshAxes;
w = warning('off','MTEX:holdOn');
lastwarn('','');
holdOn(ax);
[~,id] = lastwarn;
warning(w);
clear ans % the guard the bare call left behind in ans
if ~strcmp(id,'MTEX:holdOn')
  error('check_holdState: holdOn without output argument did not warn');
end

close all

% ------------------------------------------------------- 9 no chatter, ever
% a bare hold(ax) toggles and echoes 'Current plot held' - this is what the
% whole mechanism replaces, so no plot may ever print it again
pf = mtexdata('dubna');
out = evalc('plot(pf)');
if contains(out,'Current plot')
  error('check_holdState: plot(pf) printed hold messages:\n%s',out);
end
close all

% -------------------------------------------------- 10 hold state composition
% every plot has to leave the caller's hold state exactly as it found it,
% and has to accumulate rather than replace when the caller holds
ebsd = mtexdata('small');
ebsd = ebsd('indexed');
grains = calcGrains(ebsd,'threshold',10*degree);
odf = calcDensity(ebsd('Forsterite').orientations,'halfwidth',10*degree);
cs = ebsd('Forsterite').CS;
v = vector3d.rand(20);
ori = ebsd('Forsterite').orientations;
ori = ori(1:10:end);
cS = crystalShape(Miller({1,0,0},{0,1,0},{0,0,1},cs));

% a stiffness tensor for the seismic velocity plot - the six sub plots there
% are the densest hold on/hold off nest in MTEX
C = stiffnessTensor(...
  [[320.5  68.2  71.6     0     0     0];...
  [ 68.2 196.5  76.8     0     0     0];...
  [ 71.6  76.8 233.5     0     0     0];...
  [   0      0     0    64     0     0];...
  [   0      0     0     0    77     0];...
  [   0      0     0     0     0  78.7]],cs,'density',3.355);

cases = { ...
  'plot(pf)',                 @() plot(pf); ...
  'plot(ebsd)',               @() plot(ebsd); ...
  'plot(grains)',             @() plot(grains); ...
  'plot(grains.boundary)',    @() plot(grains.boundary); ...
  'plot(triplePoints)',       @() plot(grains.triplePoints); ...
  'scatter(v)',               @() scatter(v); ...
  'quiver(v,vF)',             @() quiver(v,rotate(v,rotation.byAxisAngle(v,90*degree))); ...
  'plot(v,''3d'')',           @() plot(v,'3d'); ...
  'plotPDF',                  @() plotPDF(odf,Miller(1,0,0,cs)); ...
  'plotIPDF',                 @() plotIPDF(odf,vector3d.X); ...
  'plot(odf,''sections'')',   @() plot(odf,'sections',3); ...
  'plot(ori,''axisAngle'')',  @() plot(ori,'axisAngle'); ...
  'plot(cs)',                 @() plot(cs); ...
  'plotHKL(cs)',              @() plotHKL(cs); ...
  'plotUVW(cs)',              @() plotUVW(cs); ...
  'plot(crystalShape)',       @() plot(cS); ...
  'plot(fundamentalRegion)',  @() plot(fundamentalRegion(cs)); ...
  'plotSeismicVelocities',    @() plotSeismicVelocities(C)};

for k = 1:size(cases,1)
  composes(cases{k,1},cases{k,2});
end

% -------------------------------------------------------- 11 the color order
% hold puts an axes into the color cycling mode, so a plot that holds only
% internally would consume a color of the caller - doc/Rotations/
% RotationTangentSpace.m draws a marker in an explicit color and expects the
% quiver that follows to get the first color of the color order
close all
R = rotation.byAxisAngle(xvector,20*degree);
plot(R,'axisAngle','MarkerColor','red')
ax = gca;
if ax.ColorOrderIndex ~= 1
  error('check_holdState: plot(R) consumed %d color(s) of the caller',...
    ax.ColorOrderIndex - 1);
end
hold on
h = quiver3(SO3TangentVector(spinTensor(0.2*vector3d(1,2,3)),R));
hold off
if max(abs(h.Color(:).' - ax.ColorOrder(1,:))) > 1e-6
  error('check_holdState: the quiver got %s instead of the first color %s',...
    mat2str(h.Color,3),mat2str(ax.ColorOrder(1,:),3));
end

% when the caller holds, the advance is intended and has to be kept
close all
ax = freshAxes; hold(ax,'on');
p1 = plot(ax,1:3,1:3);
p2 = plot(ax,1:3,2:4);
if max(abs(p1.Color - ax.ColorOrder(1,:))) > 1e-6 || ...
    max(abs(p2.Color - ax.ColorOrder(2,:))) > 1e-6
  error('check_holdState: a held axes does not cycle its colors any more');
end
close all

disp('check_holdState: ok')

end

% ------------------------------------------------------------------------

function composes(what,doPlot)
% A plot must not change the hold state of the axes it draws into, and must
% not leave a hold counter behind. The first call is what sets the axes up
% the way MTEX wants it - a plain figure/gca is not an mtexFigure, so the
% plot would just open its own and never touch it - the second call is the
% one under test.

for held = [false true]

  close all
  doPlot();
  ax = gca;
  if held, hold(ax,'on'); end
  before = ax.NextPlot;
  nBefore = numel(ax.Children);

  doPlot();

  noCounter(what);

  if ~isgraphics(ax,'axes')
    % without hold a second plot may legitimately replace the whole figure
    if held
      error('check_holdState: %s deleted a held axes',what);
    end
    continue
  end
  if ~strcmp(ax.NextPlot,before)
    error('check_holdState: %s changed NextPlot of a %s axes from ''%s'' to ''%s''',...
      what, holdName(held), before, ax.NextPlot);
  end

  % a held axes has to accumulate - if the second plot went somewhere else
  % or wiped the first one, hold was not honoured
  if held && numel(ax.Children) <= nBefore
    error(['check_holdState: %s did not add to a held axes ' ...
      '(%d children before, %d after)'], what, nBefore, numel(ax.Children));
  end

end
close all

end

function noCounter(what)
% no axes may be left with an outstanding hold counter

for a = reshape(findall(groot,'type','axes'),1,[])
  n = getappdata(a,'mtexHoldCount');
  if ~isempty(n) && n > 0
    error('check_holdState: %s left a hold counter of %d behind',what,n);
  end
end

end

function s = holdName(held)
if held, s = 'held'; else, s = 'released'; end
end

function ax = freshAxes
close all
figure;
ax = gca;
ax.NextPlot = 'replace';
end

function washeld = takeAndDrop(ax)
% take a guard, report whether the axes is held while it is alive

hG = holdOn(ax); %#ok<NASGU>
washeld = ishold(ax);

end

function throwWhileHolding(ax)

hG = holdOn(ax); %#ok<NASGU>
error('MTEX:test:boom','boom');

end

function returnEarly(ax)

hG = holdOn(ax); %#ok<NASGU>
if ishold(ax), return; end
error('check_holdState: unreachable');

end

function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
