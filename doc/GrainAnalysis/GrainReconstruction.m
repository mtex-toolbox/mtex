%% Grain Reconstruction
% Grain Reconstruction from EBSD data.
%
%% Open in Editor
%
%% Contents

%% 
% Let us first import some example EBSD data and restrict it to a subregion
% of interest.

close all; plotx2east
mtexdata forsterite
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
plot(ebsd)

%% Basic grain reconstruction
% We see that there are a lot of not indexed measurements. For grain
% reconstruction we have to three different choices how to deal with these
% unindexed regions:
%
% # leaf them unindexed
% # assign them to the surrounding grains
% # a mixture of both, e.g., assign small notindexed regions to the
% surrounding grains but keep large notindexed regions
%
% By default MTEX uses the first method. 
%
% The second parameter that is involved in grain reconstruction is the
% threshold misorientation angle indicating a grain boundary. By default
% this value is set to 10 degree. 
%
% All grain reconstruction methods in MTEX are accessable via the command 
% <EBSD.calcGrains.html calcGrains> which takes as input an EBSD data set
% and returns a list of grain.

grains = calcGrains(ebsd,'angle',10*degree)

%%
% The reconstructed grains are stored in the variable *grains*.
% Note that also the notIndexed measurements are grouped into grains. This
% allows later to analyse the shape of these unindexed regions.
%
% To visualize the grains we can plot its boundaries by the command
% <Grain2d.plotBoundary.html plotBoundary>.

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% stop overide mode
hold off

%% The grainId and how to select EBSD inside specific grains
% Beside the list of grains the command <EBSD.calcGrains.html calcGrains>
% returns also two other output arguments. 

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',7.5*degree);
grains
ebsd

%%
% The second output argument grainId is a list with the same size as the
% EBSD measurements that stores for each mesurement the corresponding
% grainId. The above syntax stores this list directly inside the ebsd
% variable. This enables MTEX to select EBSD data by grains. The following
% command returns all the EBSD data that belong to grain number 33.

ebsd(grains(33))

%%
% and is equivalent to the command

ebsd(ebsd.grainId == 33) 


%% Misorientation to mean orientation
%
% The third output argument is again a list of the same size as the ebsd
% measurements. The entries are the misorientation to the mean orientation
% of the corresponding grain.

plot(ebsd,ebsd.mis2mean.angle ./ degree)

hold on
plot(grains.boundary)
hold off

mtexColorbar

%%
% We can examine the misorientation to mean for one specific grain as
% follows

% select a grain by coordinates
myGrain = grains(9075,3275)
plot(myGrain.boundary,'linewidth',2)

% plot mis2mean angle for this specific grain
hold on
plot(ebsd(myGrain),ebsd(myGrain).mis2mean.angle ./ degree)
hold off
mtexColorbar


%% Filling not indexed holes
%
% It is important to understand that MTEX distinguishes the following two
% situations
%
% # a location is marked as not indexed
% # a location does not occur in the data set
%
% A location marked as *not indexed* is interpreted by MTEX as: at this
% position there is *no crystal*, whereas for a location that does not
% occur in the data set is interpreted by MTEX as: it is not known whether
% there is a crystal or not. Just to remind you, the later assumption is
% nothing special as it applies at all locations but the measurement
% points.
%
% A location that does not occur in the data is assigned in MTEX to the
% same grain and phase as the closest measurement point - this may also be
% a not indexed point. Hence, filling holes in MTEX means to erasing them
% from the list of measurements, i.e., instead of telling MTEX there is no
% no crystal we are telling MTEX: we do not know what there is.

%%
% The exremal case is to say whenever there is a not indexed measurement we
% actually do not know anything and allow MTEX to freely guess what happens
% there. This is realized by removing all not indexed measurements or,
% equivalently, computing the grains only from the indexed measurements

% compute the grains from the indexed measurements only
grains = calcGrains(ebsd('indexed'))

plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% mark two grains by location
plot(grains(11300,6100).boundary,'linecolor','m','linewidth',2,...
  'DisplayName','grain A')
plot(grains(12000,4000).boundary,'linecolor','r','linewidth',2,...
  'DisplayName','grain B')

% stop overide mode
hold off

%%
% We observe, especially in the marked grains, how MTEX fills notindexed
% regions and connects otherwise seperate measurements to grains. As all
% information about not indexed regions were removed the reconstructed
% grains fill the map completely

plot(grains,'linewidth',2)


