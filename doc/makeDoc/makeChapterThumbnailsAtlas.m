function makeChapterThumbnailsAtlas(varargin)
%MAKECHAPTERTHUMBNAILSATLAS Render an alternative documentation tile set.
%
% Syntax
%   makeChapterThumbnailsAtlas
%   makeChapterThumbnailsAtlas('only',{'Vectors','EBSDAnalysis'})
%   makeChapterThumbnailsAtlas('outDir',folder)
%
% Description
% This is an intentionally self-contained alternative to the chapter
% thumbnails in makeDoc/general.  It never writes there: by default the
% images are placed in makeDoc/chapterThumbnailsAtlas so that two designs
% can be reviewed side by side.  The visual system uses the same light
% background as the MTEX documentation and one chapter-specific subject
% per tile.

outDir = get_option(varargin,'outDir',fullfile(mtex_path,'doc','makeDoc', ...
  'chapterThumbnailsAtlas'));
if ~exist(outDir,'dir'), mkdir(outDir); end

names = {'Tutorials','GeneralConcepts','Vectors','Rotations', ...
  'CrystalGeometry','CrystalOrientations','Misorientations','ODFAnalysis', ...
  'PoleFigureAnalysis','EBSDAnalysis','Grains','GrainBoundaries', ...
  'EBSD3Analysis','Tensors','Elasticity','Plasticity','PhaseTransitions', ...
  'SphericalFunctions','SO3Functions','Plotting'};

only = get_option(varargin,'only',{});
if ~isempty(only)
  if ~iscell(only), only = {only}; end
  missing = setdiff(only,names);
  if ~isempty(missing)
    error('MTEX:thumbnails','no such chapter: %s',strjoin(missing,', '));
  end
  names = names(ismember(names,only));
end

oldConvention = plottingConvention.default;
plottingConvention.default('y↑→x');
cleanup = onCleanup(@() plottingConvention.default(oldConvention));

for k = 1:numel(names)
  close all
  fileName = fullfile(outDir,['chapter_' names{k} '.png']);
  try
    renderTile(names{k});
    finishTile(fileName);
    fprintf('ATLAS %s\n',names{k});
  catch err
    fprintf(2,'ATLASFAIL %s :: %s\n',names{k}, ...
      getReport(err,'extended','hyperlinks','off'));
  end
end
close all

end

% -------------------------------------------------------------------------
function renderTile(name)

p = palette;

