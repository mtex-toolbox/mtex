%% Grain Reconstruction
% Explanation how to create grains from EBSD data.
%
%% Open in Editor
%
%% Contents
%
%%
% This section discusses the different grain reconstruction methods
% implement in MTEX. 
%

%% Grain Reconstruction
% Let us first import some [[matlab:edit mtexdata, example EBSD
% data]] and reduce it to a subregion of interest.

plotx2east
mtexdata forsterite

ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

plot(ebsd)


%%
% We see that there are a lot of not indexed locations. For grain
% reconstruction we have to two different choices how to deal with these
% unindexed regions:
%
% # assign them to the surrounding grains
% # leaf the unindexed
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

grains = calcGrains(ebsd)

%%
% The reconstructed grains are stored in the variable *grains*.
% To visualize the grains we can plot its boundaries by the command
% <Grain2d.plotBoundary.html plotBoundary>.

% start overide mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5)

% mark two grains by location
plot(grains(12000,4000).boundary,'linecolor','r','linewidth',2)
plot(grains(11300,6100).boundary,'linecolor','r','linewidth',2)

% stop overide mode
hold off

%%
% We observe, especially in the marked grains, how MTEX fills notindexed
% regions and connects otherwise seperate measurements to grains.

%%
% In order to supress this filling the option *keepNotIndexed* can be used.

grains = calcGrains(ebsd,'keepNotIndexed')


% plot the ebsd data
plot(ebsd)

% start overide mode
hold on

% plot grain boundaries
plot(grains.boundary)

% mark two grains by location
plot(grains(12000,4000).boundary,'linecolor','r','linewidth',2)
plot(grains(11300,6100).boundary,'linecolor','r','linewidth',2)


% stop overide mode
hold off

%% 
% Note how the one marked grain has been seperated into two grains and the
% other marked grain has been seperated into many very small grains.

%% Grain reconstrion by the multiscale clustering method
%
% When analyzing grains with gradual and subtle boundaries the threshold
% based method may not lead to the desired result.
%
% Let us consider the following example

mtexdata single

plot(ebsd)

%%
% We obeserve that the are no rapid changes in orientation which would
% allow for applying the threshold based algorithm. Setting the threshold
% angle to a very small value would include many irrelevant or false regions.

grains_high = calcGrains(ebsd,'angle',1*degree);
grains_low  = calcGrains(ebsd,'angle',0.5*degree);

figure('position',[100 100 800 350])
plot(grains_high.boundary)
figure('position',[500 100 800 350])
plot(grains_low.boundary)

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

%%
% We observe how this method nicely splits the measurements into clusters
% of similar orientation

plot(ebsd)

% start overide mode
hold on
plot(grains_FMC.boundary,'linewidth',1.5)

% stop overide mode
hold off

%% Correcting poor grains
% Sometimes measurements belonging to grains with very few measurements can
% be regarded as inaccurate. This time, we explicitely keep the not
% indexed measurements by the flag |keepNotIndexed|

mtexdata forsterite

[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'keepNotIndexed')

close all
plot(grains)

%%
% The number of measurements per grain can be accessed by the command
% <GrainSet.grainSize.html GrainSize>. Let us determine the number of
% grains with less then 10 measurements

nnz(grains.grainSize < 5)

% or the percentage of those grains relative to the total number of grains
100 * nnz(grains.grainSize < 10) / length(grains)

%%
% We see that almost 92 percent of all grains consist of less then ten
% measurement points. Next, we compute the percentage of small grains for
% the individuell phases

p = 100*[nnz(grains('notIndexed').grainSize < 10); ...
  nnz(grains('forsterite').grainSize < 10); ...
  nnz(grains('enstatite').grainSize < 10); ...
  nnz(grains('diopside').grainSize < 10)]./length(grains)

%%
% We see that almost all small grains are acually not indexed. In order to
% allow filling in those holes we remove these small not indexed grains
% completely from the data set

condition = grains.grainSize >=10 | grains.phase > 0;

grains(condition)

%%
% If we now perform grain reconstruction a second time these small holes
% will be assigned to the neighbouring grains

grains = calcGrains(ebsd(grains(condition)),'keepNotIndexed')

plot(grains)

%%
% We see that all small unindexed regions has been filled. Another way for
% correcting EBSD data is to filter them accoring to quality measures like
% MAD or band contrast. Lets plot the band contrast of our measurements

plot(ebsd,ebsd.bc)

colorbar

%%
% We see that there is a rectangular region in top left corner which low
% band contrast. In order to filter out all measurements with low band
% contrast we can do

condition = ebsd.bc > 80;

plot(ebsd(condition))

%%
% Although this filtering has cleared out large regions. The grain
% reconstruction algorithm works still well.

grains = calcGrains(ebsd(condition))

plot(grains)
