%% Advanced Grain Reconstruction
%
%%
% <GrainReconstruction.html Grain reconstruction> introduced the parameters
% of <EBSD.calcGrains.html |calcGrains|> - the threshold angle, |'alpha'|
% and |'minPixel'|. This page is about replacing its parts rather than
% tuning them. It helps to know that |calcGrains| does three things:
%
% # it partitions the measured surface into cells, one per measurement
% # it decides, for every pair of neighbouring cells, whether a grain
% boundary separates them
% # it collects the cells that are not separated into grains
%
% The following sections deal with the second step, then with the first.
% Two things that are often done *before* a reconstruction have pages of
% their own: <EBSDDenoising.html denoising> the orientation data and
% <EBSDFilling.html filling> missing pixels.
%
% Throughout this page we use the same subregion of the forsterite data set
% as the basic page.

mtexdata forsterite silent
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

%% The grain boundary criterion
%
% Whether a boundary runs between two neighbouring pixels is decided by an
% object of type <grainBoundaryCriterion.html |grainBoundaryCriterion|>. It
% is asked for pairs of pixel indices at once and answers with one number
% per pair:
%
% * |1| - no boundary, the two pixels belong to the same grain
% * |0.5| - a low angle boundary, i.e. a boundary inside a grain
% * |0| - a grain boundary
%
% Normally |calcGrains| builds the criterion from its own options, but it
% also accepts one directly. The following two calls are the same
% reconstruction

grains = calcGrains(ebsd,'angle',10*degree,'minPixel',5)

grains = calcGrains(ebsd,gbcAngle(10*degree),'minPixel',5)

%%
% MTEX ships the criteria <gbcAngle.html |gbcAngle|> (the default),
% <gbcSoft.html |gbcSoft|>, <gbcCustom.html |gbcCustom|>,
% <gbcVariants.html |gbcVariants|> and <gbcFMC.gbcFMC.html |gbcFMC|>. The
% last of these is what deformed microstructures need and is covered on the
% <GrainReconstruction.html basic page>; |gbcVariants| separates pixels by
% their variant id and belongs to
% <MaParentGrainReconstruction.html parent grain reconstruction>. The three
% remaining ones are the subject of this section.

%% Phase dependent thresholds
%
% What counts as a grain boundary need not be the same angle in every
% phase. Passing a cell array of thresholds instead of a single one gives
% each phase its own. The entries follow the order of |ebsd.CSList|

ebsd.CSList

%%
% so the first entry belongs to the not indexed pixels - it is never used,
% but it has to be there - and the remaining four to the four minerals.
% Here we ask for the forsterite, the phase that carries the deformation in
% this specimen, to be separated already at 5 degrees, while the other
% phases keep the usual 10.

threshold = {10*degree, ...  % notIndexed, never used
  5*degree, ...              % Forsterite
  10*degree, ...             % Enstatite
  10*degree, ...             % Diopside
  10*degree};                % Silicon

grains = calcGrains(ebsd,'angle',threshold,'minPixel',5)

%%
% This splits the forsterite into 65 grains instead of the 57 a uniform 10
% degrees gives, and leaves the other phases as they were.
%
% Each entry may itself be a pair |[highAngle lowAngle]|, which is how
% <SubGrainBoundaries.html subgrain boundaries> are reconstructed.

%% Soft thresholds
%
% A threshold makes the reconstruction discontinuous in the data: two
% neighbouring pixels 9.9 degrees apart end up in the same grain, two
% pixels 10.1 degrees apart in different ones, although nothing
% distinguishes the two situations physically.
% <gbcSoft.html |gbcSoft|> replaces the step by an error function of a
% given width, so that the connectivity between two pixels falls off
% gradually around the threshold

grains = calcGrains(ebsd,gbcSoft([10*degree 2*degree]),'minPixel',5)

%%
% Be aware of what this does and what it does not do. Grains are the
% connected components of the pixel pairs with a nonzero connectivity, and a
% pair only reaches zero once the error function has saturated. So on its
% own a soft threshold merely moves the effective threshold up - this
% reconstruction returns phase for phase the same grain counts as a hard
% threshold of 14 degrees. What it does record is the transition band: a
% pair past the centre of the threshold but not yet past its saturation
% gets a boundary drawn, inside the grain it did not manage to split

length(grains.innerBoundary)

%%
% The fractional connectivities become useful once the grains are not read
% off as connected components anymore, which is what
% <GrainReconstructionMCL.html Markovian clustering> does.

%% Segmenting by any property
%
% <gbcCustom.html |gbcCustom|> separates two pixels whenever a property you
% supply differs by more than a threshold. The property is one value per
% pixel and may be a number, a <vector3d.vector3d.html |vector3d|> or a
% <quaternion.quaternion.html |quaternion|> - the latter two are compared
% by the angle between them.
%
% As an example we define grains by their c-axis alone, i.e. we consider
% two forsterite pixels to belong to the same grain whenever their c-axes
% point in the same direction, no matter how the lattice is rotated about
% it.

fo = ebsd('Forsterite');
cAxis = fo.orientations .* Miller(0,0,1,fo.CS);

grainsC = calcGrains(fo,gbcCustom(cAxis,10*degree,'antipodal'),'minPixel',5)