switch name
  case 'Tutorials'
    [~,ax] = canvas2d;
    % A miniature analysis journey: measurements, grains, interpretation.
    panel(ax,[.07 .30 .24 .40]);
    panel(ax,[.38 .30 .24 .40]);
    panel(ax,[.69 .30 .24 .40]);
    rng(4)
    for j = 1:9
      for i = 1:7
        c = p.data(1+mod(i+2*j,5),:);
        rectangle(ax,'Position',[.085+(i-1)*.029 .34+(j-1)*.035 .026 .031], ...
          'FaceColor',c,'EdgeColor','none');
      end
    end
    voronoiGlyph(ax,[.50 .50],.105);
    poleGlyph(ax,[.81 .50],.105);
    arrow2(ax,[.315 .50],[.375 .50],p.gold,4);
    arrow2(ax,[.625 .50],[.685 .50],p.gold,4);
    plot(ax,[.10 .90],[.22 .22],'Color',[p.cyan .45],'LineWidth',2);
    plot(ax,[.10 .50 .90],[.22 .15 .22],'o','Color',p.cyan, ...
      'MarkerFaceColor',p.cyan,'MarkerSize',7,'LineWidth',2);

  case 'GeneralConcepts'
    [~,ax] = canvas2d;
    % A representative branching workflow: both grain reconstruction and
    % ODF estimation start from EBSD, while parent reconstruction starts
    % from the grain structure.
    objectCard(ax,[.04 .62 .38 .28],'EBSD',p.cyan);
    objectCard(ax,[.58 .62 .38 .28],'grains',p.gold);
    objectCard(ax,[.04 .10 .38 .28],'ODF',p.coral);
    objectCard(ax,[.58 .10 .38 .28],sprintf('parent\ngrains'),p.blue);

    % At landing-page size the topology matters more than function names.
    % Use the full gap for strong arrows and leave out miniature labels.
    arrow2(ax,[.43 .76],[.57 .76],p.fg,5);
    arrow2(ax,[.23 .61],[.23 .39],p.fg,5);
    arrow2(ax,[.77 .61],[.77 .39],p.fg,5);

  case 'Vectors'
    [~,ax] = canvas3d;
    [x,y,z] = sphere(36);
    surf(ax,.72*x,.72*y,.72*z,'FaceColor',p.panel,'FaceAlpha',.30, ...
      'EdgeColor',p.muted,'EdgeAlpha',.12);
    hold(ax,'on')
    % Keep the three directions clearly separated in projection and only
    % slightly outside the reference sphere.
    arrow3(ax,[0 0 0],[.88 .16 .04],p.coral,6);
    arrow3(ax,[0 0 0],[-.36 .58 .31],p.cyan,6);
    arrow3(ax,[0 0 0],[.08 -.30 .76],p.gold,6);
    scatter3(ax,0,0,0,110,p.fg,'filled');
    view(ax,125,21); axis(ax,[-1.05 1.05 -1.05 1.05 -.95 1.05]);

  case 'Rotations'
    [~,ax] = canvas2d;
    % One reference frame and several rotated images make composition and
    % non-commuting alternatives visible at thumbnail scale.
    cubeGlyph(ax,[.23 .49],.16,-10,p.fg,.85);
    cubeGlyph(ax,[.69 .70],.10,18,p.cyan,.95);
    cubeGlyph(ax,[.73 .49],.10,-7,p.gold,.95);
    cubeGlyph(ax,[.67 .28],.10,34,p.coral,.95);
    arrow2(ax,[.37 .53],[.56 .66],p.cyan,3);
    arrow2(ax,[.39 .49],[.59 .49],p.gold,3);
    arrow2(ax,[.37 .44],[.54 .31],p.coral,3);
    scatter(ax,.46,.49,80,p.fg,'filled');

  case 'CrystalGeometry'
    % The simulated quartz pattern links planes, directions and zone axes
    % in one image, following CrystalOperations.m without its dense labels.
    data = load(fullfile(mtexDataPath,'quartzPattern.mat'));
    pattern = data.pattern;
    cs = pattern.CS;
    m = Miller(-1,0,1,0,cs,'hkil');
    r = Miller(0,-1,1,1,cs,'hkil');
    z = Miller(0,1,-1,1,cs,'hkil');
    mtexCanvas;
    [~,ax] = plot(pattern,'resolution',.30*degree,'complete','upper','noLabel');
    mtexColorMap black2white
    hold on
    circle(m,'Parent',ax,'Color',p.cyan,'LineWidth',3);
    circle(r,'Parent',ax,'Color',p.coral,'LineWidth',3);
    circle(z,'Parent',ax,'Color',p.gold,'LineWidth',3);
    d = round(cross(m,r));
    plot(d,'Parent',ax,'Marker','s','MarkerSize',9, ...
      'MarkerFaceColor',p.cyan,'MarkerEdgeColor',p.fg,'noLabel');
    hold off
    polishMTEX;
    colormap(gcf,gray(256));

  case 'CrystalOrientations'
    [~,ax] = canvas3d;
    set(ax,'Projection','orthographic');
    drawCrystalAxes(ax,p);
    view(ax,132,22); axis(ax,[-1.35 1.35 -1.35 1.35 -1.30 1.38]);
    set(ax,'Position',[.10 .10 .80 .80]);

  case 'Misorientations'
    % A Japan-law quartz twin.  Its inclined c axes make the relation
    % visible when the two translucent MTEX crystal shapes are superposed.
    cs = loadCIF('quartz');
    cS = crystalShape.quartz(cs,'simple');
    twinAxis = Miller(1,0,-1,0,cs);
    twin = orientation.byAxisAngle(twinAxis,84.55*degree);
    mtexCanvas;
    plot(cS,'FaceColor',p.cyan,'FaceAlpha',.31, ...
      'EdgeColor',p.cyan,'LineWidth',1.6);
    hold on
    plot(twin*cS,'FaceColor',p.coral,'FaceAlpha',.31, ...
      'EdgeColor',p.coral,'LineWidth',1.6);
    hold off
    view(142,18); axis tight equal off vis3d
    camzoom(.72)
    polishMTEX;

  case 'ODFAnalysis'
    % Four phi2 sections of MTEX's standard SantaFe ODF are both canonical
    % and readable in the 2-by-2 landing-page format.
    mtexCanvas;
    plotSection(SantaFe,'phi2',[15 30 45 60]*degree,'contourf', ...
      'resolution',3*degree,'layout',[2 2],'innerPlotSpacing',0, ...
      'outerPlotSpacing',0,'noLabel','silent','coordinates','off', ...
      'labels','off');
    mtexColorMap LaboTeX
    % The phi2 corner annotations are inside their axes, but drawNow counts
    % their text extent as an external inset and opens a gap between rows.
    % Freeze the completed plot and place its axes as touching quadrants.
    drawnow;
    mtexFig = gcm;
    set(mtexFig.parent,'ResizeFcn',[]);
    set(mtexFig.parent,'Units','pixels','Position',[80 80 720 720]);
    panelPosition = [1 361 360 360; 361 361 360 360; ...
      1 1 360 360; 361 1 360 360];
    for k = 1:4
      set(mtexFig.children(k),'Units','pixels','Position',panelPosition(k,:));
    end
    drawnow;

  case 'PoleFigureAnalysis'
    % Recalculated pole figures from the smooth Dubna ODF, rather than a
    % synthetic single pole or the visibly sampled raw measurements.
    odf = SO3Fun.dubna;
    h = Miller({1,0,-1,0},{0,1,-1,1},{1,0,-1,1},{1,1,-2,2},odf.CS);
    mtexCanvas;
    plotPDF(odf,h,'contourf','resolution',2.5*degree, ...
      'antipodal','layout',[2 2],'silent');
    polishMTEX;

  case 'EBSDAnalysis'
    ebsd = forsteritePatch;
    key = ipfColorKey(ebsd('Forsterite'));
    colors = key.orientation2color(ebsd('Forsterite').orientations);
    mtexCanvas;
    plot(ebsd('Forsterite'),colors,'micronbar','off');
    polishMTEX;

  case 'Grains'
    [~,grains] = forsteriteGrains;
    grains = smoothBoundary(grains,4);
    mtexCanvas;
    plot(grains,grains.area,'micronbar','off');
    hold on
    plot(grains.boundary,'lineColor',p.bg,'LineWidth',1.8);
    hold off
    polishMTEX;

  case 'GrainBoundaries'
    % The CSL data has a strong population of Sigma-3 twin boundaries.
    % Draw all interfaces quietly and let that crystallographically
    % meaningful subset carry the image.
    ebsd = mtexdata('csl');
    ebsd = ebsd(inpolygon(ebsd,[170 55 160 160]));
    [grains,ebsd] = calcGrains(ebsd,'minPixel',3);
    grains = smoothBoundary(grains,5);
    gB = grains.boundary('iron','iron');
    twinBoundary = gB(gB.isTwinning(CSL(3,ebsd('iron').CS),3*degree));
    mtexCanvas;
    plot(grains.boundary,'lineColor',p.muted,'LineWidth',2.1, ...
      'micronbar','off');
    hold on
    plot(twinBoundary,'lineColor',p.coral,'LineWidth',3.3);
    hold off
    polishMTEX;

  case 'EBSD3Analysis'
    grains = grain3d.load(fullfile(mtexDataPath,'EBSD', ...
      'SmallIN100_MeshStats.dream3d'));
    mtexCanvas;
    plot(grains,grains.meanOrientation,'LineStyle','none','micronbar','off');
    view(132,24); axis tight equal vis3d
    hold on
    outlineVolume(gca,p.fg,3.2);
    hold off
    polishMTEX;

  case 'Tensors'
    [~,ax] = canvas3d;
    stressTensorGlyph(ax,p);
    view(ax,132,22); axis(ax,[-1.4 1.4 -1.4 1.4 -1.25 1.35]);

  case 'Elasticity'
    % The radial Young's-modulus surface is the standard elasticity image:
    % its radius and colour both encode the directional stiffness.
    cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942], ...
      'mineral','Olivine');
    C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor', ...
      'Olivine1997PC.GPa'),cs);
    [~,ax] = canvas3d;
    elasticModulusGlyph(ax,C.YoungsModulus);
    view(ax,132,24); axis(ax,[-1.18 1.18 -1.18 1.18 -1.18 1.18]);

  case 'Plasticity'
    % Follow the Schmid-factor figure: a skew {111} plane inside the cube,
    % with slip, plane-normal and loading arrows all visible.
    cs = crystalSymmetry('m-3m');
    cS = crystalShape.cube(cs);
    sS = slipSystem.fcc(cs); sS = sS(1);
    loadDirection = normalize(vector3d(.35,.55,1));
    mtexCanvas;
    plot(cS,'faceColor',p.cyan,'faceAlpha',.18,'edgeColor',p.fg, ...
      'lineWidth',1.8);
    hold on
    plot(cS,sS,'faceColor',p.blue,'faceAlpha',.42);
    b = normalize(vector3d(sS.b));
    n = normalize(vector3d(sS.n));
    arrow3d(.68*b,'anchor',-.34*b,'faceColor',p.coral,'lineWidth',2);
    arrow3d(-.50*n,'anchor',.25*n,'faceColor',p.gold,'lineWidth',2);
    arrow3d(.80*loadDirection,'anchor',-.40*loadDirection, ...
      'faceColor',p.cyan,'lineWidth',2);
    hold off
    view(132,20); axis off equal vis3d
    camzoom(.55)
    polishMTEX;

  case 'PhaseTransitions'
    % Use the established parent-grain reconstruction thumbnail from the
    % MTEX website: child variants are nested inside bold recovered-parent
    % boundaries, with one parent grain explicitly selected.
    source = fullfile(fileparts(mtex_path),'web','images','thumbnails', ...
      'MaParentGrainReconstruction.jpg');
    if isfile(source)
      fig = figure('Visible','off','Color',p.bg,'Position',[80 80 720 720]);
      ax = axes(fig,'Position',[0 0 1 1]);
      image(ax,imread(source)); axis(ax,'image','off');
    else
      [~,ax] = canvas2d;
      parentVariantGlyph(ax,p);
    end

  case 'SphericalFunctions'
    % Keep MTEX's memorable example: the expression is itself a spherical
    % function, and stays recognisable at much smaller sizes than a globe.
    mtexCanvas;
    plot(S2Fun.smiley,'upper','noLabel');
    polishMTEX;

  case 'SO3Functions'
    [~,ax] = canvas3d;
    orientationFunctionGlyph(ax,p);
    view(ax,132,23); axis(ax,[-1.15 1.15 -1.15 1.15 -.15 1.65]);

  case 'Plotting'
    [~,ax] = canvas2d;
    plotModesGlyph(ax,p);
