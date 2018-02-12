%% Rotations
% Rotations are the basic concept to understand crystal orientations and
% crystal symmetries.
%%
% Rotations are represented in MTEX by the class *@rotation* which is
% inherited from the class <quaternion_index.html quaternion> and allow to
% work with rotations as with matrixes in MTEX.
%
%% Open in Editor
%
%% Contents
%
%% Euler Angle Conventions
%
% There are several ways to specify a rotation in MTEX. A
% well known possibility are the so called *Euler angles*. In texture
% analysis the following conventions are commonly used
%
% * Bunge (phi1,Phi,phi2)       - ZXZ
% * Matthies (alpha,beta,gamma) - ZYZ
% * Roe (Psi,Theta,Phi)
% * Kocks (Psi,Theta,phi)
% * Canova (omega,Theta,phi)
%
% *Defining a Rotation by Bunge Euler Angles*
%
% The default Euler angle convention in MTEX are the Bunge Euler angles.
% Here a rotation is determined by three consecutive rotations,
% the first about the z-axis, the second about the y-axis, and the third
% again about the z-axis. Hence, one needs three angles to define an
% rotation by Euler angles. The following command defines a rotation by its
% three Bunge Euler angles

o = rotation('Euler',30*degree,50*degree,10*degree)


%%
% *Defining a Rotation by Other Euler Angle Conventions*
%
% In order to define a rotation by a Euler angle convention different to
% the default Euler angle convention you to specify the convention as an
% additional parameter, e.g.

o = rotation('Euler',30*degree,50*degree,10*degree,'Roe')


%%
% *Changing the Default Euler Angle Convention*
%
% The default Euler angle convention can be changed by the command
% *setpref*, for a permanent change the
% <matlab:edit('mtex_settings.m') mtex_settings> should be edited. Compare

setMTEXpref('EulerAngleConvention','Roe')
o

%%
setMTEXpref('EulerAngleConvention','Bunge')
o

%% Other Ways of Defining a Rotation
%
% *The axis angle parametrisation*
%
% A very simple possibility to specify a rotation is to specify the
% rotation axis and the rotation angle.

o = rotation('axis',xvector,'angle',30*degree)

%%
% *Four vectors defining a rotation*
%
% Given four vectors u1, v1, u2, v2 there is a unique rotation q such that
% q u1 = v1 and q u2 = v2.

o = rotation('map',xvector,yvector,zvector,zvector)

%%
% If only two vectors are specified, then the rotation with the smallest
% angle is returned and gives the rotation from first vector onto the
% second one.

o = rotation('map',xvector,yvector)

%%
% *A fibre of rotations*
%
% The set of all rotations that rotate a certain vector u onto a certain
% vector v define a fibre in the rotation space. A discretisation of such a
% fibre is defined by

u = xvector;
v = yvector;
o = rotation('fibre',u,v)


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


%% Calculating with Rotations
%
% *Rotating Vectors*
%
% Let

o = rotation('Euler',90*degree,90*degree,0*degree)

%%
% a certain rotation. Then the rotation of the xvector is computed via

v = o * xvector

%%
% The inverse rotation is computed via the <rotation.mldivide.html
% backslash operator>

o \ v

%%
% *Concatenating Rotations*
%
% Let

rot1 = rotation('Euler',90*degree,0,0);
rot2 = rotation('Euler',0,60*degree,0);

%%
% be two rotations. Then the rotation defined by applying first rotation
% one and then rotation two is computed by

rot = rot2 * rot1

%%
% *Computing the rotation angle and the rotational axis*
%
% Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion.angle.html angle(rot)> and
% <quaternion.axis.html axis(rot)>

rot.angle / degree

rot.axis

%%
% If two rotations are specifies the command
% <quaternion.angle.html angle(rot1,rot2)> computes the rotational angle
% between both rotations

angle(rot1,rot2) / degree


%%
% *The inverse Rotation*
%
% The inverse rotation you get from the command
% <quaternion.inv.html inv(rot)>

inv(rot)

%% Improper Rotations
% Improper rotations are coordinate transformations from a left hand into a
% right handed coordinate system as, e.g. mirroring or inversion.
% In MTEX the inversion is defined as the negative identy rotation

I = - rotation('Euler',0,0,0)

%%
% Note that this is convenient as both groupings of the operations "-" and
% "*" should give the same result

- (rotation('Euler',0,0,0) * xvector)
(- rotation('Euler',0,0,0)) * xvector

%%
% *Mirroring*
%
% As a mirroring is nothing else then a rotation about 180 degree about the
% normal of the mirroring plane followed by a inversion we can defined
% a mirroring about the axis (111) by

mir = -rotation('axis',vector3d(1,1,1),'angle',180*degree)

%%
% A convenient shortcut is the command

mir = reflection(vector3d(1,1,1))

%%
% To check whether a rotation is improper or not you can do

mir.isImproper

%% Conversion into Euler Angles and Rodrigues Parametrisation
%
% There are methods to transform quaternion in almost any other
% parameterization of rotations as they are:
%
% * <quaternion.Euler.html, Euler(rot)>   in Euler angle
% * <quaternion.Rodrigues.html, Rodrigues(rot)>  in Rodrigues parameter
%

[alpha,beta,gamma] = Euler(rot,'Matthies')


%% Plotting Rotations
%
% The <quaternion.scatter.html scatter> function allows you to visualize a
% rotation in Rodriguez space.

% define 100 random rotations
rot = rotation.rand(100)

% and plot the Rodriguez space
scatter(rot)
