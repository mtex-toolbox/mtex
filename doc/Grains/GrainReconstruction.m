%% Grain Reconstruction
%
%%
% Grain reconstruction turns a map of individual measurements into a list of
% regions. Two neighbouring measurements belong to the same region as long
% as they are of the same phase and their orientations agree to within a
% threshold; where they do not, a boundary is drawn between them. The
% command that does this is <EBSD.calcGrains.html |calcGrains|>.
%
% Three settings decide what comes out: the misorientation angle at which a
% boundary is drawn, what happens to measurements that could not be indexed,
% and how few pixels a region may consist of and still be called a grain.
% This page takes them one at a time, on a map that exercises all three.

% import the data
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% restrict it to a subregion of interest
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3))

% make a phase plot
plot(ebsd,'micronbar','off')

%%
% The colours are the phases - forsterite, enstatite and diopside - and the
% white speckle between them is the fourth phase in the list, the
% measurements whose diffraction pattern could not be indexed. There are
% many of them: one measurement in five on this map is notIndexed, and most
% of them sit exactly where the grain boundaries will end up.

%% A first reconstruction
%
% |calcGrains| takes the map and returns the grains, with all three settings
% left at their defaults.

grains = calcGrains(ebsd,'angle',10*degree)

%%
% Each grain is one entry of this list, with its own phase, mean
% orientation, size and shape. The boundaries between them are a separate
% object, |grains.boundary|, which we plot on top of the map.

plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Two things are worth noticing. The boundaries are drawn between
% measurement points and never through them, so they follow the measurement
% grid in steps. And although a fifth of the map is notIndexed, only one
% grain is - the long white bar right of centre. The unindexed pixels
% everywhere else have been handed to the grains beside them. That is the
% default behaviour, and the section on |'alpha'| below is where it is
% decided.

%% The threshold angle
%
% The option |'angle'| sets the misorientation angle above which two
% neighbouring measurements are separated by a boundary. Its default is 10
% degrees, and values between 10 and 15 degrees are long habit rather than a
% measurement - see the discussion in <Grains.html the chapter opener>.
%
% On a recrystallised map like this one the exact value hardly matters.

for threshold = [2 5 10 15]*degree
  g = calcGrains(ebsd,'angle',threshold);
  fprintf('%2d degree threshold: %3d indexed grains\n',...
    round(threshold./degree),length(g('indexed')));
end

%%
% Between 5 and 15 degrees the number of grains moves by less than a tenth,
% and only at 2 degrees does it start to climb. The reason is that the
% misorientations between neighbouring measurements here are either small,
% well below any of these thresholds, or large enough to exceed all of them;
% there is little in between for the threshold to decide about. That is a
% property of the material rather than of the algorithm, and it stops being
% true as soon as the material is deformed - which is what the second half
% of this page is about.

%% Measurements that were not indexed
%
% A notIndexed measurement is not a hole in the map. It is a measurement
% like any other whose phase happens to be notIndexed, so a connected patch
% of them forms a grain, and that grain has a boundary with everything
% around it.
%
% Whether this is what you want depends on the patch. A wide unindexed
% region is genuinely a part of the specimen you know nothing about and
% should stay a region of its own. A one pixel wide seam along a grain
% boundary is not - it is the indexing failing where two lattices overlap in
% the diffraction pattern, and leaving it in place puts a spurious grain
% between every pair of neighbours.
%
% The option |'alpha'| draws the line between the two. Unindexed regions
% narrower than about |2*alpha| pixels are absorbed by the surrounding
% grains, wider ones survive. The default is |alpha = 3.1|.

for alpha = [0 1 3.1 6]
  g = calcGrains(ebsd,'angle',10*degree,'alpha',alpha);
  fprintf('alpha = %3.1f: %4d grains, %4d of them notIndexed\n',...
    alpha,length(g),length(g('notIndexed')));
end

