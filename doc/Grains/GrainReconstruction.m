%% Grain Reconstruction
%
%%
% By grain reconstruction we mean the subdivision of the specimen, or more
% precisely the measured surface of the specimen, into regions of similar
% orientation which we then call grains. Note that there is no canonical
% definition of what is a grain. The grain reconstruction method that is
% default in MTEX is based on the definition of high angle grain boundaries
% which are assumed at the Mittelsenkrechten between neighbouring
% measurements whenever their misorientation angle exceeds a certain
% threshold. According to this point of view grains are regions surrounded
% by grain boundaries. 
%
% In order to illustrate the grain reconstruction process we consider the
% following sample data set

close all; plotx2east

% import the data
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% make a phase plot
plot(ebsd)

%% Basic grain reconstruction
%
% We see that there are a lot of not indexed measurements. For grain
% reconstruction, we have  three different choices how to deal with these
% unindexed regions:
%
% # leave them unindexed
% # assign them to the surrounding grains
% # a mixture of both, e.g., assign small notindexed regions to the
% surrounding grains but keep large notindexed regions
%
% By default, MTEX uses the first method. 
%
% The second parameter that is involved in grain reconstruction is the
% threshold misorientation angle indicating a grain boundary. By default,
% this value is set to 10 degrees. 
%
% All grain reconstruction methods in MTEX are accessible via the command 
% <EBSD.calcGrains.html calcGrains> which takes as input an EBSD data set
% and returns a list of grain.

grains = calcGrains(ebsd,'angle',10*degree)

%%
% The reconstructed grains are stored in the variable *grains*.
% Note that also the notIndexed measurements are grouped into grains. This
% allows later to analyze the shape of these unindexed regions.
%
% To visualize the grains we can plot its boundaries by the command
% <grainBoundary.plot.html plot>.

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% stop overide mode
hold off

%% Filling notindexed holes
%
% It is important to understand that MTEX distinguishes the following two
% situations
%
% # a location is marked as notindexed
% # a location does not occur in the data set
%
% A location marked as *notindexed* is interpreted by MTEX as at this
% position, there is *no crystal*, whereas for a location that does not
% occur in the data set is interpreted by MTEX as: it is not known whether
% there is a crystal or not. Just to remind you, the later assumption is
% nothing special as it applies at all locations but the measurement
% points.
%
% A location that does not occur in the data is assigned in MTEX to the
% same grain and phase as the closest measurement point - this may also be
% a notindexed point. Hence, filling holes in MTEX means to erase them
% from the list of measurements, i.e., instead of telling MTEX there is
% no crystal we are telling MTEX: we do not know what there is.

%%
% The extremal case is to say whenever there is a not indexed measurement we
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
plot(grains(11300,6100).boundary,'linecolor','DarkGreen','linewidth',5,...
  'DisplayName','grain A')
plot(grains(12000,4000).boundary,'linecolor','DarkBlue','linewidth',5,...
  'DisplayName','grain B')

% stop overide mode
hold off

%%
% We observe, especially in the marked grains, how MTEX fills notindexed
% regions and connects otherwise separate measurements to grains. As all
% information about not indexed regions were removed the reconstructed
% grains fill the map completely

plot(grains,'linewidth',2)


%%
% Inside of grain B, there is a large not indexed region and we might argue
% that is not very meaningful to assign such a large region to some grain
% but should have kept it not indexed. In order to decide which not indexed
% region is large enough to be kept not indexed and which not indexed
% regions can be filled it is helpful to know that the command calcGrains
% also separates the not indexed regions into "grains" and we can standard
% grain functions like area or perimeter to analyze these regions.

[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);
notIndexed = grains('notIndexed')

%%
% We see that we have 1139 not indexed regions. A good measure for compact
% regions vs. cluttered regions is the quotient between the area and the
% boundary length. Lets, therefore, plot the "not indexed grains" colorized
% by this quotient

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
toRemove = notIndexed(notIndexed.grainSize ./ notIndexed.boundarySize<0.8);

% now we remove the corresponding EBSD measurements
ebsd(toRemove) = [];

% and perform grain reconstruction with the reduces EBSD data set
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd);

plot(grains,'lineWidth',2)

%%
% We see that that all the narrow not indexed regions have been assigned to
% the surounding grains while the large regions have been left unindexed.
% Finally, the image with the raw EBSD data and on top the grain
% boundaries.

% plot the raw data
plot(ebsd)

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% mark two grains by location
plot(grains(11300,6100).boundary,'linecolor','DarkGreen','linewidth',4,...
  'DisplayName','grain A')
plot(grains(12000,4000).boundary,'linecolor','DarkBlue','linewidth',4,...
  'DisplayName','grain B')

% stop overide mode
hold off

%% Non convex data sets
% 
% By default MTEX uses the convex hull when computing the outer boundary
% for an EBSD data set. This leads to poor results in the case of non
% convex EBSD data sets.

% cut of a non convex region from our previous data set
poly = 1.0e+04 *[...
  0.6853    0.2848
  0.7102    0.6245
  0.8847    0.3908
  1.1963    0.6650
  1.1371    0.2880
  0.6853    0.2833
  0.6853    0.2848];

ebsdP = ebsd(ebsd.inpolygon(poly));
  
plot(ebsdP,'micronBar','off')
legend off

% compute the grains
grains = calcGrains(ebsdP('indexed'));

% plot the grain boundary
hold on
plot(grains.boundary,'linewidth',1.5)
hold off  

%%
% We see that the grains badly fill up the entire convex hull of the data
% points. This can be avoided by specifying the option |tight| for the
% determination of the outer boundary.

plot(ebsdP,'micronBar','off')
legend off

% compute the grains
grains = calcGrains(ebsdP('indexed'),'boundary','tight');

% plot the grain boundary
hold on
plot(grains.boundary,'linewidth',1.5)
hold off  

