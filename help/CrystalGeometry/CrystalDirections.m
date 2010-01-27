%% Crystal Directions
%
%% Open in Editor
%
%% Contents
%
%% Description
%
% Crystal directions are represented in MTEX by the variables of the 
% class <Miller_index.html Miller> which in turn represent a direction with
% respect to the crystal coordinate system.  
% described  by three or four values h, l, k (,m) and a 
% [[symmetry_index.html,crystall symmetry]]. Essentially all operations
% defined for the [[vector3d_index.html,vector3d]] class are also available
% for Miller indece. Furthermore, You can ask for all crystallographically
% equivalent crystal directions to one Miller indece.
%
%% Definition
%
% Miller indice are definded by three coordinates h, k, l 
% (four in the case of trigonal or hecagonal crystal symmetry) and by the
% corresponding symmetry class. It is also possible to convert a vector3d
% object into a Miller indice.

cs = symmetry('trigonal');
m = Miller(1,0,-1,1,cs)
m = Miller(zvector,cs)

%% Plotting Miller indece
%
% Miller indece are plotted as spherical projections. The specific
% projection as well as wheter to plot all equivalent directions can be
% specified by options.

plot(Miller(2,1,-3,1,cs))   % plot Miller indece

%% Plotting Miller indece
%
% By providing the options *all* and *labeled* all symmetrically equivalent
% crystal directions are plotted together with there correct Miller indice.

plot(Miller(2,1,-3,1,cs),'all','labeled')   % plot Miller indece

%% Symmetrically Equivalent Crystal Directions
%
% A simple way to compute all symmetrically equivalent
% directions to a given crystal direction is proveded by the command
% <Miller_symmetrise.html symmetrise>

m = Miller(1,1,-2,0,cs)
symmetrise(m)

%% 
% As allways the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

symmetrise(m,'antipodal')

%%
% The command <Miller_symeq.html symeq> can also be used to check whether
% two crystal directions are symmetrically equivalent. Compare

Miller(1,1,-2,0,cs) == Miller(-1,-1,2,0,cs)

%%
% and

eq(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')

%% Angles
%
% The angle between two crystall directions m1 and m2 is defined as the
% smallest angle between m1 and all symmetrically equivalent directions to
% m2. This angle in radiand is calculated by the funtion <Miller_angle.html
% angle> 

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs))/degree

%% 
% As allways the keyword <AxialDirectional.html antipodal> adds antipodal symmetry to this
% computation

angle(Miller(1,1,-2,0,cs),Miller(-1,-1,2,0,cs),'antipodal')/degree

%% Conversations
%
% Converting Miller indice into a three dimensional vector is straight
% forward using the command <Miller_vector3d.html vectord3d>.

vector3d(m)

%%
% Conversion into spherical coordinates requires the function <vector3d_vec2sph.html
% vec2sph> 

[theta,rho] = vec2sph(m)

%% Calculations
%
% Given a crystal orientation

cs = symmetry('cubic');
o = brassOrientation(cs)

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

