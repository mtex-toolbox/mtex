function makeChapterThumbnails(varargin)
% render one thumbnail per documentation chapter for the overview page
%
% Syntax
%   makeChapterThumbnails
%   makeChapterThumbnails('only',{'CrystalGeometry','Plotting'})
%   makeChapterThumbnails('outDir',pathToSomewhereElse)
%
% Options
%  only   - render just these chapters, everything else is left alone
%  outDir - where to write, default doc/makeDoc/general
%
% Description
% A tile has one job: to be recognised at 150 pixels. It is chosen for that
% and is deliberately *not* tied to the chapter's opening figure, which is
% chosen to teach. Two tiles must never share a silhouette - the first
% version of this set had three chapters rendering as dots on a circle and
% two rendering as the same pole figure.
%
% Rendering the whole set costs minutes, so iterate with 'only'.

outDir = get_option(varargin,'outDir',fullfile(mtex_path,'doc','makeDoc','general'));

old = plottingConvention.default;
plottingConvention.default('y↑→x');
cleanup = onCleanup(@() plottingConvention.default(old));

names = {'Tutorials','GeneralConcepts','Vectors','Rotations','CrystalGeometry',...
  'CrystalOrientations','Misorientations','ODFAnalysis','PoleFigureAnalysis',...
  'EBSDAnalysis','Grains','GrainBoundaries','EBSD3Analysis','Tensors',...
  'Elasticity','Plasticity','PhaseTransitions','SphericalFunctions',...
  'SO3Functions','Plotting'};

only = get_option(varargin,'only',{});
if ~isempty(only)
  if ~iscell(only), only = {only}; end
  names = names(ismember(names,only));
  missing = setdiff(only,names);
  if ~isempty(missing)
    error('MTEX:thumbnails','no such chapter: %s',strjoin(missing,', '));
  end
end

for k = 1:numel(names)
  close all
  f = fullfile(outDir,['chapter_' names{k} '.png']);
  try
    switch names{k}

      case 'GeneralConcepts'  % no MATLAB figure - the chapter is about code
        codeTile(f)

      case 'Plotting'         % a grid of renderings of one data set
        plottingTile(f)

      case 'Rotations'        % one crystal at successive rotations
        rotationTile(f)

      otherwise
        figure('Position',[100 100 400 400],'Color','w')
        drawOne(names{k});

        % a legend or colorbar says nothing at thumbnail size
        delete(findobj(gcf,'Type','Legend'))
        delete(findobj(gcf,'Type','ColorBar'))

        exportgraphics(gcf,f,'Resolution',96)
        squareOff(f)
    end
    fprintf('THUMB %s\n',names{k});
  catch e
    fprintf('THUMBFAIL %s :: %s\n',names{k},e.message);
  end
end
close all

end

% -------------------------------------------------------------------------
function squareOff(f)
% crop the tile to a filled square, the way the site's other thumbnails look
%
% Trim the white MATLAB leaves around a figure, then scale so the *short*
% side reaches the target and cut the overhang off the long side. Padding to
% square instead would leave white margins and shrink the picture, which
% reads as an empty tile at this size.
%
% Needs ImageMagick. Without it the raw figure is kept, which still works -
% the tiles are simply of differing shapes.

persistent haveMagick
if isempty(haveMagick), haveMagick = ~system('magick -version > /dev/null 2>&1'); end

if ~haveMagick
  warning('MTEX:thumbnails','ImageMagick not found, thumbnails left uncropped');
  return
end

system(sprintf(['magick "%s" -fuzz 2%% -trim +repage ' ...
  '-resize 300x300^ -gravity center -extent 300x300 "%s"'],f,f));

end

% -------------------------------------------------------------------------
function codeTile(f)
% General Concepts is about scripting habits and has no picture of its own,
% so the tile is the thing itself: a few lines of MTEX, with the line that
% carries the chapter's point picked out.

lines = {'ebsd = EBSD.load(fname)','','grains = calcGrains(ebsd,...)','', ...
  'big = grains(grains.area > 50)'};
hot = 5;

cmd = sprintf(['magick -size 300x300 xc:''#1f2430'' ' ...
  '-font DejaVu-Sans-Mono -pointsize 14 ']);
y = 62;
for k = 1:numel(lines)
  if isempty(lines{k}), y = y + 22; continue; end
  if k == hot, col = '#7fd6a0'; else, col = '#9aa7bd'; end
  cmd = [cmd sprintf('-fill ''%s'' -annotate +18+%d ''%s'' ',col,y,lines{k})]; %#ok<AGROW>
  y = y + 46;
end
system([cmd '"' f '"']);

end

