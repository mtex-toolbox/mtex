%% Fill Missing Data in Orientation Maps
%
% Orientation maps determined by EBSD or any other technique are, as all
% experimental data, effected by measurement errors. Those measurement
% errors can be divided into systematic errors and random errors.
% Systematic errors mostly occur due to a bad calibration of the EBSD
% system and require additional knowledge to be corrected. Deviations from
% the true orientation due to noisy Kikuchi pattern or tolerances of the
% indecing algorithm can be modeled as random errors. In this section we
% demonstrate how random errors can be significantly reduced using
% denoising techniques.

%%
% We shall demonstrate the denoising capabilities of MTEX at the hand of an
% orientation map of deformed Magnesium 

% import the data
mtexdata twin

% consider only indexed data
ebsd = ebsd('indexed');

% reconstruct the grain structure
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',10*degree);

% remove some very small grains
ebsd(grains(grains.grainSize<5)) = [];

% redo grain segementation
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',10*degree);

% smooth grain boundaries
grains = smooth(grains,5);

% plot the orientation map
plot(ebsd,ebsd.orientations)

% and on top the grain boundaries
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% In order to visualize orientation gradients within the grains we next
% colorize the orientations according to their misorientation axis and
% angle with respect to the grain mean orientation.

% define the color key
colorKey = axisAngleColorKey;

% we need to set the reference orientations are the mean orientation of each grain
colorKey.oriRef = grains(ebsd.grainId).meanOrientation;

% lets plot the result
plot(ebsd,colorKey.orientation2color(ebsd.orientations))
hold on
plot(grains.boundary,'linewidth',2)
hold off

%% A Very Sparse Measured Data Set
%
% In order to demonstrate the fill capabilities of the MTEX algorithms we
% randomly throw away 75 percent of all data.

ebsdSub = ebsd(discretesample(length(ebsd),round(length(ebsd)*25/100)));

% plot the reduced data
plot(ebsdSub,ebsdSub.orientations)

%%
% In a first step we reconstruct the grain structure from these 25 percent
% pixels.

% reconstruct the grain structure
[grainsSub,ebsdSub.grainId] = calcGrains(ebsdSub,'angle',10*degree);

grainsSub = smooth(grainsSub,5)

hold on
plot(grainsSub.boundary,'linewidth',2)
hold off

%%
% In order to fill the 75 percent missing orientations we use the option
% |fill| when denoising the data.

F = splineFilter;

% interpolate the missing data 
ebsdSub_filled = smooth(ebsdSub,F,'fill',grainsSub);
ebsdSub_filled = ebsdSub_filled('indexed');

% plot the result
colorKey.oriRef = grainsSub(ebsdSub_filled.grainId).meanOrientation;
plot(ebsdSub_filled,colorKey.orientation2color(ebsdSub_filled.orientations))

hold on
plot(grainsSub.boundary,'linewidth',2)
hold off


%%

F = halfQuadraticFilter; 

% interpolate the missing data 
ebsdSub_filled = smooth(ebsdSub,F,'fill',grainsSub);
ebsdSub_filled = ebsdSub_filled('indexed');

% plot the result
colorKey.oriRef = grainsSub(ebsdSub_filled.grainId).meanOrientation;
plot(ebsdSub_filled,colorKey.orientation2color(ebsdSub_filled.orientations))

hold on
plot(grainsSub.boundary,'linewidth',2)
hold off


%% A real world example
% Let's consider a subset of the 

close all; plotx2east
mtexdata forsterite
ebsd = ebsd(inpolygon(ebsd,[10 4 5 3]*10^3));
plot(ebsd('Fo'),ebsd('Fo').orientations)
hold on
plot(ebsd('En'),ebsd('En').orientations)
plot(ebsd('Di'),ebsd('Di').orientations)

% compute grains
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',10*degree);


% remove small grains
ebsd(grains(grains.grainSize < 3)) = [];

% and repeat the grain computation
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',10*degree);

%
grains = smooth(grains,5);

% plot the boundary of all grains
plot(grains.boundary,'linewidth',2)
hold off

%%
% Using the option |fill| the command |smooth| fills the holes inside the
% grains. Note that the nonindexed pixels at the grain boundaries kept
% untouched. In order to allow MTEX to decide whether a pixel is inside a
% grain or not, the |grain| variable has to be passed as an additional
% argument.

F = halfQuadraticFilter;
F.alpha = 10;

ebsdS = smooth(ebsd('indexed'),F,'fill',grains);

plot(ebsdS('Fo'),ebsdS('Fo').orientations)
hold on
plot(ebsdS('En'),ebsdS('En').orientations)
plot(ebsdS('Di'),ebsdS('Di').orientations)

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% stop overide mode
hold off

%%
% In order to visualize the orientation gradient within the grains, we plot
% the misorientation to the meanorientation. We observe that the mis2mean
% varies smoothly also within the regions of not indexed orientations.

% plot mis2mean for all phases
ipfKey = axisAngleColorKey(ebsdS('Fo'));
ipfKey.oriRef = grains(ebsdS('fo').grainId).meanOrientation;
ipfKey.maxAngle = 2.5*degree;

color = ipfKey.orientation2color(ebsdS('Fo').orientations);
plot(ebsdS('Fo'),color,'micronbar','off')

hold on
ipfKey.oriRef = grains(ebsdS('En').grainId).meanOrientation;

plot(ebsdS('En'),ipfKey.orientation2color(ebsdS('En').orientations))


% plot boundary
plot(grains.boundary,'linewidth',4)
plot(grains('En').boundary,'lineWidth',4,'lineColor','r')
hold off

%%
% For comparison

ipfKey.oriRef = grains(ebsd('fo').grainId).meanOrientation;
ipfKey.maxAngle = 2.5*degree;

color = ipfKey.orientation2color(ebsd('Fo').orientations);
plot(ebsd('Fo'),color,'micronbar','off')

hold on
ipfKey.oriRef = grains(ebsd('En').grainId).meanOrientation;

plot(ebsd('En'),ipfKey.orientation2color(ebsd('En').orientations))


% plot boundary
plot(grains.boundary,'linewidth',4)
plot(grains('En').boundary,'lineWidth',4,'lineColor','r')
hold off


