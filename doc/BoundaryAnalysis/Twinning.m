
%%

mtexdata twins

ebsd = ebsd('indexed')

%%

plot(ebsd,ebsd.orientations)

%%

[grains,ebsd.grainId] = calcGrains(ebsd('indexed'))

% smooth the grain boundaries a bit
grains = smooth(grains,2)

%%

gB = grains.boundary

hold on
plot(gB,'linewidth',2)
hold off

%% compute the misorientation between two grains

mori = inv(grains(65).meanOrientation) * grains(74).meanOrientation;

%% select twinning boundaries

% define a twinning misorientation
twinMori = orientation('axis',Miller(1,-2,1,0,ebsd.CS,'uvw'),...
  'angle',86.3*degree,ebsd.CS,ebsd.CS)

% consider only Magnesium to Magnesium grain boundaries
gBMg2Mg = gB('Magnesium','Magnesium');

% restrict to twinnings with threshold 5 degree
isTwinning = angle(gBMg2Mg.misorientation,twinMori) < 5*degree;
twinBoundary = gBMg2Mg(isTwinning)

% plot the twinning boundaries
hold on
plot(twinBoundary,'linecolor','b','linewidth',2,'displayName','twin boundary')
hold off

%% merge twins along twin boundaries

[mergedGrains,parentId] = merge(grains,twinBoundary);

% plot the merged grains
plot(ebsd,ebsd.orientations)
hold on
plot(mergedGrains.boundary,'linecolor','b','linewidth',1.5,'linestyle','-',...
  'displayName','merged grains')
hold off

%% remove boundary grains

% this gives the boundary ids that are 
boundaryIds = mergedGrains.boundary.hasPhaseId(0);

% the corresponding grain ids
grainId = unique(mergedGrains.boundary(boundaryIds).grainId(:,2))

% remove those grains from the list
mergedGrains(grainId) = []

%%

plot(mergedGrains)



%% grain relationships

% each merged grain has an id, i.e.,
mergedGrains(20).id

% and each of the original grains has a property |paraentId| which
% indicates into which grain it has been merged hence, you can find the
% childs of |mergedGrains(20)| by
childs = grains(parentId == mergedGrains(20).id)

% for each of the childs you can get Euler angles
childs.meanOrientation

% and the grain size
childs.grainSize

% or
childs.area