end

end

% -------------------------------------------------------------------------
function p = palette
p.bg = [250 251 252]/255;
p.panel = [235 241 245]/255;
p.fg = [32 49 61]/255;
p.muted = [116 137 151]/255;
p.cyan = [0 151 157]/255;
p.gold = [226 145 27]/255;
p.coral = [214 67 74]/255;
p.blue = [52 91 182]/255;
p.data = [p.cyan; p.gold; p.coral; p.blue; [126 82 177]/255];
end

function [fig,ax] = canvas2d
p = palette;
fig = figure('Visible','off','Color',p.bg,'Position',[80 80 720 720]);
ax = axes(fig,'Position',[0 0 1 1],'Color',p.bg);
hold(ax,'on'); axis(ax,[0 1 0 1]); axis(ax,'off');
rectangle(ax,'Position',[0 0 1 1],'FaceColor',p.bg,'EdgeColor','none');
% Quiet cartographic grid: enough texture to unite the set at large sizes.
for t = .08:.12:.92
  plot(ax,[t t],[.04 .96],'Color',[p.muted .045],'LineWidth',1);
  plot(ax,[.04 .96],[t t],'Color',[p.muted .045],'LineWidth',1);
end
end

function [fig,ax] = canvas3d
p = palette;
fig = figure('Visible','off','Color',p.bg,'Position',[80 80 720 720]);
ax = axes(fig,'Position',[.02 .02 .96 .96],'Color',p.bg);
hold(ax,'on'); axis(ax,'equal'); axis(ax,'off'); axis(ax,'vis3d');
set(ax,'Clipping','off','Projection','perspective');
end

