%% Crystal Directions
% Explains how to define crystal directions by Miller indices and how to
% compute crystallographic equivalent directions.
%
%% Open in Editor
%
%% Contents
%
%%
% Crystal directions are represented in MTEX by variables of type
% <Miller_index.html Miller> which represent a direction with respect to the
% crystal coordinate system a, b, c. Alternatively, a crystal direction may
% also be defined in reciprocel space, i.e. with respect to the axes a*, b*,
% c*. Essentially all operations defined for general directions, i.e. for
% variables of type [[vector3d_index.html,vector3d]] are also available for
% Miller indece.
%
%% Definition
%
% Since crystal directions are alway subject to a certain crystal
% reference frame, the starting for any crystal direction is the
% definition of a variable of type [[symmetry_index.html,symmetry]]

cs = symmetry('triclinic',[5.29,9.18,9.42],[90.4,98.9,90.1]*degree,...
  'X||a*','Z||c','mineral','Talc');

%%
% Now a crystal direction can be defined either by its coordinates u, v,
% w with respect to the crystal coordinate system a, b, c,

m = Miller(1,0,1,cs,'uvw')

%%
% or in reciprocle space, by its coordinates h, k, l with respect to axis
% a*, b*, c*

m = Miller(1,0,1,cs,'hkl')

%%
% In the case of trigonal and hexagonal crystal symmetry, the convention
% of using four Miller indices h, k, i, l, is also supported

cs = symmetry('quartz.cif')
m = Miller(2,1,-3,1,cs,'hkl')


%% Plotting Miller indece
%
% Miller indece are plotted as spherical projections. The specific
% projection as well as wheter to plot all equivalent directions can be
% specified by options.

plot(m,'Grid')   % plot Miller indece

%%
%
% By providing the options *all* and *labeled* all symmetrically equivalent
% crystal directions are plotted together with there correct Miller indice.

plot(m,cs,'all','labeled','grid')   % plot Miller indece

%% Symmetrically Equivalent Crystal Directions
%
% A simple way to compute all symmetrically equivalent
% directions to a given crystal direction is provided by the command
% <Miller_symmetrise.html symmetrise>

symmetrise(m)

%%
% As allways the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

symmetrise(m,'antipodal')

%%
% The command <vector3d_eq.html eq or ==> can be used to check whether
% two crystal directions are symmetrically equivalent. Compare

Miller(1,1,-2,0,cs) == Miller(-1,-1,2,0,cs)

%%
% and

eq(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')

%% Angles
%
% The angle between two crystall directions m1 and m2 is defined as the
% smallest angle between m1 and all symmetrically equivalent directions to
% m2. This angle in radiand is calculated by the funtion <vector3d_angle.html
% angle>

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs)) / degree

%%
% As allways the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal') / degree

%% Conversations
%
% Converting a crystal direction which is represented by its coordinates
% with respect to the crystal coordinate system a, b, c into a
% representation with respect to the associated Euclidean coordinate
% system is done by the command <Miller_vector3d.html vectord3d>.

vector3d(m)

%%
% Conversion into spherical coordinates requires the function <vector3d_polar.html
% polar>

[theta,rho] = polar(m)

%% Calculations
%
% Given a crystal orientation


o = orientation('Euler',10*degree,20*degree,30*degree,cs)

%%
% one can apply it to a crystal direction to find its coordinates with
% respect to the specimen coordinate system

o * m

%%
% By applying a <symmetry_index.html crystal symmetry> one obtains
% the coordinates with respect to the specimen coordinate system of all
% crystallographically equivalent specimen directions.

p = o * symmetrise(m);
plot(p)

