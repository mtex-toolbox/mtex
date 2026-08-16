%% Grain Reconstruction
%
%%
% By grain reconstruction we mean the subdivision of the specimen, or more
% precisely the measured surface of the specimen, into regions of similar
% orientation which we then call grains. Note that there is no canonical
% definition of what is a grain. The default grain reconstruction method in
% MTEX is based on the definition of high angle grain boundaries which are
% assumed at the perpendicular bisector between neighboring measurements
% whenever their misorientation angle exceeds a certain threshold.
% According to this point of view grains are regions surrounded by grain
% boundaries.
%
% In order to illustrate the grain reconstruction process we consider the
% following sample data set

% import the data
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% make a phase plot
plot(ebsd,'micronbar','off')

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
% The extent to which unindexed pixels are assigned is controlled by the
% parameter |'alpha'|. Roughly speaking this parameter is the radius, in
% pixels, of the smallest unindexed region that will not be entirely
% assigned to surrounding grains. The default of this value is
% |alpha = 3.1|.
%
% The second parameter |'angle'| involved in grain reconstruction is the
% threshold misorientation angle indicating a grain boundary. By default,
% this value is set to |angle = 10*degree|.
%
% Finally, the option |'minPixel'| controls the minimum size of a
% reconstructed grain. Grains with less pixels are considered as not
% indexed.
%
% All grain reconstruction methods in MTEX are accessible via the command 
% <EBSD.calcGrains.html |calcGrains|> which takes as input an EBSD data set
% and returns a list of grain.

[grains, ebsd] = calcGrains(ebsd,'alpha',2.1,'angle',10*degree,'minPixel',5);
grains

%%
% The reconstructed grains are stored in the variable |grains|. To
% visualize the grains we can plot its boundaries by the command
% <grainBoundary.plot.html |plot|>.

% start override mode
hold on

% plot the boundary of all grains
plot(grains.boundary,'linewidth',1.5,'micronbar','off')

% stop override mode
hold off

%% Grain Boundary Smoothing 
% 
% Due to the gridded nature of the EBSD measurement the reconstructed grain
% boundaries often suffer from the staircase effect. This can be reduced by
% smoothing the grain boundaries using the command <grain2d.smoothBoundary.html
% |smooth|>

grains = smoothBoundary(grains,5);

% display the result
plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%% Adapting the Alpha Parameter
% Increasing the parameter |'alpha'| larger not indexed regions are
% associated to grains.

% reload the data
mtexdata forsterite silent
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

[grains, ebsd] = calcGrains(ebsd,'alpha',6,'angle',10*degree,'minPixel',3);
grains = smoothBoundary(grains,3);

% plot the boundary of all grains
plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% On the other setting |alpha = 0| the grains consists exactly of the
% measurement pixels

% reload the data
mtexdata forsterite silent
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

[grains, ebsd] = calcGrains(ebsd,'alpha',0,'angle',10*degree);

% plot the boundary of all grains
plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%% Grain Reconstruction in heavily deformed microstructures
%
% Everything above rests on one assumption: that a misorientation between
% two neighboring pixels means the same thing everywhere on the map, so that
% a single threshold angle can separate "inside a grain" from "across a
% grain boundary". In a heavily deformed material that assumption fails from
% both sides at once. Inside a grain the lattice is bent, so neighboring
% pixels differ by an amount that has nothing to do with a boundary and
% which accumulates to tens of degrees across the grain. Between two grains,
% on the other hand, the misorientation may be well below any threshold one
% could still call high angle.
%
% As an example we consider an austenitic steel deformed in situ. It was
% indexed by spherical pattern matching rather than by the Hough transform,
% which leaves an orientation noise of about 0.1 degree - an order of
% magnitude below a typical Hough indexed map - so the substructure the
% deformation produced is actually resolved.

mtexdata EMSphinx

% the deformed austenite
ebsd = ebsd('Iron fcc');

plot(ebsd,ebsd.orientations)

%%
% The color gradients within the elongated grains are the bent lattice. We
% zoom into a smaller region to see what a threshold makes of it.

region = [40 30 80 60];
ebsd = ebsd(inpolygon(ebsd,region));

plot(ebsd,ebsd.orientations)

%%
% At the usual 10 degree the reconstruction returns the grains, but every
% boundary below the threshold is missed - and there are many, since
% deformation creates them.

grains = smoothBoundary(calcGrains(ebsd,'angle',10*degree,'minPixel',10),5);

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Lowering the threshold does not recover them. Well before it reaches the
% angles those boundaries actually have, it starts cutting the bent lattice
% inside the grains, and the boundaries it draws there are contour lines of
% a smooth orientation field rather than anything physical.

grains = smoothBoundary(calcGrains(ebsd,'angle',0.5*degree,'minPixel',10),5);

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%% Fast multiscale clustering
%
% The way out is to stop asking about pixel pairs in isolation. Fast
% multiscale clustering, <gbcFMC.gbcFMC.html |gbcFMC|>, builds a hierarchy
% of ever coarser aggregates of pixels and compares the misorientation
% between two aggregates against *their own internal orientation spread*
% instead of against a fixed angle. A 1 degree step between two uniform
% aggregates is then a boundary, while the same step inside a strongly bent
% grain is not, and the algorithm has no threshold angle at all.
%
% It is selected by the option |'fmc'|, whose value |cmaha| controls how
% sharply a surprising misorientation suppresses the coupling between two
% aggregates - larger values separate more strictly and return more grains.

grains = calcGrains(ebsd,'fmc',0.5,'minPixel',10);
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Note that the low angle boundaries missed at 10 degree are found, without
% any of the spurious ones a 0.5 degree threshold produced.
%
% Raising |cmaha| resolves the substructure within those grains - the
% dislocation cells that carry the deformation.

grains = calcGrains(ebsd,'fmc',1.5,'minPixel',10);
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Finally the same reconstruction on the full map. Unlike the threshold
% based criteria, FMC clusters the entire map at once rather than pixel pair
% by pixel pair, which is why this takes a few seconds. Adding the flag
% |'verbose'| reports how far the hierarchy coarsened and at which of its
% scales the grains were eventually read off.

mtexdata EMSphinx silent
ebsd = ebsd('Iron fcc');

grains = calcGrains(ebsd,'fmc',1.5,'minPixel',10)
grains = smoothBoundary(grains,5);

plot(ebsd,ebsd.orientations)
hold on
plot(grains.boundary)
hold off

%% More ways to reconstruct grains
%
% The threshold angle and fast multiscale clustering are two of several
% criteria by which |calcGrains| may separate neighbouring pixels, and all
% of them are interchangeable objects. How to choose between them, how to
% segment by a property other than the orientation, and how to write a
% criterion of your own is the subject of
% <GrainReconstructionAdvanced.html Advanced Grain Reconstruction>. A
% second way of turning a criterion into grains, by clustering the map
% instead of taking connected components, is described in
% <GrainReconstructionMCL.html Markovian Clustering>.

 







