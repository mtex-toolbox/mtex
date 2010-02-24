%% Rotations
%
%% Open in Editor
%
%% Contents
%
%% Description
%
% The class *rotation* is an inheritant of the class <quaternion_index.html
% quaternion> and allow to work with rotations as with matrixes in MTEX.
%
%% Defining a Rotation
%
% There are several ways to specify a rotation in MTEX. A
% well known possibility are the so called *Euler angles*. Here two
% conventions are commonly used:
%
% *The Bunge Euler Angle Convention*
%
% Here an arbitrary rotation is determined by three consecutive rotations,
% the first about the z-axis, the second about the y-axis, and the third
% again about the z-axis. Hence, one needs three angles two define an
% rotation by Euler angles. 

o = rotation('Euler',30*degree,50*degree,10*degree)

%%
% *The Matthies Euler Angle Convention*
%
% In contrast to the Bunge conventionen here the three rotations are taken
% about the z-axis, the y-axis, and the z-axis.

o = rotation('Euler',30*degree,50*degree,10*degree,'ZYZ')

%%
% *The axis angle parametrisation*
%
% Another posibility to specify a rotation is the give its rotational axis
% and its rotational angle.

o = rotation('axis',xvector,'angle',30*degree)

%% 
% *A fibre of rotations*
%
% You can also define a fibre of rotations that rotates a certain vector u
% onto a vector v

u = xvector;
v = yvector;
o = rotation('fibre',u,v)

%%
% *Four vectors defining a rotation*
%
% Given four vectors u1, v1, u2, v2 there is a unique rotations q such that 
% q u1 = v1 and q u2 = v2. 

o = rotation('map',xvector,yvector,zvector,zvector)

%%
% *Defining an rotation by a 3 times 3 matrix*

o = rotation('matrix',eye(3))

%%
% *Defining an rotation by a quaternion*
%
% A last possibility is to define a rotation by a quaternion, i.e., by its
% components a,b,c,d. 


o = rotation('quaternion',1,0,0,0)

%%
% Actually, MTEX represents internally every rotation as a quaternion.
% Hence, one can write

q = quaternion(1,0,0,0)
o = rotation(q)

%% Rotating Vectors
%
% Let 

o = rotation('Euler',90*degree,90*degree,0*degree)

%%
% a certain rotation. Then the rotation of the xvector is computed via

v = o * xvector

%%
% The inverse rotation is computed via the <rotation_mldivide.html backslash operator>

o \ v

%% Concatenating Rotations
%
% Let 

rot1 = rotation('Euler',90*degree,0,0);
rot2 = rotation('Euler',0,60*degree,0);

%%
% be two rotations. Then the rotation defined by applying first rotation
% one and then rotation two is computed by

rot = rot2 * rot1



%% Calculating with Orientations and Rotations
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX. Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion_angle.html angle(rot)> and
% <quaternion_axis.html axis(rot)> 

angle(rot)/degree

axis(rot)
%%
% The inverse rotation you get from the command
% <quaternion_inverse.html inverse(rot)>

inverse(rot)

%% Conversion into Euler Angles and Rodrigues Parametrisation
%
% There are methods to transform quaternion in almost any other
% parameterization of rotations as they are:
%
% * [[quaternion_Euler.html,Euler(rot)]]   in Euler angle
% * [[quaternion_Rodrigues.html,Rodrigues(rot)]] % in Rodrigues parameter
%

[phi1,Phi,phi2] = Euler(rot)


%% Plotting Rotations
% 
% The [[rotation_plot.html,plot]] function allows you to visualize an 
% rotation by plotting how the standard basis x,y,z transforms under the
% rotation.

cla reset;set(gcf,'position',[43   362   400   300])
plot(rot)


