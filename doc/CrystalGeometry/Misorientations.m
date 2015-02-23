%% Misorientations
% Explains how to define crystal orientations, how to switch between
% different convention and how to compute crystallographic equivalent
% orientations.
%
%% Open in Editor
%
%% Contents
%
%% Misorientations between grains
% Let us import some EBSD data set, compute grains and plot the colorized
% according to their meanorientation and lets highlight grain 70 and grain
% 80

mtexdata twins
grains = calcGrains(ebsd('indexed'))
CS = grains.CS; % extract crystal symmetry

plot(grains,grains.meanOrientation)
hold on
plot(grains([70,80]).boundary,'edgecolor','w','linewidth',2)

%%
% The misorientation between those two grains can be computed from the
% meanorientations of the grains. Remember that an orientation always maps
% crystal coordinates into specimen coordinates. Hence, the product of an
% inverse orientation with another orientation transfers crystal
% coordinates from one crystal reference frame into crystal coordinates
% with respect to another crystal reference frame.

mori = inv(grains(70).meanOrientation) * grains(80).meanOrientation

%% 
% In the present case the misorientation describes the coordinate transform
% from the reference frame of grain 80 into the reference frame of crystal
% 70. Take as an expample the plane {11-20} with respect to the grain 80.
% Then the plane in grain 70 which aligned parallel to this plane can be
% computed by

round(mori * Miller(1,1,-2,0,CS))


%%
% Conversely, the inverse of mori is the coordinate transform from crystal
% 70 to grain 80.

round(inv(mori) * Miller(2,-1,-1,0,CS))


%% Coinsident lattice planes
% The coincidence between major lattice planes may suggest that the
% misorientation is a twinning misorientation. Lets analyse whether there
% are some more alignments between major lattice planes.

m = Miller({1,0,-1,0},{1,1,-2,0},{1,0,-1,1},{1,1,-2,1},{1,1,-2,2},{0,0,0,1},CS);

close all
% cycle through all major lattice planes
for im = 1:length(m)
  
  % plot the lattice planes of grains 80 with respect to the 
  % reference frame of grain 70
  plot(mori * symmetrise(m(im)),'symmetrised','MarkerSize',10,...
    'DisplayName',char(m(im)),'fundamentalRegion','figSize','normal')
  hold all
end
hold off
annotate(m,'labeled')

% show legend
legend({},'location','NorthWest','FontSize',13);

%%
% we observe an almost perfect math between the {11-20} lattice planes
% and the {10-11} lattice planes
% and good coincidences for the lattice plane {10-10} to {0001} and
% {11-22}; and for the lattice plane {10-10} to {11-22}. Lets compute the
% angles explicitly

angle(mori * Miller(1,1,-2,0,CS),Miller(1,1,-2,0,CS)) / degree
angle(mori * Miller(-1,0,1,1,CS),Miller(1,0,-1,1,CS)) / degree
angle(mori * Miller(0,0,0,1,CS) ,Miller(1,0,-1,0,CS)) / degree
angle(mori * Miller(1,1,-2,2,CS),Miller(1,0,-1,0,CS)) / degree
angle(mori * Miller(1,0,-1,0,CS),Miller(1,1,-2,2,CS)) / degree

%% Twinning misorientations
% Lets define a misorientation that makes a perfect fit between the {11-20}
% lattice planes and between the {10-11} lattice planes

mori = orientation('map',Miller(1,1,-2,0,CS),Miller(2,-1,-1,0,CS),...
  Miller(-1,0,1,1,CS),Miller(1,0,-1,1,CS))

% the rotational axis
round(mori.axis)

% the rotational angle
mori.angle / degree

%%
% Lets plot the same figure as before with the exact twinning
% misorientation.

for im = 1:length(m)
  plot(mori * symmetrise(m(im)),'symmetrised','MarkerSize',10,...
    'DisplayName',char(m(im)),'fundamentalRegion')
  hold all
end
hold off
annotate(m,'labeled')

% show legend
legend({},'location','NorthWest','FontSize',13);


%% Highlight twinning boundaries
% It turns out that in the previous EBSD map many grain boudaries have a
% misorientation close to the twinning misorientation we just defined. Lets
% higlight such twinning boundaries

% consider only Magnesium to Magnesium grain boundaries
gB = grains.boundary('Mag','Mag');
% check for small deviation from the twinning misorientation
isTwinning = angle(gB.misorientation,mori) < 5*degree;

% plot the grains and highlight the twinning boundaries
plot(grains,grains.meanOrientation)
hold on
plot(gB(isTwinning),'edgecolor','w','linewidth',2)
hold off

%% Phase transitions
% Misorientations may not only be defined between crystal frames of the
% same phase. Lets consider the phases Magnetite and Hematite.

CS_Mag = loadCIF('Magnetite')
CS_Hem = loadCIF('Hematite')

%%
% The phase transition from Magnetite to Hematite is described in
% literature by {111}_m parallel {0001}_h and {-101}_m parallel {10-10}_h
% The corresponding misorientation is defined in MTEX by

Mag2Hem = orientation('map',...
  Miller(1,1,1,CS_Mag),Miller(0,0,0,1,CS_Hem),...
  Miller(-1,0,1,CS_Mag),Miller(1,0,-1,0,CS_Hem))

%%
% Assume a Magnetite grain with orientation

ori_Mag = orientation('Euler',0,0,0,CS_Mag)

%%
% Then we can compute all variants of the phase transition by

symmetrise(ori_Mag) * inv(Mag2Hem)

%%
% and the corresponding pole figures by

plotPDF(symmetrise(ori_Mag) * inv(Mag2Hem),...
  Miller({1,0,-1,0},{1,1,-2,0},{0,0,0,1},CS_Hem))