% -------------------------------------------------------------------------
function rotationTile(f)
% the same crystal at three successive rotations, so the tile implies motion
%
% Composed rather than drawn in one axes: translating a crystalShape leaves
% the axes fitted to the last one, and a single wide row would lose its outer
% cubes to the square crop.

col = [0.85 0.33 0.25; 0.35 0.62 0.85; 0.45 0.75 0.45];
cS = crystalShape.cube(crystalSymmetry('m-3m'));
tmp = cell(1,3);

for j = 1:3
  close all
  figure('Position',[100 100 300 300],'Color','w')
  rot = rotation.byAxisAngle(vector3d.Z,(j-1)*40*degree) * ...
        rotation.byAxisAngle(vector3d.X,25*degree);
  plot(rot*cS,'faceColor',col(j,:))
  axis off
  tmp{j} = [tempname '.png'];
  exportgraphics(gcf,tmp{j},'Resolution',96)
  system(sprintf('magick "%s" -fuzz 2%%%% -trim +repage -resize 96x96 -background white -gravity center -extent 100x100 "%s"',tmp{j},tmp{j}));
end
close all

system(sprintf(['magick montage %s %s %s -tile 3x1 -geometry +0+0 -background white "%s"'],...
  tmp{1},tmp{2},tmp{3},f));
system(sprintf('magick "%s" -background white -gravity center -extent 300x300 "%s"',f,f));
cellfun(@delete,tmp);

end

% -------------------------------------------------------------------------
function plottingTile(f)
% the Plotting chapter is about the choice of rendering, so the tile shows
% one data set drawn four ways rather than one more pole figure

cs = crystalSymmetry('432');
odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs),'halfwidth',15*degree);
h = Miller(1,0,0,cs);

styles = {{'contourf'},{'contour','linewidth',2},{'smooth'},{'points','MarkerSize',4}};
tmp = cell(1,numel(styles));

for k = 1:numel(styles)
  close all
  figure('Position',[100 100 400 400],'Color','w')
  if strcmp(styles{k}{1},'points')
    plotPDF(discreteSample(odf,400),h,'MarkerSize',4)
  else
    plotPDF(odf,h,styles{k}{:})
  end
  delete(findobj(gcf,'Type','ColorBar'))
  tmp{k} = [tempname '.png'];
  exportgraphics(gcf,tmp{k},'Resolution',96)
  system(sprintf('magick "%s" -fuzz 2%%%% -trim +repage -resize 150x150^ -gravity center -extent 150x150 "%s"',tmp{k},tmp{k}));
end
close all

system(sprintf('magick montage %s %s %s %s -tile 2x2 -geometry +0+0 -background white "%s"',...
  tmp{1},tmp{2},tmp{3},tmp{4},f));
cellfun(@delete,tmp);

end

% -------------------------------------------------------------------------
function drawOne(name)