function mtexCanvas
p = palette;
figure('Visible','off','Color',p.bg,'Position',[80 80 720 720]);
end

function finishTile(fileName)
p = palette;
fig = gcf;
set(fig,'Color',p.bg);
drawnow;
exportgraphics(fig,fileName,'Resolution',120,'BackgroundColor',p.bg);
% Normalize pixel dimensions without touching the production thumbnail set.
if isunix
  magick = 'magick';
  if system('command -v magick > /dev/null 2>&1') ~= 0 && ...
      system('command -v distrobox-host-exec > /dev/null 2>&1') == 0
    magick = 'distrobox-host-exec magick';
  end
  if contains(fileName,'ODFAnalysis')
    % R2026a exportgraphics may rasterize this nominally square mtexFigure
    % a few percent taller than wide.  Preserve the complete 2-by-2 layout;
    % fill-and-crop would otherwise remove the phi2 labels and boundary data.
    cmd = sprintf([ '%s "%s" -resize 420x420 -gravity center ' ...
      '-background "rgb(250,251,252)" -extent 420x420 "%s"'], ...
      magick,fileName,fileName);
  elseif contains(fileName,'Misorientations')
    cmd = sprintf([ '%s "%s" -resize 370x370 -gravity center ' ...
      '-background "rgb(250,251,252)" -extent 420x420 "%s"'], ...
      magick,fileName,fileName);
  elseif contains(fileName,'CrystalOrientations')
    cmd = sprintf([ '%s "%s" -resize 380x380 -gravity center ' ...
      '-background "rgb(250,251,252)" -extent 420x420 "%s"'], ...
      magick,fileName,fileName);
  else
    cmd = sprintf('%s "%s" -resize 420x420^ -gravity center -extent 420x420 "%s"', ...
      magick,fileName,fileName);
  end
  status = system(cmd);
  if status ~= 0
    warning('MTEX:thumbnails','ImageMagick resize failed for %s',fileName);
  end
