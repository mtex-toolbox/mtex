%% Miller Indices
% Miller indices are used to describe directions with respect to the
% crystal reference system.
%
%% Open in Editor
%
%% Contents
%
%% Crystal Lattice Directions
%
% Since lattice directions are always subject to a certain crystal
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
% A lattice direction |m = u * a + v * b + w * c| is a vector with
% coordinates u, v, w with respect to these crystallographic axes. Such a
% direction is commonly denoted by [uvw] with coordinates u, v, w called
% Miller indices. In MTEX a lattice direction is represented by a variable
% of type <Miller_index.html Miller> which is defined by

m = Miller(1,0,1,cs,'uvw')

%%
% for values |u = 1|, |v = 0|, and, |w = 1|. To plot a crystal direction as
% a <phericalProjection_index.html spherical projections> do

plot(m,'upper','labeled','grid')

%% Crystal Lattice Planes
%
% A crystal lattice plane (hkl) is commonly described by its normal vector
% |n = h * a* + k * b* + l * c*| where a*, b*, c* describes the reciprocal
% crystal coordinate system. In MTEX a lattice plane is defined by

m = Miller(1,0,1,cs,'hkl')

%%
% By default lattice planes are plotted as normal directions. Using the
% option |plane| we may alternatively plot the trace of the lattice plane
% with the sphere.

hold on
% the normal direction
plot(m,'upper','labeled')

% the trace of the corresponding lattice plane
plot(m,'plane','linecolor','r','linewidth',2)
hold off

%%
% Note that for non Euclidean crystal frames uvw and hkl notations usually
% lead to different directions.
%s
%% Trigonal and Hexagonal Convention
%
% In the case of trigonal and hexagonal crystal symmetry often four digit
% Miller indices [UVTW] and (HKIL) are used, as they make it more easy to
% identify symmetrically equivalent directions. This notation is reduntant
% as the first three Miller indeces always sum up to zero, i.e., $U + V +
% T = 0$ and $H + K + I = 0$. The syntax is

% import trigonal Quartz lattice structure
cs = loadCIF('quartz')

% a four digit lattice direction
m = Miller(2,1,-3,1,cs,'UVTW')

plot(m,'upper','labeled')

n = Miller(1,1,-2,3,cs,'HKIL')

hold on
plot(n,'upper','labeled')
hold off


%% Symmetrically Equivalent Crystal Directions
%
% Since crystal lattices are symmetric lattice directions can be grouped
% into classes of symmetrically equivalent directions. Those groups can be
% derived by permuting the Miller indeces (uvw). The class of all
% directions symmetrically equivalent to (uvw) is commonly denoted by
% <uvw>, while the class of all lattice planes symmetrically equivalent to
% the plane (hkl) is denoted by {hkl}. Given a lattice direction or a
% lattice plane all symmetrically equivalent directions and planes are
% computed by the command <Miller.symmetrise.html symmetrise>
% 

symmetrise(m)

%%
% As always the keyword <AxialDirectional.html antipodal> adds antipodal
% symmetry to this computation

symmetrise(m,'antipodal')

%%
% Using the options *symmetrised* and *labeled* all symmetrically
% equivalent crystal directions are plotted together with their Miller
% indices.

plot(m,'symmetrised','labeled','grid','backgroundcolor','w')

%%
% 
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
