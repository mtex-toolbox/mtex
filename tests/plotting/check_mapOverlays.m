function check_mapOverlays
% check what is drawn ON TOP of a map - crystal shapes, spherical functions
%
% Those overlays are lifted off the map along its normal so that they do not
% z-fight with it. The normal alone does not say which way that is: it is a
% property of the DATA, while the side the viewer sits on is a property of
% the plotting convention. With the pristine default - z into the screen -
% the two point in opposite directions, so lifting along |N| buries the
% overlay behind the map, where the depth sorting hides it. The map is
% opaque, so the whole overlay simply disappears without any error.
%
% That is what happened to the hexagonal prisms in the first section of
% doc/ODFAnalysis/ODFTheory.m: they were placed 20 to 60 units behind a map
% viewed from -z. grain2d/plot had the sign correction for crystal shapes
% but not for spherical functions, EBSD/plot for neither.
%
% Checked here for both conventions, since a fix that merely flips the sign
% would move the failure to the other one rather than remove it.
%
% See also
% EBSD/plot grain2d/plot plottingConvention

oldVis = get(0,'DefaultFigureVisible');
set(0,'DefaultFigureVisible','off');
cleanUp = onCleanup(@() cleanup(oldVis)); %#ok<NASGU>

cs = crystalSymmetry('6/mmm',[3 3 5],'mineral','test');

% four blocks, so that there are a few grains to carry an overlay
n = 8;
[c,r] = meshgrid(1:n,1:n);
blockId = 1 + (r>4) + 2*(c>4);
oris = orientation.byAxisAngle(zvector,(1:4)*20*degree,cs);
rot = rotation.id(n,n);
for k = 1:4, rot(blockId==k) = oris(k); end
ebsd = EBSDsquare([],rot,2*ones(n,n),[0 1],{'notIndexed',cs},'dxy',[1 1]);

grains = calcGrains(ebsd,'threshold',5*degree);
assert(length(grains)==4,'check_mapOverlays: expected 4 grains, got %d',length(grains));

cS = crystalShape.hex(cs);
S2F = S2FunHarmonic.quadrature(@(v) 1 + v.z.^2);

% z into the screen is the pristine default and the case that used to fail,
% z out of the screen must keep working
for pC = {plottingConvention(-zvector,xvector), plottingConvention(zvector,xvector)}

  what = 'z into the screen';
  if pC{1}.outOfScreen.z > 0, what = 'z out of the screen'; end

  plottingConvention.default(pC{1});

  checkAbove(what,'EBSD + crystalShape',pC{1}, ...
    @() plot(ebsd,ebsd.orientations), @() plot(ebsd,0.3*cS));

  checkAbove(what,'grain2d + crystalShape',pC{1}, ...
    @() plot(grains,grains.meanOrientation), @() plot(grains,cS));

  checkAbove(what,'grain2d + S2Fun',pC{1}, ...
    @() plot(grains,grains.meanOrientation), @() plot(grains,S2F));

end

close all
disp('check_mapOverlays: passed');

end

% =========================================================================
function checkAbove(what,who,pC,plotMap,plotOverlay)
% the overlay has to end up on the viewer's side of the map

close all
plotMap();
before = findall(gca);

hold on
plotOverlay();
hold off

ax = gca;
added = setdiff(findall(ax),before);

z = [];
for h = reshape(added,1,[])
  if isprop(h,'ZData') && ~isempty(h.ZData), z = [z; h.ZData(:)]; end %#ok<AGROW>
  if isprop(h,'Vertices') && ~isempty(h.Vertices) && size(h.Vertices,2) > 2
    z = [z; h.Vertices(:,3)]; %#ok<AGROW>
  end
end
z = z(~isnan(z));

assert(~isempty(z), ...
  'check_mapOverlays: %s, %s drew nothing with a z coordinate',what,who);

% the map sits at z = 0, so the overlay has to be on the side the camera is
side = dot(vector3d(0,0,mean(z)),pC.outOfScreen);

assert(side > 0, ...
  ['check_mapOverlays: %s, %s is drawn %.3g behind the map - it has to be ' ...
  'lifted towards the viewer, not along the map normal'],what,who,-side);

% and the camera has to agree with the convention we just tested against
camSide = sign(ax.CameraPosition(3) - ax.CameraTarget(3));
assert(camSide == sign(pC.outOfScreen.z), ...
  'check_mapOverlays: %s, the camera sits on the wrong side of the map',what);

end

% =========================================================================
function cleanup(oldVis)
close all
set(0,'DefaultFigureVisible',oldVis);
end
