%% Specimen Directions
%
%% Abstract
% This section describes the class *vector3d* and gives an overview how to
% deal with specimen directions in MTEX.
%
%% Open in Editor
%
%% Contents
%
%% Description
%
% Specimen directions are three dimensional vectors in the Euclidean space
% represented by coordinates with respect to a outer specimen coordinate
% system x, y, z. Im MTEX Specimen directions are represented by variables
% of the class *vector3d*. 
%
%% Defining Specimen Directions
%
% The standard way to define a specimen directions is by its coordinates. 

v = vector3d(1,1,0); 

%%
% This gives a single vector with coordinates (1,1,0) with respect to the
% x, y , z coordinate system. A second way to define a specimen directions
% is by its spherical coordinates, i.e. by its polar angle and its azimuth
% angle. This is done by the option *polar*. 

polar_angle = 60*degree;
azimuth_angle = 45*degree;
v = vector3d('polar',polar_angle,azimuth_angle); 

%%
% Finally one can also define a vector as a linear combination of the
% predefined vectors <xvector.html xvector>, <yvector.html yvector>, and
% <zvector.html zvector>

v = xvector + 2*yvector; 


%% Calculating with Specimen Directions
%
% As we have seen in the last example. One can calculate with specimen
% directions as with ordinary number. Moreover, all basic vector operation as 
% [[vector3d_plus.html,"+"]], [[vector3d_minus.html,"-"]], 
% [[vector3d_times.html,"*"]], [[vector3d_dot.html,inner product]], 
% [[vector3d_cross.html,cross product]] are implemented. 

u = dot(v,xvector) * yvector + 2 * cross(v,zvector);

%% 
% Using the brackets |v = [v1,v2]| two specimen directions can be concatened. Now each
% single vector is accesable via |v(1)| and |v(2)|.

w = [v,u];
w(1)
w(2)

%%
% When calculating with concatenated specimen directions all operations are
% performed componentwise for each specimen direction.

w = w + v;

%%
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX.
%
%  [[vector3d_angle.html,angle(v1,v2)]] % angle between two specimen  directions
%  [[vector3d_dot.html,dot(v1,v2)]]   % inner product
%  [[vector3d_cross.html,cross(v1,v2)]] % cross product
%  [[vector3d_norm.html,norm(v)]]      % length of the specimen directions
%  [[vector3d_sum.html,sum(v)]]       % sum over all specimen directions in v
%  [[vector3d_mean.html,mean(v)]]      % mean over all specimen directions in v  
%  [[vector3d_polar.html,polar(v)]]   % conversion to spherical coordinates
%
% A simple example for apply the norm function is to normalize a set of
% specimen directions

w = w ./ norm(w)

%% Plotting three dimensionl vectors
% 
% The [[vector3d_plot.html,plot]] function allows you to visualize an 
% arbitrary number of specimen directions in a spherical projection

cla reset;set(gcf,'position',[43   362   200   200])
plot([zvector,xvector+yvector+zvector],'labeled')

 
