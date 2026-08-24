%% 3D - EBSD
%
%%
% Everything measured on a polished surface is a section through something
% three-dimensional, and a section is a biased witness. Cut a box of grains
% with a plane and the circles you see are almost never through the middle
% of a grain, so the sizes are systematically too small. Cut an elongated
% grain across rather than along and it looks equiaxed. The boundary you
% measure is a line where a surface met your section, and its inclination
% is simply gone.
%
% Three-dimensional data removes these compromises. It comes from serial
% sectioning - polish, map, repeat - from diffraction techniques that see
% into the volume, or from simulated microstructures generated for
% modelling.

plottingConvention.default('y↑→x');

fname = fullfile(mtexDataPath,'EBSD','SmallIN100_MeshStats.dream3d');
grains = grain3d.load(fname);

plot(grains,grains.meanOrientation,'LineStyle','none','micronbar','off')

%%
% What is drawn is the outside of the volume. The grains behind it are
% present in the data, which is the point, and also the reason a
% three-dimensional data set takes more care to look at than a map.
%
%% What three dimensions actually buy
%
% Three things, and they are worth separating because they need different
% amounts of data.
%
% *Volume instead of area.* A grain has a real size rather than a sectioned
% one, so the size distribution needs no stereological correction and no
% assumption about shape.
%
% *The whole boundary.* The interface between two grains is a surface, so
% the two numbers that a section could not give - the inclination of the
% boundary plane - are measured rather than inferred. All five parameters of
% a boundary become available at once, per boundary, which is the single
% biggest gain.
%
% *Real neighbourhood.* Two grains that appear to touch in a section may
% not, and two that do touch may not appear to. Only in three dimensions is
% the contact network of the grains the actual one.
%
%% The data is shaped differently
%
% A 2D map is a list of measurements on a grid. A 3D grain structure is
% usually a *mesh*: grains bounded by faces, faces bounded by edges, with
% the geometry carried by vertices. It is not a stack of pixels, and code
% written for maps does not carry over unchanged.
%
% The practical consequences are that faces have an orientation which may
% need fixing on import, that plotting means deciding what to hide, and
% that everything is larger - which is why a subset is usually selected
% before anything expensive.
%
%% Where to start
%
% <Grains3D.html 3D-Grains> is the entry point: importing a volume, what the
% resulting <grain3d.grain3d.html |grain3d|> object contains, and how to
% draw it.
%
% <Grains3DProperties.html Properties> and
% <Grains3DOperations.html Operations> are the three-dimensional
% counterparts of the measuring and selecting pages in
% <Grains.html Grains>. Not everything has a counterpart yet, and those
% pages say which.
%
% <NeperInterface.html Neper Interface> connects MTEX to Neper, which
% generates synthetic polycrystals. This is more useful than it may sound:
% a simulated microstructure has a known answer, which makes it the honest
% way to test whether an analysis does what you think.
%
%% Next
%
% The two-dimensional case is <EBSDAnalysis.html EBSD>,
% <Grains.html Grains> and <GrainBoundaries.html Grain Boundaries>, and
% those chapters are where the concepts are introduced. The boundary
% character that three dimensions finally makes fully measurable is
% discussed under
% <BoundaryNormalDistribution.html Boundary Normal Distribution>.
%
