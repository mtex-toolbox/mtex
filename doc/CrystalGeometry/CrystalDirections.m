%% Crystal Directions
% Crystal directions are directions relative to a crystal reference frame
% and are usually defined in terms of Miller indices. This sections
% explains how to calculate with crystal directions in MTEX.
%
%% Open in Editor
%
%% Contents
%
%% Definition
%
% Since crystal directions are always subject to a certain crystal
% reference frame, the starting point for any crystal direction is the
% definition of a variable of type <crystalSymmetry_index.html
% crystalSymmetry>

cs = crystalSymmetry('triclinic',[5.29,9.18,9.42],[90.4,98.9,90.1]*degree,...
  'X||a*','Z||c','mineral','Talc');

%%
% The variable |cs| containes the geometry of the crystal reference frame
% and, in particular, the alignment of the crystallographic a,b, and, c axis.

a = cs.aAxis
b = cs.bAxis
c = cs.cAxis

%%
% A crystal direction |m = u * a + v * b + w * c| is a vector with
% coordinates u, v, w with respect to these crystallographic axes. In MTEX a
% crystal direction is represented by a variable of type <Miller_index.html
% Miller> which is defined by

m = Miller(1,0,1,cs,'uvw')

%%
% for values |u = 1|, |v = 0|, and, |w = 1|. To plot a crystal direction as
% a <phericalProjection_index.html spherical projections> do

plot(m,'upper','labeled','grid')

%%
% Alternatively, a crystal direction may also be defined in the reciprocal
% space, i.e. with respect to the dual axes a*, b*, c*. The corresponding
% coordinates are usually denoted by |h|, |k|, |l|. Note that for non
% Euclidean crystal frames uvw and hkl notations usually lead to different
% directions.

m = Miller(1,0,1,cs,'hkl')
hold on
plot(m,'upper','labeled')
% the corresponding lattice plane
plot(m,'plane','linecolor','r','linewidth',2)
hold off

%% Trigonal and Hexagonal Convention
%
% In the case of trigonal and hexagonal crystal symmetry, the convention of
% using four Miller indices h, k, i, l, and U, V, T, W is supported as
% well.

cs = loadCIF('quartz')
m = Miller(2,1,-3,1,cs,'UVTW')


%% Symmetrically Equivalent Crystal Directions
%
% A simple way to compute all symmetrically equivalent
% directions to a given crystal direction is provided by the command
% <Miller.symmetrise.html symmetrise>

symmetrise(m)

%%
% As always the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

symmetrise(m,'antipodal')

%%
% Using the options *symmetrised* and *labeled* all symmetrically
% equivalent crystal directions are plotted together with their Miller
% indices.

plot(m,'symmetrised','labeled','grid','backgroundcolor','w')

%%
% The command [[vector3d.eq.html,eq or ==]] can be used to check whether
% two crystal directions are symmetrically equivalent. Compare

Miller(1,1,-2,0,cs) == Miller(-1,-1,2,0,cs)

%%
% and

eq(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')

%% Angles
%
% The angle between two crystal directions m1 and m2 is defined as the
% smallest angle between m1 and all symmetrically equivalent directions to
% m2. This angle is in radians and it is calculated by the function <vector3d.angle.html
% angle>

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs)) / degree

%%
% As always the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal') / degree

%% Conversions
%
% Converting a crystal direction which is represented by its coordinates
% with respect to the crystal coordinate system a, b, c into a
% representation with respect to the associated Euclidean coordinate
% system is done by the command <Miller.vector3d.html vectord3d>.

vector3d(m)

%%
% Conversion into spherical coordinates requires the function <vector3d.polar.html
% polar>

[theta,rho] = polar(m)

%% Calculations
%
% Essentially all the operations defined for general directions, i.e. for
% variables of type [[vector3d_index.html,vector3d]] are also available for
% Miller indices. In addition Miller indices interact with crystal
% orientations. Consider the crystal orientation

o = orientation.byEuler(10*degree,20*degree,30*degree,cs)

%%
% Then one can apply it to a crystal direction to find its coordinates with
% respect to the specimen coordinate system

o * m

%%
% By applying a <symmetry_index.html crystal symmetry> one obtains
% the coordinates with respect to the specimen coordinate system of all
% crystallographically equivalent specimen directions.

p = o * symmetrise(m);
plot(p,'grid')
