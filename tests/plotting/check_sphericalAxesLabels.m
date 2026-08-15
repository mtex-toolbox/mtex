function check_sphericalAxesLabels
% check that spherical plots annotate the reference frame if and only if
% they are not given in crystal coordinates
%
% The annotation is drawn by sphericalPlot/plotAxesLabels from the
% pfAnnotations preference. A crystal symmetry in the argument list marks a
% plot as living in crystal coordinates, there the vertices of the
% fundamental sector are labelled by their Miller indices instead.

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanup = onCleanup(@() set(0,'DefaultFigureVisible',oldVis));

cs = crystalSymmetry('432');
csHex = crystalSymmetry('6/mmm',[1 1 1.6]);
ss = specimenSymmetry('222');
odf = unimodalODF(orientation.byEuler(30*degree,40*degree,10*degree,cs));
mdf = unimodalODF(orientation.byEuler(30*degree,40*degree,10*degree,cs,cs));
f = fibre.beta(cs);
v = vector3d.rand(50);

% --- plots in specimen coordinates - must be annotated ------------------
labeled = {
  'plot(vector3d)'      , @() plot(v)
  'scatter(vector3d)'   , @() scatter(v)
  'smooth(vector3d)'    , @() smooth(v,rand(50,1))
  'quiver(vector3d)'    , @() quiver(v,vector3d.rand(50))
  'S2Fun'               , @() plot(calcDensity(v))
  'S2Fun contourf'      , @() contourf(calcDensity(v))
  'S2VectorField'       , @() plot(S2VectorField.polar(zvector))
  'plotPDF ODF'         , @() plotPDF(odf,Miller(1,0,0,cs))
  'plotPDF orientation' , @() plotPDF(odf.discreteSample(100),Miller(1,0,0,cs))
  'plotPDF fibre'       , @() plotPDF(f,Miller(1,0,0,cs))
  'PoleFigure'          , @() plot(calcPoleFigure(odf,Miller(1,0,0,cs),equispacedS2Grid('resolution',10*degree)))
  'sigmaSections'       , @() plot(odf,'sigma','sections',2)
  'pfSections'          , @() plot(odf,'pf','sections',2)
  'specimenSymmetry'    , @() plot(ss)
  };

% --- plots in crystal coordinates - must not be annotated ---------------
unlabeled = {
  'plot(Miller)'         , @() plot(Miller(1,0,0,cs))
  'smooth(Miller)'       , @() smooth(Miller(vector3d.rand(50),cs),rand(50,1))
  'plotIPDF ODF'         , @() plotIPDF(odf,xvector)
  'plotIPDF orientation' , @() plotIPDF(odf.discreteSample(100),xvector)
  'plotIPDF fibre'       , @() plotIPDF(f,xvector)
  'plotPDF misorientation',@() plotPDF(mdf,Miller(1,0,0,cs))
  'ipfSections'          , @() plot(odf,'ipf','sections',2)
  'axisAngleSections'    , @() plot(mdf,'axisAngle','sections',2)
  'crystalSymmetry'      , @() plot(cs)
  'ipfHSVKey'            , @() plot(ipfHSVKey(csHex))
  'HSVDirectionKey'      , @() plot(HSVDirectionKey(cs))
  'tensor'               , @() plot(stiffnessTensor([...
    236 134 134   0   0   0; 134 236 134   0   0   0; 134 134 236   0   0   0;...
      0   0   0 119   0   0;   0   0   0   0 119   0;   0   0   0   0   0 119],cs))
  };

% --- plots on a plain projection - no spherical axis at all -------------
plain = {
  'phi2Sections'         , @() plot(odf,'phi2','sections',2)
  'phi1Sections'         , @() plot(odf,'phi1','sections',2)
  };

for i = 1:size(labeled,1)
  n = countLabels(labeled{i,2});
  if all(n == 0)
    error('check_sphericalAxesLabels: %s is not annotated',labeled{i,1});
  end
end

