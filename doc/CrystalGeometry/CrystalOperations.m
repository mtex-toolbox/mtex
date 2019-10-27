%% Operations Crystal Directions
%
%%
% In this section we discuss basic operations with crystal directions.
% Therefore, lets start by importing the trigonal Quartz crystal symmetry

cs = loadCIF('quartz')

%%
% and consider two hexgonal prism normal

m1 = Miller(1,-1,0,0,cs)
m2 = Miller(1,0,-1,0,cs)

plot(m1,'upper','labeled','backgroundColor','w')
hold on
plot(m2,'labeled','backgroundColor','w')
hold off

%% Zone Axes
%
% Both prism planes intersects in a common zone axis which is orthogonal to
% both plane normals can is computed by

d = round(cross(m1,m2))

%%
% Note that MTEX automatically switches from reciprocal to direct
% coordinates for displaying the zone axis. 
%
% The other way round two, not paralllel, zone axes

d1 = Miller(0,0,0,1,cs,'UVTW');
d2 = Miller(1,-2,1,3,cs,'UVTW');

%%
% span a lattice plane with normal vector

round(cross(d1,d2))

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

symmetrise(d2)

%%
% As always the keyword <VectorsAxes.html antipodal> adds antipodal
% symmetry to this computation

symmetrise(d2,'antipodal')

%%
% Using the options *symmetrised* and *labeled* all symmetrically
% equivalent crystal directions are plotted together with their Miller
% indices. Lets apply this to a list of lattice planes

h = Miller({1,0,-1,0},{1,1,-2,0},{1,0,-1,1},{1,1,-2,1},{0,0,0,1},cs);

for i = 1:length(h)
  plot(h(i),'symmetrised','labeled','backgroundColor','w','grid','upper','doNotDraw')
  hold all
end
hold off
drawNow(gcm,'figSize','normal')

%%
% 
% The command <vector3d.eq.html eq or == > can be used to check whether
% two crystal directions are symmetrically equivalent. Compare

Miller(1,1,-2,0,cs) == Miller(-1,-1,2,0,cs)

%%
% and

eq(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')

%% Angles
%
% The angle between two crystal directions m1 and m2 is defined as the
% smallest angle between m1 and all symmetrically equivalent directions to
% m2. This angle is in radians and it is calculated by the function
% <vector3d.angle.html angle>

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs)) / degree

%%
% As always the keyword <VectorsAxes.html antipodal> adds antipodal
% symmetry to this computation

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal') / degree

%%
% In order to ignore the crystal symmetry, i.e., to compute the actual
% angle between two directions use the option *noSymmetry*

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'noSymmetry') / degree

%%
% This option is available for many other functions involving crystal
% directions and crystal orientations.
%
%% Calculations
%
% Essentially all the operations defined for general directions, i.e. for
% variables of type <vector3d.vector3d.html vector3d> are also available for
% Miller indices. In addition Miller indices interact with crystal
% orientations. Consider the crystal orientation

ori = orientation.byEuler(10*degree,20*degree,30*degree,cs)

%%
% Then one can apply it to a crystal direction to find its coordinates with
% respect to the specimen coordinate system

ori * m1

%%
% By applying a <crystalSymmetry.crystalSymmetry.html crystal symmetry> one
% obtains the coordinates with respect to the specimen coordinate system of
% all crystallographically equivalent specimen directions.

p = ori * symmetrise(m1);
plot(p,'grid')

% 
% The above plot is essentialy the pole figure representation of the
% orientation *ori*.
%
%% Conversions
%
% Converting a crystal direction which is represented by its coordinates
% with respect to the crystal coordinate system a, b, c into a
% representation with respect to the associated Euclidean coordinate system
% is done by the command <Miller.vector3d.html vectord3d>.

vector3d(m1)

%%
% Conversion into spherical coordinates requires the function <vector3d.polar.html
% polar>

[theta,rho] = polar(m1)