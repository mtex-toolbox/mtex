%% Grain Reconstruction
% Explanation how to create grains from EBSD data.
%
%% Open in Editor
%
%% Contents
%
%%
% Reconstructing grains and grain boundaries is one of the central problems
% when analyzing EBSD data. It is instrumental for ODF estimation from EBSD
% data as well as <GrainMisorientationAnalysis.html misorientation analysis>.
%

%% Grain Reconstruction
% Let us first import some standard EBSD data with a [[matlab:edit
% mtexdata, script file]]

mtexdata aachen
plotx2east

%%
% Grain reconstruction in MTEX is done via the command
% <EBSD.calcGrains.html calcGrains>. As an optional argument the desired
% threshold angle for misorientation defining a grains boundary can be
% specified.

grains = calcGrains(ebsd,'threshold',2.5*degree)

%%
% The reconstructed grains are stored in the variable *grains* which
% describes the EBSD data by <GrainSet_index.html incidence and adjacency
% matrices>. In order to verify the result let us plot the grain boundaries
% into the spatial EBSD plot.

close all
plot(ebsd)
hold on
plotBoundary(grains)
hold off

%%
% When plotting the grains directly the associated color is defined by the
% mean orientation within each grain.

plot(grains)

%%
% The capabilities <GrainSpatialPlots.html plotting grains> are a key for
% understanding the specimen.
%
%% Computing grain properties
% There are a couple of properties that can be computed for each indiviual
% grain, e.g. perimeter, diameter, area,  grainSize (no. of measurements)
% which can be simply calculated by the commands

perimeter(grains);
diameter(grains);
area(grains);
grainSize(grains);

%%
% As an example let us explore the relation between the grain area coverage
% over the specimen. first, we sort the area of grain in ascending order

A = sort(area(grains));

%%
% then, we can plot the probability to access a random grain from the
% GrainSet which is smaller than a certain area

close all
semilogx(A,(1:numel(A))./numel(A))
set(gca,'xtick',5*10.^(-2:2)) % adjust the ticks
grid on
xlabel('area'),ylabel('cumulative percentage')

%%
% alternatively, we can plot the area fraction, i.e. the probability to
% pick spatially a grain less than a certain area.

close, semilogx(A,cumsum(A)./sum(A))
set(gca,'xtick',5*10.^(-2:2)) % adjust the ticks
grid on
xlabel('area'),ylabel('cumulative area fraction')

%% Accessing individual grains
% Individual grains can be accessed by indexing, where the index refers to
% the n-th grain.

grains(1)
close all
plot(grains([327 1065]))

%%
% Selecting a single phase works like previously done with the EBSD data.

selected_grains = grains('Fe')

%%
% Moreover, grains allow logical indexing

selected_grains = grains(grainSize(grains) > 10)

%%
% Logical indexing allows more complex queries, e.g. selecting grains with
% at least 10 measurements within one phase

selected_grains = grains(grainSize(grains) >= 10 & grains('mg'))

%%
% One can also use these selected grains for further queries.

large_grains = grains( perimeter(grains) > 150  | selected_grains )

close all
plot(large_grains)

%%
% Also, one can select grains by its spatial location

grains_by_xy = findByLocation(grains,[146  137])

close all
plot(grains_by_xy)
hold on
plot(146,137,'marker','d','markerfacecolor','r','markersize',10)

%%
% or by a specific orientation.

grains_by_orientation = findByOrientation(grains('fe'),idquaternion, 10*degree)

close all
plot(grains_by_orientation)

%% Correcting poor grains
% Sometimes measurements belonging to grains with very few measurements can
% be regarded as inaccurate. In order to detect such measuremens we have
% first to reconstruct grains from the EBSD measurements using the command
% <EBSD.calcGrains.html calcGrains>. This time, we explicitely keep the not
% indexed measurements by the flag *keepNotIndexed*

grains = calcGrains(ebsd,'angle',5*degree,'keepNotIndexed')

close all
plot(grains)

%%
% The histogram of the grainsize shows a lot of grains consisting only of
% very few measurements.

p = histc(grainSize(grains),1:5)'./numel(grains)
sum(p)

%%
% and we calculate the area fraction for small grains.

A = area(grains);
sum(A(grainSize(grains)<=5))/ sum(A)

%%
% grains with less than 5 measurements make up >80% of the constructed
% grains but cover only 13% of the specimen, i.e. there might be some
% corruption of the data present, which we are going to eliminate.
%%
% Next, let us take a closer look, how the small grains are distributed
% over the phases

p = [sum(grainSize(grains('notIndexed')) <= 5) ...
  sum(grainSize(grains('Fe')) <= 5) ...
  sum(grainSize(grains('Mg')) <= 5)]./numel(grains)

%%
% It is possible to select different grains by size and phase. E.g. not
% indexed grains with more than 20 measurments, which can be considered as
% large areas of missing data and which should not be assigned to any
% conventional grain. We further consider iron grains with less than 5
% measurments as not suitable.

large_grains = grains( ...
  (grains('notIndexed') & grainSize(grains)>=20) |...
  (grains('fe') & grainSize(grains)>=5 ) | ...
  grains('mg'))

close all
plotBoundary(large_grains)
hold on,
plot(grains(~large_grains),'facecolor','r')

%%
% Indeed, there are a lot of small not indexed grains, mostly located at
% grain boundaries. Next, we use the EBSD data of the computed grain set to
% do the reconstruction again.

grains_corrected = calcGrains(large_grains.ebsd,'keepNotIndexed','angle',5*degree)

close all
plot(grains_corrected,'property','phase')

%%
% Now, let us compare the grain size the both distribution, between the
% uncorreted and corrected GrainSet.

Auncorr = sort(area(grains));
Acorr   = sort(area(grains_corrected));

%%
% As the following plots indicate, the small grains are now assigned to
% larger grains

close all
semilogx(Auncorr,cumsum(Auncorr)/sum(Auncorr),'b')
hold on
semilogx(Acorr,cumsum(Acorr)/sum(Acorr),'r')
set(gca,'xtick',5*10.^(-2:2)) % adjust the ticks
grid on
legend('uncorrected','corrected')
xlabel('area'), ylabel('cumulative area fraction')