end
end

function polishMTEX
p = palette;
fig = gcf;
set(fig,'Color',p.bg);
delete(findall(fig,'Type','ColorBar'));
delete(findall(fig,'Type','Legend'));
set(findall(fig,'Type','Text'),'Visible','off');
axs = findall(fig,'Type','Axes');
for ax = reshape(axs,1,[])
  set(ax,'Color',p.bg,'XColor',p.muted,'YColor',p.muted, ...
    'ZColor',p.muted);
  axis(ax,'off');
end
colormap(fig,atlasMap(256));
end

function map = atlasMap(n)
anchors = [45 55 138; 35 112 170; 25 163 157; 129 196 110; ...
  243 190 63; 220 75 69; 119 39 93] / 255;
x = linspace(0,1,size(anchors,1));
map = interp1(x,anchors,linspace(0,1,n),'pchip');
map = min(max(map,0),1);
end

% -- 2D drawing helpers ---------------------------------------------------
function panel(ax,pos)
p = palette;
rectangle(ax,'Position',pos,'Curvature',.12,'FaceColor',[p.panel .94], ...
  'EdgeColor',[p.muted .25],'LineWidth',1.5);
end

function objectCard(ax,pos,label,accent)
p = palette;
rectangle(ax,'Position',pos,'Curvature',.16,'FaceColor',p.panel, ...
  'EdgeColor',accent,'LineWidth',3);
plot(ax,pos(1)+.035,pos(2)+pos(4)-.045,'o','MarkerFaceColor',accent, ...
  'MarkerEdgeColor','none','MarkerSize',11);
text(ax,pos(1)+pos(3)/2,pos(2)+pos(4)/2,label,'HorizontalAlignment','center', ...
  'VerticalAlignment','middle','Color',p.fg,'FontSize',32,'FontWeight','bold');
end

function arrow2(ax,a,b,color,width)
d = b-a;
quiver(ax,a(1),a(2),d(1),d(2),0,'Color',color,'LineWidth',width, ...
  'MaxHeadSize',.75);
end

function circularArrow(ax,c,r,a0,a1,color)
t = linspace(a0,a1,90)*pi/180;
plot(ax,c(1)+r*cos(t),c(2)+r*sin(t),'Color',color,'LineWidth',6);
q0 = [c(1)+r*cos(t(end-2)),c(2)+r*sin(t(end-2))];
q1 = [c(1)+r*cos(t(end)),c(2)+r*sin(t(end))];
arrow2(ax,q0,q1,color,6);
end

function cubeGlyph(ax,c,s,angleDeg,color,alpha)
q = [-1 -1; 1 -1; 1 1; -1 1]' * s;
a = angleDeg*pi/180;
R = [cos(a) -sin(a); sin(a) cos(a)]; q = R*q;
shift = R*[.48*s; .66*s];
front = q + c(:); back = q + c(:) + shift;
patch(ax,front(1,:),front(2,:),color,'FaceAlpha',.08*alpha, ...
  'EdgeColor',color,'EdgeAlpha',alpha,'LineWidth',3);
