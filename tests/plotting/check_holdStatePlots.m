function check_holdStatePlots
% check that every MTEX plot leaves the caller's hold state untouched
%
% Split out of check_holdState, whose other half - the holdOn/holdRelease
% guard semantics - needs no data and lives in core/check_holdGuard. This
% half sweeps 18 plot commands in both hold states and was the expensive
% part: it loads two data sets, reconstructs grains, estimates an ODF and
% then draws roughly 72 plots, plotSeismicVelocities with its six sub plots
% being the densest hold nest in MTEX.
%
% Also checks that no plot prints 'Current plot held' - a bare hold(ax)
% echoes it, and replacing that is the whole point of the mechanism - and
% that a plot does not consume a colour of the caller's colour order.
%
% Figures are made invisible and closed by runTests, so this file does not
% manage DefaultFigureVisible itself.
%
% See also
% holdOn holdRelease check_holdGuard

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
% every plot leaves the caller's hold state as it found it, and accumulates when held
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
% a plot that holds only internally must not consume a color of the caller
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

% --------------------------------------- the 3d background sphere composes
checkEmptySphereBackground;

disp('check_holdState: ok')

end

% -------------------------------------------------------------------------
function checkEmptySphereBackground
% quiver3 draws its arrows ON TOP of a background sphere
%
% plotEmptySphere used to end with hold(ax,'on'), deliberately leaving the
% axes held so that its CALLER could draw on top of the background it had
% just laid down. The incremental hold rewrite read that as a missing
% release and gave it an onCleanup guard, which is released the moment
% plotEmptySphere returns - so the plot that followed started a fresh axes
% and the sphere and its grid were gone from every quiver3.
%
% The hold has to span the background AND the field, which is what
% @vector3d/scatter3d already did and the two quiver3 now do as well.
%
% Note the objects are drawn with 'handlevisibility','off', so they are
% invisible to findobj - this has to use findall.

sVF = S2VectorFieldHarmonic(@(v) vector3d(v.x,v.y,0*v.x));
sAF = S2AxisFieldHarmonic(@(v) vector3d(-v.y,v.x,0*v.x,'antipodal'));
v3d = equispacedS2Grid('resolution',20*degree);

cases = {'S2VectorField/quiver3', @() quiver3(sVF), ...
         'S2AxisField/quiver3',   @() quiver3(sAF), ...
         'vector3d/scatter3d',    @() scatter3d(v3d)};

for k = 1:2:numel(cases)
  close all; figure; ax = gca;
  cases{k+1}();

  nSurf = numel(findall(ax,'Type','surface'));
  nLine = numel(findall(ax,'Type','line'));

  if nSurf < 1 || nLine < 10
    error(['check_holdState: %s lost the background sphere - ' ...
      'found %d surface and %d line objects'],cases{k},nSurf,nLine);
  end
end

% and the caller's hold state survives it, in both directions
for held = [false true]
  close all; figure; ax = gca; ax.NextPlot = 'replace';
  if held, hold(ax,'on'); end
  before = ishold(ax);
  quiver3(sVF);
  if ishold(ax) ~= before
    error('check_holdState: quiver3 changed the hold state from %d to %d', ...
      before,ishold(ax));
  end
end

close all

end

% -------------------------------------------------------------------------
function ax = freshAxes
close all
figure;
ax = gca;
ax.NextPlot = 'replace';
end

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

