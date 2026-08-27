%% Notation and Conventions
%
%%
% Texture analysis has more conventions than most subjects, and most of
% them are choices rather than facts. Two people can compute correctly from
% the same data and disagree, because they made different choices and
% neither said so. This page states the ones MTEX makes.
%
% The single most useful habit: when a result is rotated or mirrored from
% what you expected, the cause is almost always on this page.
%
%% Angles are radians, and |degree| converts
%
% Every angle in MTEX is in radians. There is no option to change this and
% no automatic detection. The constant |degree| holds the conversion, and
% the convention throughout the documentation is to write angles by
% multiplying with it.

10*degree

%%
% A bare |10| passed where an angle is expected is not an error - it is 10
% radians, which is a little over one and a half turns. This is a common
% cause of results that are wildly rather than subtly wrong.
%
%% Euler angles follow Bunge, and that has to be said
%
% Three angles mean nothing until you say which axes they turn about and in
% which order. MTEX uses the *Bunge* convention by default: rotate about
% Z, then about the new X, then about the new Z, written as phi1, Phi,
% phi2.

cs = crystalSymmetry('m-3m');
ori = orientation.byEuler(30*degree,50*degree,10*degree,cs);

% these two are the same call
round(Euler(ori,'Bunge')./degree)

%%
% Other conventions exist and MTEX will use them if asked, so Euler angles
% arriving from elsewhere should be treated as unlabelled until their
% convention is known. See
% <MTEXvsBungeConvention.html MTEX vs. Bunge Convention> for where MTEX
% sits relative to the textbook statement of Bunge's convention, which is
% not quite the same question.
%
%% An orientation maps crystal to specimen
%
% This is the choice that decides whether everything downstream is the
% relationship or its inverse. In MTEX an orientation applied to a crystal
% direction returns a specimen direction.

h = Miller(0,0,1,cs)   % a direction in the crystal

r = ori * h            % where it points in the specimen

%%
% So |ori * h| reads "where does crystal direction h point?", and
% |inv(ori) * r| reads "which crystal direction points along r?". The
% first is what a pole figure shows, the second an inverse pole figure.
%
% The *active* and *passive* readings of a rotation - turning the object,
% or turning the axes - are inverses of each other, which is the other
% place this ambiguity appears. See
% <DefinitionAsCoordinateTransform.html Theory>.
%
%% Planes and directions are different objects
%
% |Miller(1,0,0,cs)| is by default a *plane*, given by its Miller indices
% |(hkl)|. To mean a direction, say so with |'uvw'|. In a cubic lattice the
% two coincide, which makes cubic a poor place to learn the difference.

csQuartz = crystalSymmetry('321',[4.9 4.9 5.4],'mineral','Quartz');

% the (100) plane normal and the [100] direction of quartz
angle(Miller(1,0,0,csQuartz),Miller(1,0,0,csQuartz,'uvw')) ./ degree

%%
% Thirty degrees apart in the same crystal. For trigonal and hexagonal
% lattices MTEX displays four indices, |(hkil)|, where the third is
% redundant and equal to |-(h+k)|.
%
%% The crystal axes have to be aligned with Cartesian ones
%
% A point group says which symmetry operations exist. It does not say how
% the crystal's own axes are laid onto a Cartesian frame, and for anything
% less symmetric than cubic there is a genuine choice. MTEX's default is
% |X||a*, Z||c|, and a phase can be given a different one.
%
% This is why two correctly published tensors for the same mineral can
% disagree, and why data imported from two vendors can differ by a rotation
% that corresponds to nothing physical. See
% <SymmetryAlignment.html Crystal Axes Alignment>.
%
%% The plotting convention is a session setting
%
% Which specimen direction points east on the page, and which points out of
% it, is a property of the reference frame rather than of the data. It can
% be set for one plot, for a session, or carried by the frame the data
% lives in.
%
%   plot(x,'how2plot','y↑→x')       % this plot only
%   plottingConvention.default(...)  % the whole session
%
% Because it is a session setting it can differ between your script and an
% example you copied, and the only symptom is a figure that is mirrored or
% rotated. The documentation pages set it explicitly for this reason. See
% <AxesAlignment.html Axes Alignment>.
%
%% Units
%
% MTEX does not track units. Lengths in a map are whatever the file used,
% normally micrometres, and derived quantities inherit that silently - an
% area is in those units squared whether or not anything says so.
%
% Two cases need care because a formula divides one physical quantity by
% another. Elastic stiffness is conventionally in GPa and density in
% g/cm^3, and <WaveVelocities.html wave velocities> are only in km/s if
% both were supplied in those units - a stiffness tensor carrying no
% density yields a number that is not a velocity at all. ODF values are in
% multiples of a random distribution and are therefore dimensionless.
%
%% Names used in the examples
%
% The documentation is consistent about variable names, and following the
% same habit makes scripts easier to read:
%
% || |cs| || crystal symmetry || |ss| || specimen symmetry ||
% || |ori| || orientation || |mori| || misorientation ||
% || |odf| || orientation distribution || |pf| || pole figure ||
% || |ebsd| || an orientation map || |grains| || reconstructed grains ||
% || |h| || a crystal direction || |r| || a specimen direction ||
% || |cS| || a crystal shape || |sS| || a slip system ||
%
%% Next
%
% The terms these conventions apply to are collected in
% <Glossary.html Glossary>. The habits of the toolbox itself - lists,
% indexing, options - are in <GeneralConcepts.html General Concepts>.
%