patch(ax,back(1,:),back(2,:),color,'FaceAlpha',.18*alpha, ...
  'EdgeColor',color,'EdgeAlpha',alpha,'LineWidth',3);
for k = 1:4
  plot(ax,[front(1,k) back(1,k)],[front(2,k) back(2,k)], ...
    'Color',[color alpha],'LineWidth',3);
end
end

function voronoiGlyph(ax,c,r)
p = palette;
t = linspace(0,2*pi,7); t(end)=[];
pts = c + r*[cos(t(:)) sin(t(:))];
for k=1:6
  q = [c; pts(k,:); pts(mod(k,6)+1,:)];
  patch(ax,q(:,1),q(:,2),p.data(1+mod(k-1,5),:),'FaceAlpha',.75, ...
    'EdgeColor',p.bg,'LineWidth',2);
end
end

function poleGlyph(ax,c,r)
p = palette;
t = linspace(0,2*pi,120);
plot(ax,c(1)+r*cos(t),c(2)+r*sin(t),'Color',p.fg,'LineWidth',2);
for a = [20 75 145 215 286]
  rr = .65*r; q = c + rr*[cosd(a) sind(a)];
  scatter(ax,q(1),q(2),44,p.data(1+mod(round(a/40),5),:),'filled');
end
plot(ax,[c(1)-r c(1)+r],[c(2) c(2)],'Color',[p.muted .45]);
plot(ax,[c(1) c(1)],[c(2)-r c(2)+r],'Color',[p.muted .45]);
end

function poleContour(ax,c,r,p)
n = 260; x = linspace(-1,1,n); [X,Y] = meshgrid(x); R = hypot(X,Y);
Z = .10 + 1.7*exp(-((X+.38).^2+(Y-.18).^2)/.055) + ...
  1.25*exp(-((X-.34).^2+(Y+.34).^2)/.075) + ...
  .90*exp(-((X-.18).^2+(Y-.48).^2)/.045) + ...
  .55*exp(-((X+.28).^2+(Y+.55).^2)/.04);
Z(R>1) = nan;
contourf(ax,c(1)+r*X,c(2)+r*Y,Z,11,'LineColor','none');
colormap(ax,atlasMap(256));
t=linspace(0,2*pi,300);
plot(ax,c(1)+r*cos(t),c(2)+r*sin(t),'Color',p.fg,'LineWidth',4);
plot(ax,[c(1)-r c(1)+r],[c(2) c(2)],'Color',[p.fg .22],'LineWidth',1);
plot(ax,[c(1) c(1)],[c(2)-r c(2)+r],'Color',[p.fg .22],'LineWidth',1);
for q = [.19 .39 .59 .79]
  plot(ax,c(1)+q*r*cos(t),c(2)+q*r*sin(t),'Color',[p.fg .10]);
end
end

% -- 3D drawing helpers ---------------------------------------------------
function arrow3(ax,a,b,color,width)
d = b-a;
quiver3(ax,a(1),a(2),a(3),d(1),d(2),d(3),0,'Color',color, ...
  'LineWidth',width,'MaxHeadSize',.28);
end

function drawCrystalAxes(ax,p)
% The muted orthogonal triad is the specimen frame.  The colored triad and
% cube are one crystal frame in its specimen orientation.
arrow3(ax,[0 0 0],[.72 0 0],p.muted,2.5);
arrow3(ax,[0 0 0],[0 .72 0],p.muted,2.5);
arrow3(ax,[0 0 0],[0 0 .72],p.muted,2.5);

R = axisRotation([.4 .7 .2],48*pi/180);
v = .42*[-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; ...
  -1 -1 1; 1 -1 1; 1 1 1; -1 1 1] * R';
f = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
patch(ax,'Vertices',v,'Faces',f,'FaceColor',p.panel,'FaceAlpha',.36, ...
  'EdgeColor',p.fg,'EdgeAlpha',.88,'LineWidth',2.5);
cols = {p.coral,p.cyan,p.gold};
for k=1:3
  d = R(:,k)'; arrow3(ax,[0 0 0],.76*d,cols{k},6);
end
scatter3(ax,0,0,0,120,p.fg,'filled');
end

