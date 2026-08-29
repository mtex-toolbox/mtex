%% Neper Interface
%
% <https://neper.info Neper> is an open-source package developed by Romain
% Quey for generating and meshing polycrystals. MTEX can configure a Neper
% tessellation, run it, and load the result as a @grain3d collection.
% <Grains3D.html Three-Dimensional Grains> defines that representation and
% introduces selection and sectioning.
%
% A planar section is useful when the three-dimensional microstructure must
% be compared with a two-dimensional map. It is not required for analysing
% the original @grain3d collection.

plottingConvention.default('y↑→x');

%% Check the external program
%
% Install Neper separately and make its executable available on the system
% path. Its <https://neper.info/doc/ documentation> gives platform-specific
% installation instructions. On Windows, the MTEX interface calls Neper
% through the Windows Subsystem for Linux.
%
% The check below keeps this page executable on systems without Neper. In
% that case, the simulation section loads a bundled tessellation explicitly.
% This avoids mistaking an old output file for a successful new simulation.

if ispc
  [neperStatus,~] = system('wsl neper --version');
else
  [neperStatus,~] = system('neper --version');
end
hasNeper = neperStatus == 0;

%% Choose files and geometry
%
% <neper.neper.html |neper.init|> creates the interface object. By default,
% Neper works in |fullfile(tempdir,'neper')|. Keeping generated files under
% the temporary directory prevents a documentation run from overwriting a
% project tessellation.
%
% The default three-dimensional base name is |allgrains|, and the default
% two-dimensional base name is |2dslice|. Neper adds |.tess| and |.ori|;
% three-dimensional output may also include |.stpoly|. Assign |filePath|,
% |fileName3d|, or |fileName2d| when these defaults are unsuitable.

if hasNeper
  neper.init;
  neper.filePath = fullfile(tempdir,'mtex-neper-doc');
  neper.fileName3d = 'my100grains';
  neper.fileName2d = 'my100GrSlice';
end

%%
% For example, an existing project directory could be selected with
%
%   neper.filePath = 'C:\Users\user\Documents\work\MtexWork\neper';
%
% The |geometry| property controls the outer domain. Its default is
% |"cube(1,1,1)"|. Cuboids use |"cube(x,y,z)"|; cylinders use
% |"cylinder(h,d,numFaces)"|; spheres use |"sphere(d,numFaces)"|.

if hasNeper
  neper.geometry = "cube(4,4,2)";
end

%% Control repeatability and morphology
%
% Neper uses the integer |id| as the seed for the initial seed positions.
% Reusing it makes the initial tessellation repeatable. The default is |1|.
%
% The |morpho| string sets the target cell morphology. The default
% |'graingrowth'| is an alias for the lognormal equivalent-diameter and
% sphericity distributions below. Neper documents further choices under
% <https://neper.info/doc/neper_t.html#cmdoption-morpho morphology options>.

if hasNeper
  neper.id = 529;
  neper.morpho = ...
    'diameq:lognormal(1,0.35),1-sphericity:lognormal(0.145,0.03)';
end

%% Simulate a textured microstructure
%
% <neper.simulateGrains.html |simulateGrains|> accepts either an orientation
% distribution function (<ODFTheory.html ODF>) and a grain count, or a list
% of orientations.
% For a list, its length determines the grain count. The |'silent'| option
% writes Neper's console output to |neper.log| in |filePath|.

odf = SO3Fun.dubna;
numGrains = 1000;

if hasNeper
  grains = neper.simulateGrains(numGrains,odf,'silent');
else
  tessFile = fullfile(mtexDataPath,'Neper','my100grains.tess');
  grains = grain3d.load(tessFile,'CS',odf.CS);
end
grains

%%
% To prescribe every orientation rather than sample the ODF internally, use
%
%   ori = odf.discreteSample(numGrains);
%   grains = neper.simulateGrains(ori,'silent');
%
% The summary confirms that the result is a three-dimensional grain
% collection. When the bundled fallback is used, its stored orientations
% replace a newly sampled list.

clf
plot(grains,grains.meanOrientation,'micronbar','off')
how2plot = plottingConvention.default3D;
setCamera(how2plot)

%%
% The colours encode one mean orientation per polyhedral grain. The outer
% envelope follows the cuboid selected by the simulation that created this
% tessellation.

%% Compare planar sections
%
% The earlier <Grains3D.html sectioning example> defines
% <grain3d.slice.html |slice|>. A slice normal and either a point in the plane
% or its signed distance from the origin specify the cutting plane. Here all
% three sections pass through the centre of the collection.

N = [vector3d(0,0,1),vector3d(1,-1,0),vector3d(2,2,4)];
A = grains.midPoint;

grains001 = grains.slice(N(1),A);
grains1_10 = grains.slice(N(2),A);
grains224 = grains.slice(N(3),A)

newMtexFigure('layout',[1,3],'figSize','large');
plot(grains001,grains001.meanOrientation,'micronbar','off');
mtexTitle('(001) normal')
nextAxis
plot(grains1_10,grains1_10.meanOrientation,'micronbar','off');
mtexTitle('(1 -1 0) normal')
nextAxis
plot(grains224,grains224.meanOrientation,'micronbar','off');
mtexTitle('(2 2 4) normal')

%%
% The three panels show differently oriented planes. Their unequal outlines
% show how the same cuboid and its grains are sampled by horizontal and
% oblique sections.
%
% <neper.getSlice.html |neper.getSlice|> is a separate route that asks Neper
% to write a two-dimensional |.tess| file. Use |grain3d.slice| when the
% three-dimensional collection is already loaded and no external file is
% needed.

%% Relate a section to its parent grains
%
% <grain3d.intersected.html |intersected|> selects the full polyhedra crossed
% by a plane. Overlaying those grains on the horizontal section connects each
% planar polygon to the three-dimensional material that produced it.

inPlane = grains.intersected(N(1),A);

plot(grains001,grains001.meanOrientation,'micronbar','off');
hold on
plot(grains(inPlane),grains(inPlane).meanOrientation,'faceAlpha',0.55)
hold off
setCamera(how2plot)

%%
% The opaque polygons are the section itself. The translucent polyhedra
% extend to both sides of the plane and are the corresponding parent grains.

%% References
%
% * R. Quey, P. R. Dawson and F. Barbe,
% <https://doi.org/10.1016/j.cma.2011.01.002 Large-scale 3D random
% polycrystals for the finite element method: Generation, meshing and
% remeshing>, _Computer Methods in Applied Mechanics and Engineering_ 200
% (2011), 1729--1745, presents the generation and meshing methods implemented
% in Neper.

%% Next
%
% Continue with
% <Grains3DProperties.html Properties of Three-Dimensional Grains> to measure
% the faces, surface area, volume, and shape of the generated collection.

%#ok<*NOPTS>