for i = 1:size(unlabeled,1)
  n = countLabels(unlabeled{i,2});
  if any(n > 0)
    error('check_sphericalAxesLabels: %s must not be annotated',unlabeled{i,1});
  end
end

for i = 1:size(plain,1)
  n = countLabels(plain{i,2});
  if any(n > 0)
    error('check_sphericalAxesLabels: %s must not be annotated',plain{i,1});
  end
end

% --- a plain function on a crystal frame annotates a, b, c --------------
% the GBND in crystal coordinates is a plain S2FunHarmonic that carries a
% crystalFrame - the specimen X / Y / Z would be meaningless there, the
% frame annotates its own axes instead
sFc = calcDensity(v);
sFc = setFrame(sFc,csHex.frame);
close all
plot(sFc);
str = string(get(findobj(gcf,'type','text','tag','axesLabels'),'String'));
close all
if ~all(ismember(["a","b","c"],str))
  error(['check_sphericalAxesLabels: a crystal framed S2Fun must be ' ...
    'annotated with its crystal axes, found %s'],join(str,', '));
end

% --- a full plot in crystal coordinates gets Miller labels --------------
% the sector vertices in all their symmetrically equivalent positions -
% they are drawn by plotLabels, hence not tagged axesLabels
close all
plot(calcDensity(Miller(v,csHex)),'complete','upper');
txt = findobj(gcf,'type','text','-not','tag','axesLabels');
nMiller = sum(arrayfun(@(h) ~isempty(char(get(h,'String'))),txt));
close all
if nMiller < 7 % 0001 + at least the six equivalents of the rim vertices
  error(['check_sphericalAxesLabels: a complete crystal coordinate plot ' ...
    'must label the symmetrised sector vertices']);
end

% --- every axis of a multi plot is annotated ----------------------------
n = countLabels(@() plotPDF(odf,Miller({1,0,0},{1,1,1},cs)));
if numel(n) < 2 || any(n == 0)
  error('check_sphericalAxesLabels: not all pole figures are annotated');
end

% --- the noLabel flag switches the annotation off -----------------------
if any(countLabels(@() plot(v,'noLabel')) > 0)
  error('check_sphericalAxesLabels: noLabel does not suppress the annotation');
end

% --- replotting into the same axes does not stack annotations -----------
n = countLabels(@() plotTwice(v));
if any(n ~= countLabels(@() plot(v)))
  error('check_sphericalAxesLabels: annotations are duplicated on hold on');
end

% --- the pfAnnotations preference customizes the labels -----------------
storePFA = getMTEXpref('pfAnnotations');
restore = onCleanup(@() setMTEXpref('pfAnnotations',storePFA));
setMTEXpref('pfAnnotations',@(varargin) ...
  text([vector3d.X,vector3d.Y,vector3d.Z],{'RD','TD','ND'},...
  'BackgroundColor','w','tag','axesLabels',varargin{:}));

close all
plot(v);
str = string(get(findobj(gcf,'type','text','tag','axesLabels'),'String'));
close all
if ~all(ismember(["RD","TD","ND"],str))
  error('check_sphericalAxesLabels: the pfAnnotations preference is ignored, found %s',...
    join(str,', '));
end

% --- switching the annotation off for the whole session -----------------
setMTEXpref('pfAnnotations',@(varargin) []);
if any(countLabels(@() plot(v)) > 0)
  error('check_sphericalAxesLabels: an empty pfAnnotations still annotates');
end

disp('check_sphericalAxesLabels passed');

end

% --------------------------------------------------------------------
function n = countLabels(fun)
% number of reference frame labels per axis of a freshly created figure

close all
fun();
fig = gcf;
ax = findobj(fig,'type','axes');
n = zeros(1,numel(ax));
for i = 1:numel(ax)
  n(i) = numel(findobj(ax(i),'type','text','tag','axesLabels'));
end
close all

end

% --------------------------------------------------------------------
function plotTwice(v)

plot(v);
hold on
plot(vector3d.rand(10),'MarkerColor','red');
hold off

end