switch name

  case 'Tutorials'
    % a phase map: flat colour blocks, so it cannot be mistaken for an ipf map
    mtexdata forsterite silent
    ebsd = evalin('base','ebsd');
    plot(ebsd(inpolygon(ebsd,[5 2 10 5]*10^3)),'micronbar','off')

  case 'GeneralConcepts'
    v = vector3d.rand(500);
    steep = angle(v,vector3d.Z) < 30*degree;
    plot(v(~steep),'upper','MarkerSize',7,'MarkerFaceColor',[.55 .55 .55],'MarkerEdgeColor','none')
    hold on
    plot(v(steep),'upper','MarkerSize',9,'MarkerFaceColor','r','MarkerEdgeColor','k')
    hold off

  case 'Vectors'
    % on a 3d ball rather than a flat disc, so it reads differently from
    % every pole figure in the set
    plot(vector3d.rand(400),'3d','MarkerSize',6,'MarkerFaceColor',[.85 .2 .2])

  case 'Rotations'
    % handled as a composite, see rotationTile

  case 'CrystalGeometry'
    % a Kikuchi pattern says planes and directions at once: the centre line
    % of a band is where a lattice plane meets the screen, and bands cross
    % at zone axes
    data = load([mtexDataPath filesep 'quartzPattern.mat']);
    pattern = data.pattern;
    cs = pattern.CS;

    [~,ax] = plot(pattern,'resolution',0.25*degree,'complete','upper','noLabel');
    mtexColorMap black2white

    m = Miller(-1,0,1,0,cs,'hkil');   % hexagonal prism
    r = Miller(0,-1,1,1,cs,'hkil');   % positive rhomboedron
    z = Miller(0,1,-1,1,cs,'hkil');   % negative rhomboedron

    hold on
    circle(m.symmetrise,'parent',ax,'color','deepSkyBlue','linewidth',2)
    circle(r.symmetrise,'parent',ax,'color','red','linewidth',2)
    circle(z.symmetrise,'parent',ax,'color','yellow','linewidth',2)
    hold off

  case 'CrystalOrientations'
    cs = crystalSymmetry('m-3m');
    ori = orientation.byEuler(30*degree,50*degree,10*degree,cs);
    plot(ori * crystalShape.cube(cs),'faceColor',[0.3 0.6 0.85])
    hold on
    arrow3d(1.1*[vector3d.X,vector3d.Y,vector3d.Z])
    hold off

  case 'Misorientations'
    mtexdata twins silent
    ebsd = evalin('base','ebsd');
    grains = calcGrains(ebsd('indexed'),'threshold',5*degree);
    grains = smoothBoundary(grains,5);
    plot(grains,grains.meanOrientation,'micronbar','off','faceAlpha',0.45)
    hold on
    plot(grains.boundary,grains.boundary.misorientation.angle./degree,'linewidth',6)
    hold off

  case 'ODFAnalysis'
    % inverse pole figures: triangular sectors, not the round discs the pole
    % figure chapter uses
    cs = crystalSymmetry('432');
    odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs),'halfwidth',15*degree);
    plotIPDF(odf,[vector3d.X,vector3d.Z],'contourf','figSize','small')

  case 'PoleFigureAnalysis'
    mtexdata dubna silent
    pf = evalin('base','pf');
    % braces select a pole figure, round brackets select measurement points
    plot(pf,'contourf','figSize','small')

  case 'EBSDAnalysis'
    mtexdata forsterite silent
    ebsd = evalin('base','ebsd');
    ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
    plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')

  case 'Grains'
    mtexdata forsterite silent
    ebsd = evalin('base','ebsd');
    ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
    grains = calcGrains(ebsd('indexed'),'threshold',10*degree);
    plot(ebsd('Forsterite'),ebsd('Forsterite').orientations,'micronbar','off')
    hold on
    plot(grains.boundary,'lineWidth',1.5)
    hold off

  case 'GrainBoundaries'
    % the network on its own: a line drawing, with no filled map underneath
    mtexdata forsterite silent
    ebsd = evalin('base','ebsd');
    ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
    grains = calcGrains(ebsd('indexed'),'threshold',10*degree);
    grains = smoothBoundary(grains,5);
    plot(grains.boundary,'lineWidth',4,'lineColor',[0.1 0.1 0.1])
    hold on
    plot(grains.triplePoints,'color','r','MarkerSize',9)
    hold off

  case 'EBSD3Analysis'
    grains = grain3d.load(fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d'));
    plot(grains,grains.meanOrientation,'LineStyle','none','micronbar','off')
    % seen from straight above a volume looks like a map, which defeats the point
    view(135,25); axis vis3d

  case 'Tensors'
    % as a 3d surface, so it is not another coloured disc like Elasticity
    cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivine');
    C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'),cs);
    plot(C.YoungsModulus,'3d')
    view(115,20); camlight('headlight'); axis off

  case 'Elasticity'
    cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivine');
    C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'),cs);
    C = addOption(C,'density',3.355);
    plot(velocity(C),'complete','upper')

  case 'Plasticity'
    cs = crystalSymmetry('m-3m','mineral','Aluminium');
    cS = crystalShape.cube(cs);
    plot(cS,'faceAlpha',0.2)
    hold on
    plot(cS,slipSystem.fcc(cs),'faceColor','red')
    hold off

  case 'PhaseTransitions'
    % one colour per variant, so the tile shows that one parent gives many
    % children rather than showing an anonymous scatter
    csP = crystalSymmetry('m-3m',[3.65 3.65 3.65],'mineral','Austenite');
    csC = crystalSymmetry('m-3m',[2.87 2.87 2.87],'mineral','Ferrite');
    p2c = orientation.KurdjumovSachs(csP,csC);
    oriChild = variants(p2c,orientation.byEuler(0,0,0,csP));
    plotPDF(oriChild,Miller(0,0,1,csC),'property',1:length(oriChild),...
      'MarkerSize',11,'figSize','small')
    mtexColorMap hsv

  case 'SphericalFunctions'
    plot(S2Fun.smiley,'upper')

  case 'SO3Functions'
    cs = crystalSymmetry('432');
    odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs),'halfwidth',15*degree);
    plot(odf,'sigma','sections',3,'figSize','small')

  case 'Plotting'
    cs = crystalSymmetry('432');
    odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs),'halfwidth',15*degree);
    h = [Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(1,1,1,cs)];
    plotPDF(odf,h,'contourf','figSize','small')

end

end
