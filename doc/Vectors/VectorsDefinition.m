%% Defining Vectors
%
%%
% The standard way to define a three dimensional vector is by its
% coordinates.

v = vector3d(1,1,0); 

%%
% This gives a single vector with coordinates (1,1,0) with respect to the
% x, y , z coordinate system. A second way to define a specimen directions
% is by its spherical coordinates, i.e. by its polar angle and its azimuth
% angle. This is done by the option *polar*. 

polar_angle = 60*degree;
azimuth_angle = 45*degree;
v = vector3d.byPolar(polar_angle,azimuth_angle); 

%%
% Finally, one can also define a vector as a linear combination of the
% predefined vectors <xvector.html xvector>, <yvector.html yvector>, and
% <zvector.html zvector>

v = xvector + 2*yvector; 

%% Predefined Vectors
% 

[vector3d.X vector3d.Y vector3d.Z]

%%
% The command <vector3d.rand.html vector3d.rand> allows to define random
% unit vectors

vector3d.rand

%%
% Similarly, the commands <vector3d.ones.html vector3d.ones>,
% <vector3d.zeros.html vector3d.zeros> and <vector3d.nan.html vector3d.nan>
% allow to define vectors of ones, zeros and nan.

[vector3d.ones vector3d.zeros vector3d.nan]