function R = axisRotation(axis,angle)
axis = axis(:)/norm(axis); K = [0 -axis(3) axis(2); axis(3) 0 -axis(1); -axis(2) axis(1) 0];
R = eye(3)*cos(angle) + (1-cos(angle))*(axis*axis') + sin(angle)*K;
end

function stressTensorGlyph(ax,p)
% A Cauchy stress element exposes both tensor indices: the face normal is
% the first and the traction direction on that face is the second.
v = .52*[-1 -1 -1; 1 -1 -1; 1 1 -1; -1 1 -1; ...
  -1 -1 1; 1 -1 1; 1 1 1; -1 1 1];
f = [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8];
patch(ax,'Vertices',v,'Faces',f,'FaceColor',p.panel,'FaceAlpha',.42, ...
  'EdgeColor',p.fg,'EdgeAlpha',.88,'LineWidth',2.5);

% Opposed normal tractions on three pairs of faces.
normalColor = {p.coral,p.cyan,p.gold};
for k = 1:3
  e = zeros(1,3); e(k) = 1;
  arrow3(ax,.52*e,1.20*e,normalColor{k},5);
  arrow3(ax,-.52*e,-1.20*e,normalColor{k},5);
end

% Shear components lie in their faces and make this more than a force cube.
arrow3(ax,[.55 -.30 -.18],[.55 .34 -.18],p.blue,4);
arrow3(ax,[-.28 .55 .16],[.34 .55 .16],p.coral,4);
arrow3(ax,[-.30 -.16 .55],[.28 .30 .55],p.cyan,4);
scatter3(ax,0,0,0,75,p.fg,'filled');
end

function elasticModulusGlyph(ax,E)
% Sample MTEX's directional Young's modulus on a full sphere.  Using a
% controlled radial mesh avoids the hemisphere/camera crop of S2Fun/surf
% while retaining the actual olivine elasticity data.
[az,el] = meshgrid(linspace(0,2*pi,145),linspace(-pi/2,pi/2,91));
x = cos(el).*cos(az); y = cos(el).*sin(az); z = sin(el);
value = reshape(E.eval(vector3d(x(:),y(:),z(:))),size(x));
radius = .62 + .43*(value-min(value(:))) ./ range(value(:));
surf(ax,radius.*x,radius.*y,radius.*z,value,'EdgeColor','none', ...
  'FaceAlpha',.98);
colormap(ax,atlasMap(256));
camlight(ax,'headlight'); lighting(ax,'gouraud');
end

function outlineVolume(ax,color,width)
% Emphasize the measurement volume independently of the internal grain
% patches; relying on axes box rendering makes the back edges too faint.
xl = xlim(ax); yl = ylim(ax); zl = zlim(ax);
dx = .025*diff(xl); dy = .025*diff(yl); dz = .025*diff(zl);
xl = xl + [-dx dx]; yl = yl + [-dy dy]; zl = zl + [-dz dz];
q = [xl(1) yl(1) zl(1); xl(2) yl(1) zl(1); ...
  xl(2) yl(2) zl(1); xl(1) yl(2) zl(1); ...
  xl(1) yl(1) zl(2); xl(2) yl(1) zl(2); ...
  xl(2) yl(2) zl(2); xl(1) yl(2) zl(2)];
e = [1 2;2 3;3 4;4 1;5 6;6 7;7 8;8 5;1 5;2 6;3 7;4 8];
for k = 1:size(e,1)
  plot3(ax,q(e(k,:),1),q(e(k,:),2),q(e(k,:),3), ...
    'Color',color,'LineWidth',width);
end
axis(ax,[xl yl zl]);
end

function parentVariantGlyph(ax,p)
% Portable fallback when the sibling MTEX website checkout is unavailable.
cubeGlyph(ax,[.23 .49],.16,-10,p.fg,.85);
cubeGlyph(ax,[.69 .70],.10,18,p.cyan,.95);
cubeGlyph(ax,[.73 .49],.10,-7,p.gold,.95);
cubeGlyph(ax,[.67 .28],.10,34,p.coral,.95);
arrow2(ax,[.37 .53],[.56 .66],p.cyan,3);
arrow2(ax,[.39 .49],[.59 .49],p.gold,3);
arrow2(ax,[.37 .44],[.54 .31],p.coral,3);
end

function orientationFunctionGlyph(ax,p)
[X,Y] = meshgrid(linspace(-1,1,130));
zs = [.15 .72 1.29];
for k=1:3
  Z = exp(-((X-.33*cos(k)).^2+(Y-.35*sin(1.7*k)).^2)/.13) + ...
    .65*exp(-((X+.45).^2+(Y-.18*k+.32).^2)/.08);
  surf(ax,X,Y,zs(k)+.14*Z,Z,'EdgeColor','none','FaceAlpha',.82);
  contour3(ax,X,Y,zs(k)+.145*Z,Z,6,'LineColor',p.fg,'LineWidth',.8);
end

colormap(ax,atlasMap(256));
for k=1:4
  plot3(ax,[-1 1],[-1 -1],[(k-1)*.48 (k-1)*.48],'Color',[p.muted .16]);
end
end

function odfGlyph(ax,p,odf)
assert(isa(odf,'SO3Fun'),'Expected an MTEX orientation distribution function.');
[x,y,z] = sphere(64);
centers = [-.32 -.18 .46; .35 .24 .94; -.05 .38 1.33];
scales = [.43 .31 .23; .28 .42 .21; .24 .24 .31];
cols = {p.coral,p.cyan,p.gold};
for k=1:3
  X=centers(k,1)+scales(k,1)*x;
  Y=centers(k,2)+scales(k,2)*y;
  Z=centers(k,3)+scales(k,3)*z;
  surf(ax,X,Y,Z,z,'FaceColor',cols{k},'FaceAlpha',.46, ...
    'EdgeColor','none');
end
% Euler-space frame makes the three-dimensional domain explicit.
q = [-.82 -.72 .08; .82 -.72 .08; .82 .72 .08; -.82 .72 .08; ...
  -.82 -.72 1.55; .82 -.72 1.55; .82 .72 1.55; -.82 .72 1.55];
e = [1 2;2 3;3 4;4 1;5 6;6 7;7 8;8 5;1 5;2 6;3 7;4 8];
for j=1:size(e,1)
  plot3(ax,q(e(j,:),1),q(e(j,:),2),q(e(j,:),3),'Color',[p.muted .38], ...
    'LineWidth',1.5);
end
arrow3(ax,q(1,:),q(2,:)+[.12 0 0],p.coral,2.5);
arrow3(ax,q(1,:),q(4,:)+[0 .12 0],p.cyan,2.5);
arrow3(ax,q(1,:),q(5,:)+[0 0 .12],p.gold,2.5);
camlight(ax,'headlight'); lighting(ax,'gouraud');
end

function plotModesGlyph(ax,p)
[X,Y]=meshgrid(linspace(-1,1,48));
Z=1.25*exp(-4*((X+.34).^2+(Y-.18).^2)) + ...
  .85*exp(-6*((X-.38).^2+(Y+.28).^2));
pos = [.06 .54 .40 .40; .54 .54 .40 .40; .06 .06 .40 .40; .54 .06 .40 .40];
for k=1:4, panel(ax,pos(k,:)); end

% The same field as smooth colour, contours, samples and a surface.
xp=pos(1,1)+.04+(.32*(X+1)/2); yp=pos(1,2)+.04+(.32*(Y+1)/2);
surface(ax,xp,yp,zeros(size(Z)),Z,'FaceColor','interp','EdgeColor','none');

xp=pos(2,1)+.04+(.32*(X+1)/2); yp=pos(2,2)+.04+(.32*(Y+1)/2);
contour(ax,xp,yp,Z,6,'LineColor',p.blue,'LineWidth',1.6);

rng(7)
q = randn(72,2).*[.13 .10] + [.17 .27];
q2 = randn(42,2).*[.10 .08] + [.29 .13];
q = [q;q2];
scatter(ax,pos(3,1)+q(:,1),pos(3,2)+q(:,2),18,p.coral,'filled', ...
  'MarkerFaceAlpha',.65);

xp=pos(4,1)+.20+.12*X-.075*Y;
yp=pos(4,2)+.13+.055*X+.04*Y+.11*Z;
surface(ax,xp,yp,Z,'CData',Z,'FaceColor','interp','EdgeColor',p.fg, ...
  'EdgeAlpha',.12);
colormap(ax,atlasMap(256));
end

% -- MTEX data helpers ----------------------------------------------------
function ebsd = forsteritePatch
ebsd = mtexdata('forsterite');
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*1e3));
end

function [ebsd,grains] = forsteriteGrains
ebsd = forsteritePatch;
grains = calcGrains(ebsd('indexed'),'threshold',10*degree);
end