%%
% With |alpha = 0| nothing is absorbed. The unindexed pixels then contribute
% a thousand grains of their own, five times the number of real grains the
% default finds, and because their seams also cut through regions that
% should be single grains the indexed count rises from 210 to 525. One pixel
% of closing already removes almost all of them, the default keeps only the
% one wide unindexed region, and |alpha = 6| absorbs that one too.
%
% The effect is easiest to see when the two extremes are drawn on the same
% part of the map.

region = [5 2 2 1.5]*10^3;
ebsdSub = ebsd(inpolygon(ebsd,region));

grainsSharp = calcGrains(ebsd,'angle',10*degree,'alpha',0);

newMtexFigure('layout',[1,2])

plot(ebsdSub,'micronbar','off')
hold on
plot(grainsSharp.boundary,'linewidth',1.5)
hold off
xlim(region(1)+[0 region(3)]), ylim(region(2)+[0 region(4)])

nextAxis
plot(ebsdSub,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off
xlim(region(1)+[0 region(3)]), ylim(region(2)+[0 region(4)])

%%
% On the left, at |alpha = 0|, every white pixel is fenced off on its own and
% the seams running through the blue forsterite cut it into pieces. On the
% right, at the default, the white pixels are still there and still not
% indexed, but they no longer separate anything: what is left are the
% boundaries between the phases and between the grains. The isolated orange
% pixels keep their boundary on both sides, because they were indexed - they
% are diopside, and |'minPixel'| below is what deals with them.

%% Grains that are too small to mean anything
%
% Even with the unindexed seams absorbed, a threshold criterion produces
% grains of one, two or three pixels wherever a few measurements are
% mis-indexed. They are noise, they are numerous, and because most grain
% statistics are counts they distort every one of them. The option
% |'minPixel'| removes them: an indexed grain with fewer pixels than this is
% not returned, and its measurements are marked notIndexed instead.

for minPixel = [1 5 10]
  g = calcGrains(ebsd,'angle',10*degree,'minPixel',minPixel);
  fprintf('minPixel = %2d: %3d indexed grains, holding %4.1f%% of the indexed pixels\n',...
    minPixel,length(g('indexed')),100*sum(g('indexed').numPixel)/nnz(ebsd.isIndexed));
end

%%
% More than half of the grains on this map consist of fewer than five
% pixels, and together they hold one measurement in a hundred. Removing them
% changes the grain statistics a great deal and the microstructure not at
% all.

%% Smoothing the boundaries
%
% Because the boundaries run between measurement points, they follow the
% measurement grid in steps - the staircase effect. This is a property of
% the reconstruction, not of the material, and it is worth removing before
% anything is measured on the boundary itself, such as its length or its
% direction. The command is <grain2d.smoothBoundary.html |smoothBoundary|>,
% and its argument is the number of smoothing iterations.

grains = calcGrains(ebsd,'angle',10*degree,'minPixel',5);
grains = smoothBoundary(grains,5);

plot(ebsd,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% The steps are gone and the boundaries have kept their course. How far this
% may be pushed before the shape itself starts to change, and which of the
% available smoothing methods to use, is the subject of
% <GrainSmoothing.html Grain Boundary Smoothing>.

%% Keeping map and grains together
%
% |calcGrains| returns a second output: the map again, with one property
% added, |grainId|, telling for every measurement which grain it went into.
% Almost everything in this chapter that relates the two descriptions of the
% specimen needs it, so it is worth asking for from the start.

[grains, ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);

% the measurements inside the largest grain
[~,id] = max(grains.numPixel);
ebsd(grains(id))

%%
% Two remarks on this second output. The measurements it holds are the same
% measurements, but a pixel that was absorbed by |'alpha'|, or dropped by
% |'minPixel'|, has had its phase rewritten, so it is not the map you
% imported and reconstructing from it a second time is not meaningful. And
% |grainId| is what <SelectingGrains.html Selecting Grains> uses throughout:
% |ebsd(grains(id))| above is nothing but a lookup on it.

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
