function out = layoutFixtures(name)
% the plots @mtexFigure has to lay out, as named fixtures
%
% Syntax
%   names = layoutFixtures       % every fixture name
%   layoutFixtures(name)         % build that one, leaving it as the current figure
%
% Description
% One entry per layout path in @mtexFigure: a single axes and a raster, a
% global colorbar and one per axes, all four colorbar and all four legend
% sides, the three branches of axesInset, a polar axes and a placed
% camera. Synthetic throughout - mtexdata would dominate the runtime and
% adds nothing to a layout question.
%
% See also
% layoutSnapshot mtexFigure/drawNow

names = {'map','mapColorbar','pf1','pf3','pf3Colorbar','pf3ColorbarEach', ...
  'cBarEast','cBarWest','cBarNorth','cBarSouth', ...
  'legendEast','legendWest','legendNorth','legendSouth', ...
  'odfSections','sphereScatter','polarAxes','crystalShapeCam','sgTitle'};

if nargin == 0, out = names; return; end

assert(any(strcmp(name,names)),'layoutFixtures: no fixture named ''%s''',name);

feval(name);
if nargout > 0, out = gcm; end

end

% =========================================================================
function map
ebsd = synthEBSD;
plot(ebsd,ebsd.orientations,'coordinates','on');
end

function mapColorbar
ebsd = synthEBSD;
plot(ebsd,ebsd.prop.bc);
mtexColorbar;
end

function pf1
odf = synthODF;
plotPDF(odf,Miller(1,0,0,odf.CS),'contourf');
end

function pf3
odf = synthODF;
plotPDF(odf,Miller({1,0,0},{1,1,0},{1,1,1},odf.CS),'contourf');
end

function pf3Colorbar
pf3; mtexColorbar;
end

function pf3ColorbarEach
pf3; mtexColorbar('multiple');
end

function cBarEast,  pf3; mtexColorbar('eastoutside');  end
function cBarWest,  pf3; mtexColorbar('westoutside');  end
function cBarNorth, pf3; mtexColorbar('northoutside'); end
function cBarSouth, pf3; mtexColorbar('southoutside'); end

function legendEast,  withLegend('eastoutside');  end
function legendWest,  withLegend('westoutside');  end
function legendNorth, withLegend('northoutside'); end
function legendSouth, withLegend('southoutside'); end

function odfSections
plot(synthODF,'sections',6,'contourf');
end

function sphereScatter
% the axesInset 'visible off' branch, with labels in data units
plot(vector3d.rand(200),'upper','grid');
end

function polarAxes
newMtexFigure;
polaraxes('parent',gcf);
polarplot(linspace(0,2*pi,50),rand(1,50));
end

function crystalShapeCam
% a placed camera, where MATLAB reports TightInset as [0 0 0 0]
cs = crystalSymmetry('6/mmm',[3.2 3.2 5.2],'mineral','Mg');
plot(crystalShape.hex(cs));
end

function sgTitle
pf3;
sgtitle('a super title');
end

% =========================================================================
function withLegend(loc)
% two marker sets so MATLAB has something to build a legend from

plot(vector3d.rand(30),'upper','MarkerColor','r','DisplayName','first');
hold on
plot(vector3d.rand(30),'upper','MarkerColor','b','DisplayName','second');
hold off
legend('show','Location',loc);
drawNow(gcm);

end

% -------------------------------------------------------------------------
function ebsd = synthEBSD
% a 24x24 map - enough for shape and layout, nothing spent on data

rng(0);
[x,y] = ndgrid((0:23)*0.5,(0:23)*0.5);
bc = reshape(1:numel(x),size(x));
ebsd = EBSD(vector3d(x(:),y(:),0*x(:)), rotation.rand(numel(x),1), ...
  ones(numel(x),1), {crystalSymmetry('m-3m','mineral','testPhase')}, ...
  struct('bc',bc(:)));

end

% -------------------------------------------------------------------------
function odf = synthODF
% seeded: two renderings of a fixture have to be comparable by eye, not just
% by their numbers

rng(0);
odf = SO3FunRBF(orientation.rand(5,crystalSymmetry('m-3m')), ...
  SO3DeLaValleePoussinKernel('halfwidth',15*degree));

end
