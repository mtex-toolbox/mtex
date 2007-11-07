%% The Class vector3d
% class representing three dimensional vectors
%
%% Description
%
% The class vector3d allows to work with three dimensional vectors in MTEX,
% as they occur e.g. as specimen dircetions. Objects of the class vector3d
% can be handeled like ordinary in MATLAB. All basic vector operation as 
% [[vector3d_plus.html,"+"]], [[vector3d_minus.html,"-"]], 
% [[vector3d_times.html,"*"]], [[vector3d_dot.html,inner product]], 
% [[vector3d_cross.html,cross product]] are implemented. Furthermore,
% conversation methods to spherical coordinates or 
% [[vec2Miller.html,Miller indece]] exists.
%
%% Defining three dimensional vectors
%
% The standard way is to define a vector3d by its coordinates. However you
% can also define it by its spherical coordinates or as linear combination
% of predefined vectors.

v = vector3d(1,1,0);      % by coordinates
v = sph2vec(0,45*degree); % by spherical coordinates (azimuth, )
v = xvector + yvector;    % predefined vectors

%% 
% Using the brackets |v = [v1,v2]| two vectors can be concatened. Now each
% single vector is accesable via |v(1)| and |v(2)|.

%% Calculating with three dimensional vectors
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX.
%
%  [[vector3d_dot.html,dot(v1,v2);]]   % inner product
%  [[vector3d_cross.html,cross(v1,v2);]] % cross product
%  [[vector3d_norm.html,norm(v);]]      % norm of the vector
%  [[vector3d_sum.html,sum(v);]]       % sum over all vectors in v
%  [[vector3d_mean.html,mean(v);]]      % mean over all vectors in v  
%  [[vector3d_vec2sph.html,vec2sph(v);]]   % conversion to spherical coordinates
%
%% Plotting three dimensionl vectors
% 
% The [[vector3d_plot.html,plot]] function allows you to visualize an 
% arbitrary number of three dimensional vectors in a spherical projection

cla reset;set(gcf,'position',[43   362   300   300])
plot([zvector,xvector+yvector+zvector],'FontSize',20)