%%
% Inside of grain B there is a large not indexed region and we might argue
% that is not very meaningfull to assign such a large region to some grain
% but should have kept it not indexed. In order to decide which not indexed
% region is large enaugh to be kept not indexed and which not indexed
% regions can be filled it is helpfull to know that the command calcGrains
% also seperates the not indexed regions into "grains" and we can standard
% grain functions like area or perimeter to analyze these regions.

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
notIndexed = grains('notIndexed')

%%
% We see that we have 1139 not indexed regions. A good measure for compact
% regions vs. cluttered regions is the quotient between the area and the
% boundary length.

% plot the not indexed regions colorcoded according the the quotient between
% number of measurements and number of boundary segments
plot(notIndexed,log(notIndexed.grainSize ./ notIndexed.boundarySize))
mtexColorbar

%%
% Regions with a high quotient are blocks which can be hardly correctly
% assigned to a grain. Hence, we should keep these regions as not indexed
% and only remove the not indexed information from locations with a low
% quotient.

% the "not indexed grains" we want to remove
toRemove = notIndexed(notIndexed.grainSize ./ notIndexed.boundarySize<0.8)

% now we remove the corresponding EBSD measurements
ebsd(toRemove) = []

% and perform grain reconstruction with the reduces EBSD data set
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);

plot(grains)

%%
% We see that there are some not indexed regions are left blank. Finally,
% the image with the raw EBSD data and on top the grain boundaries.


% plot the raw data
plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% mark two grains by location
plot(grains(11300,6100).boundary,'linecolor','m','linewidth',2,...
  'DisplayName','grain A')
plot(grains(12000,4000).boundary,'linecolor','r','linewidth',2,...
  'DisplayName','grain B')

% stop overide mode
hold off

%% Grain smoothing
% The reconstructed grains show the typicaly staircase effect. This effect
% can be reduced by smoothing the grains. This is particulary important
% when working with the direction of the boundary segments

% plot the raw data
plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,angle(grains.boundary.direction,xvector)./degree,'linewidth',3.5)
mtexColorbar

% stop overide mode
hold off

%%
% We see that the angle between the grain bounday direction and the x-axis
% takes only values 0, 45 and 90 degree. After applying smoothing we obtain
% a much better result

% smooth the grain boundaries
grains = smooth(grains)

% plot the raw data
plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,angle(grains.boundary.direction,xvector)./degree,'linewidth',3.5)
mtexColorbar

% stop overide mode
hold off


%% Grain reconstruction by the multiscale clustering method
%
% When analyzing grains with gradual and subtle boundaries the threshold
% based method may not lead to the desired result.
%
% Let us consider the following example

mtexdata single

oM = ipdfHSVOrientationMapping(ebsd);
oM.inversePoleFigureDirection = mean(ebsd.orientations) * oM.whiteCenter;
oM.colorStretching = 5;

plot(ebsd,oM.orientation2color(ebsd.orientations))

%%
% We obeserve that the are no rapid changes in orientation which would
% allow for applying the threshold based algorithm. Setting the threshold
% angle to a very small value would include many irrelevant or false regions.

grains_high = calcGrains(ebsd,'angle',1*degree);
grains_low  = calcGrains(ebsd,'angle',0.5*degree);

figure
plot(ebsd,oM.orientation2color(ebsd.orientations))
hold on
plot(grains_high.boundary)
hold off

figure
plot(ebsd,oM.orientation2color(ebsd.orientations))
hold on
plot(grains_low.boundary)
hold off
%%
% As an alternative MTEX includes the fast multiscale clustering method
% (FMC method) which  constructs clusters in a hierarchical manner from
% single pixels using fuzzy logic to account for local, as well as global
% information.
%
% Analogous with the threshold angle, a  single parameter, C_Maha controls
% the sensitivity of the segmentation. A C_Maha value of 3.5 properly 
% identifies the  subgrain features. A C_Maha value of 3 captures more
% general features, while a value of 4 identifies finer features but is
% slightly oversegmented.
%

grains_FMC = calcGrains(ebsd,'FMC',3.5)

% smooth grains to remove staircase effect
grains_FMC = smooth(grains_FMC);

%%
% We observe how this method nicely splits the measurements into clusters
% of similar orientation

plot(ebsd,oM.orientation2color(ebsd.orientations))

% start overide mode
hold on
plot(grains_FMC.boundary,'linewidth',1.5)

% stop overide mode
hold off

