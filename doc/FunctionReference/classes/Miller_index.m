%% Crystal Directions (The Class @Miller)
% This section describes the class *Miller* and gives an overview how to
% deal with crystal directions in MTEX.
%
%% Open in Editor
%
%% Contents
%
%% Class Description
% Crystal directions are represented in MTEX by the variables of the class
% *Miller* which in turn represent a direction with respect to the crystal
% coordinate system described  by three or four values h, l, k (,m) and a
% <crystalSymmetry_index.html crystall symmetry>. Essentially all operations
% defined for the @vector3d class are also available for Miller indices.
% Furthermore, You can ask for all crystallographically equivalent crystal
% directions to one Miller index.
%
%% SUB: Defining Miller indices
%
% Miller indices are defined by three coordinates h, k, l
% (four in the case of trigonal or hexagonal crystal symmetry) and by the
% corresponding symmetry class. It is also possible to convert a vector3d
% object into a Miller index.

cs = crystalSymmetry('trigonal');
m = Miller(1,0,-1,1,cs)
m = Miller(zvector,cs)

%% SUB: Plotting Miller indices
%
% Miller indices are plotted as spherical projections. The specific
% projection as well as whether to plot all equivalent directions can be
% specified by options.

plot(Miller(2,1,-3,1,cs))   % plot Miller indices

%%
%
% By providing the options *all* and *labeled* all symmetrically equivalent
% crystal directions are plotted together with their correct Miller indices.

plot(Miller(2,1,-3,1,cs),'all','labeled')   % plot Miller indices

%% SUB: Symmetrically Equivalent Crystal Directions
%
% A simple way to compute all symmetrically equivalent
% directions to a given crystal direction is provided by the command
% <Miller.symmetrise.html symmetrise>

m = Miller(1,1,-2,0,cs)
symmetrise(m)

%%
% As always the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

symmetrise(m,'antipodal')

%%
% The command <vector3d.eq.html eq or ==> can be used to check whether
% two crystal directions are symmetrically equivalent. Compare

Miller(1,1,-2,0,cs) == Miller(-1,-1,2,0,cs)

%%
% and

eq(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')

%% SUB: Angle between directions
%
% The angle between two crystal directions m1 and m2 is defined as the
% smallest angle between m1 and all symmetrically equivalent directions to
% m2. This angle in radians is calculated by the function <vector3d.angle.html
% angle>

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs)) / degree

%%
% As always the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal') / degree

%% SUB: Conversions
%
% Converting Miller indices into a three-dimensional vector is straight
% forward using the command <Miller.vector3d.html vectord3d>.

vector3d(m)

%%
% Conversion into spherical coordinates requires the function <vector3d.polar.html
% polar>

[theta,rho] = polar(m)

%% SUB: Calculations
%
% Given a crystal orientation

o = orientation.byEuler(20*degree,30*degree,40*degree,cs)

%%
% one can apply it to a crystal direction to find its coordinates with
% respect to the specimen coordinate system

o * m

%%
% By applying a [[symmetry_index.html,crystal symmetry class]] one obtains
% the coordinates with respect to the specimen coordinate system of all
% crystallographically equivalent specimen directions.

p = o * symmetrise(m);
plot(p)