%%
% The flag |'antipodal'| is passed on to
% <vector3d.angle.html |angle|> and is what makes the c-axis an axis rather
% than a direction - without it two pixels whose c-axes are the same axis
% but point in opposite senses would count as a boundary.
%
% Plotting the ordinary reconstruction in black underneath and this one in
% red on top shows what the criterion is blind to: the segments left black
% are boundaries across which the c-axes agree and only the rotation about
% them differs.

grainsA = calcGrains(fo,'angle',10*degree,'minPixel',5)

plot(fo,fo.orientations,'micronbar','off')
hold on
plot(grainsA.boundary,'linewidth',3,'lineColor','black')
plot(grainsC.boundary,'linewidth',1,'lineColor','red')
hold off

%%
% On this sample there are only a few of them - 57 forsterite grains become
% 55 - since grains that share a c-axis but not the rest of the lattice are
% rare here. In a material with a strong fibre texture there would be many
% more.

%% Writing your own criterion
%
% A criterion of your own is a subclass of
% <grainBoundaryCriterion.html |grainBoundaryCriterion|> with a single
% method |doEvaluate(obj,ebsd,i,j)|, where |i| and |j| are equally sized
% lists of neighbouring pixel indices and the output has the same size.
%
% The following criterion asks for two things at once: that the
% misorientation stays below a threshold, *and* that the band contrast does
% not collapse - which keeps grains from leaking through a chain of poorly
% indexed pixels.
%
%   classdef gbcAngleAndBC < grainBoundaryCriterion
%
%   properties
%     threshold = 10*degree
%     minBC = 50
%   end
%
%   methods (Access = protected)
%
%     function out = doEvaluate(obj,ebsd,i,j)
%
%       % delegate the misorientation part
%       out = eval(gbcAngle(obj.threshold),ebsd,i,j);
%
%       % and veto across badly indexed pixels
%       bad = ebsd.bc(i) < obj.minBC | ebsd.bc(j) < obj.minBC;
%       out(bad) = 0;
%
%     end
%   end
%   end
%
% Save this as |gbcAngleAndBC.m| anywhere on the search path and use it as
% any other criterion
%
%   grains = calcGrains(ebsd,gbcAngleAndBC,'minPixel',5)
%
% A criterion that needs to precompute something from the whole map may
% overload the method |prepare(obj,ebsd)|, which is called once before the
% pixel pairs are evaluated.

%% The spatial decomposition
%
% The first of the three steps, partitioning the surface into cells, is
% where the parameter |'alpha'| acts. It is the radius, measured in pixels,
% of the disk by which the measured region is closed: a not indexed region
% narrower than |2*alpha| pixels is closed over and disappears, a wider one
% survives and becomes a not indexed grain. The default is |alpha = 3.1|.
%
% The cost of the closing grows with the area of that disk. The flag
% |'delaunay'| computes the partition from the Delaunay triangulation of
% the indexed pixels instead - a triangle is filled when its circumradius
% is at most |alpha| pixels. This is the exact alpha complex rather than a
% raster approximation of it, and its cost hardly grows with |'alpha'| at
% all. At the default |'alpha'| the closing is the faster of the two; the
% flag is for maps with gaps wide enough to need a large one

tic; grains = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alpha',60); toc

tic; grains = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alpha',60,'delaunay'); toc

%%
% Note that the two do not have to agree pixel for pixel at the same
% |'alpha'| - a closing radius and a circumradius are different quantities.

%% Not indexed regions are grains
%
% |'alpha'| is a single number for the whole map, and picking it blindly is
% guesswork. It need not be, because |calcGrains| turns the not indexed
% regions into grains as well - so all of
% <ShapeParameters.html grain shape analysis> applies to them and one can
% simply look at what is there before deciding. Reconstructing with
% |alpha = 0| keeps every single not indexed pixel

[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'alpha',0);
notIndexed = grains('notIndexed')

%%
% Their sizes tell us what |'alpha'| has to deal with. A region of |n|
% pixels has a radius of about |sqrt(n/pi)| pixels, and |'alpha'| closes
% everything narrower than |2*alpha|

numPixel = notIndexed.numPixel;

[median(numPixel), quantile(numPixel,0.99), max(numPixel)]

%%
% The overwhelming majority are single misindexed pixels, and only a
% handful are regions in their own right. It is those few that decide
% |'alpha'|: the largest has a radius of about |sqrt(355/pi) = 10| pixels,
% so any |'alpha'| below that keeps it.
%
% Their shape is just as informative. The ratio between the number of
% pixels of a region and the number of its boundary segments measures how
% compact it is - high for a blob that is really a hole in the specimen,
% low for a ragged scatter of bad indexing.

plot(notIndexed,log(notIndexed.numPixel ./ notIndexed.boundarySize))
mtexColorbar

%%
% Note that MTEX makes no distinction between a pixel that the indexing
% marked as not indexed and a grid position that does not occur in the data
% set at all - both are simply positions without a measurement, and
% |'alpha'| decides for both alike. Deleting the measurements in a region
% therefore does not fill it. To actually put orientations into the holes,
% see <EBSDFilling.html Filling Missing Data>.

%#ok<*NASGU>
%#ok<*ASGLU>
%#ok<*NOPTS>
