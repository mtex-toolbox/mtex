%% Fundamental Regions 
% 
%
%% Open in Editor
%
%% Contents
%

%% The complete, symmetry free, orientation space
%
% The space orientations can be imagined as a three dimensional ball with
% radius 180 degree. The distance of some point in the ball to the origin
% represent the rotational angle and the vector represents the rotational
% axis. In MTEX this can be represented as follows

% triclic crystal symmetry
cs = crystalSymmetry('triclinic')

% the corresponding orientation space
oR_all = fundamentalRegion(cs);

% lets plot the ball of all orientations
plot(oR_all)

%%
% Next we plot some orientations into this space

% rotation about the z-axis about 180 degree
rotZ = orientation('axis',zvector,'angle',180*degree,cs); 

hold on
plot(rotZ,'MarkerColor','b','MarkerSize',10)
hold off

% rotations about the x- and y-axis about 30,60,90 ... degree
rotX = orientation('axis',xvector,'angle',(-180:30:180)*degree,cs); 
rotY = orientation('axis',yvector,'angle',(-180:30:180)*degree,cs); 

hold on
plot(rotX,'MarkerColor','r','MarkerSize',10)
plot(rotY,'MarkerColor','g','MarkerSize',10)
hold off

%% 
% An alternative view on the orientation space is by sections, e.g. 
% sections along the Euler angles or along the rotational angle. The latter
% one should be demonstrated next:

plotODF(rotZ,'MarkerColor','b','axisAngle',(30:30:180)*degree)
hold on
plotODF(rotX,'MarkerColor','g')
hold on
plotODF(rotY,'MarkerColor','r')
hold off

%% Crystal Symmetries
% In case of crystal symmetries the orientation space can divded into as
% many equivalent segments as the symmetry group has elements. E.g. in the
% case of orthorombic symmetry the orientation space is subdived into four
% equal parts, the central one looking like

cs = crystalSymmetry('222')
oR = fundamentalRegion(cs);

close all
plot(oR_all)
hold on
plot(oR,'color','r')
hold off

%%
% As an example consider the following EBSD data set

mtexdata forsterite

%%
% we can visualize the Forsterite orientations by

hold on
plot(ebsd('Fo').orientations)
hold off

%%
% We see that not all orientations are inside the fundamental region.
% However, as there is for each orientation exactly one represent inside
% the fundamental region we can project the orientations inside this
% region. This is done by

ori =  ebsd('Fo').orientations.project2FundamentalRegion

hold on
plot(ori,'MarkerColor','g')
hold off

%% Change the center of the fundamental region
% There is no necessity that the fundamental region has to be centered in
% the origin - it can be centered at any orientation, e.g. at the mean
% orientation of a grain.

% segment data into grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'));

% take the orientaions of the largest on
[~,id] = max(grains.area);
largeGrain = grains(id)
ori = ebsd(largeGrain).orientations

% recenter the fundamental zone to the mean orientation 
plot(rotate(oR,largeGrain.meanOrientation))

% project the orientations into the fundamental region around the mean
% orientation
ori = ori.project2FundamentalRegion(largeGrain.meanOrientation)

hold on
plot(ori)
hold off


%% Fundamental regions of misorientations
%
% Misorientations are characterised by two crystal symmetries. A
% corresponding fundamental region is defined by

oR = fundamentalRegion(ebsd('Fo').CS,ebsd('En').CS);

plot(oR)

% Let plot grain boundary misorientations within this fundamental region
hold on
plot(grains.boundary('fo','En').misorientation.project2FundamentalRegion)
hold off

%% Fundamental regions of misorientations with antipodal symmetry
%
% Note that for boundary misorientations between the same phase we can
% *not* distinguish between a misorintation and its inverse. This is not
% the case for misorientations between different phases or the
% misorientation between the mean orientation of a grain and all other
% orientations. The inverse of a misorientation is axis - angle
% representation is simply the one with the same angle but antipodal axis.
% Accordingly this additional symmetry is handled in MTEX by the keyword
% *antipodal*. 

oR = fundamentalRegion(ebsd('Fo').CS,ebsd('Fo').CS,'antipodal');

plot(oR)

%%
% We see that the fundamental region with antipodal symmetry has only half
% the size as without. In order to project into this fundamental region use

hold on
mori = grains.boundary('Fo','Fo').misorientation
plot(mori.project2FundamentalRegion('antipodal'))
hold off

%% Axis angle sections
%
% Again we can plot constant angle sections through the fundamental
% region. This is done by

plotODF(mori,'axisAngle')

%%
% Note that in the previous plot we distinguish between |mori| and
% |inv(mori)|. Adding antipodal symmetry those are considered as equivalent

plotODF(mori,'axisAngle','antipodal')

