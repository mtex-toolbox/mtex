%% Defining Three Dimensional Vectors
%%
plottingConvention.default('y↑→x');
%%
% Three dimensional vectors in the Euclidean space are represented by
% variables of the class <vector3d.vector3d.html *vector3d*>.
%
%% Cartesian Coordinates
% The standard way to define specimen directions is by its x, y and z
% coordinates.

v = vector3d(1,2,3)

%%
% This gives a single vector with coordinates (1,2,3) with respect to the
% X, Y, Z coordinate system. Lets visualize this vector

plot(v,'grid')

%%
% Note that the alignment of the X, Y, Z axes is only a plotting
% convention, which can be easily changed without changing the
% coordinates. For a single plot pass the convention along

pC = plottingConvention('z←↑y'); 
plot(v,'how2plot',pC,'grid')

%%
% Nothing about |v| has changed - the next plot is aligned as before. To
% change the alignment of the whole session use
% <plottingConvention.default.html |plottingConvention.default|>.

%%
% One can easily access the coordinates of any vector by

v.x

%%
% or change it by

v.x = 0

%% Polar Coordinates
%
% A second way to define specimen directions is by polar coordinates, i.e.
% by its polar angle and its azimuth angle. This is done by the option
% *polar*.

polar_angle = 60*degree;
azimuth_angle = 45*degree;
v = vector3d.byPolar(polar_angle,azimuth_angle)

plot(v,'grid')

%%
% Analogously as for the Cartesian coordinates we can access and change
% polar coordinates directly by

v.rho ./ degree   % the azimuth angle in degree
v.theta ./ degree % the polar angle in degree
