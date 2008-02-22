%% The Class quaternion
% class representing orientations
%
%% Description
%
% The class quaternion allows to work with rotations in MTEX,
% as they occur e.g. as crystal orientation or symmetries. Quaternions may
% be multiplied with [[vector3d_index.html,three dimensional vecotors]] 
% which means rotating the vector or may by multiplied with another 
% quaternion which means to concatenate both rotations. 
%
%% Defining three dimensional vectors
%
% The standard way is to define a quaternion q is to give its coordinates
% (a,b,c,d). However making use of one of the following conversion methods
% is much more human readable.
%
%  q = [[quaternion_quaternion.html,quaternion]](a,b,c,d)          % by coordinates
%  q = [[axis2quat.html,axis2quat]](axis,angle);       % by rotational axis and rotational angle
%  q = [[euler2quat.html,euler2quat]](alpha,beta,gamma) % by Euler angles
%  q = [[Miller2quat.html,Miller2quat]]([h k l],[u v w],symmetry); % by Miller indece
%  q = [[idquaternion.html,idquaternion]];                % identical quaternion
%  q = [[vec42quat.html,vec42quat]](u1,v1,u2,v2);      % by four vectors
%
% Additional methods to define a rotation are [[hr2quat.html,hr2quat]] and 
% [[vec42quat.html,vec42quat]].
% Using the brackets |q = [q1,q2]| two quaternions can be concatened. Now each
% single quaternion is accesable via |q(1)| and |q(2)|.

%% Calculating with three dimensional vectors
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX.
%
%  [[quaternion_rotangle.html,rotangle(q)]]; % rotational angle
%  [[quaternion_rotaxis.html,rotaxis(q);]]  % rotational axisq2 = Miller2quat([-1 -1 -1],[1 -2 1]);
%  [[quaternion_inverse.html,inverse(q);]]  % inverse rotation 
%
%% Conversion
%
% There are methods to transform quaternion in almost any other
% parameterization of rotations as they are:
%
%  [[quaternion_quat2euler.html,quat2euler(q)]]     % in Euler angle
%  [[quaternion_quat2rodriguez.html,quat2rodriguez(q)]] % in Rodriguez parameter
%
%% Plotting quaternions
% 
% The [[quaternion_plot.html,plot]] function allowq2 = Miller2quat([-1 -1 -1],[1 -2 1]);s you to visualize an 
% quaternion by plotting how the standard basis x,y,z transforms under the
% rotation.

cla reset;set(gcf,'position',[43   362   300   300])
plot(Miller2quat([-1 -1 -1],[1 -2 1]),'FontSize',20)


