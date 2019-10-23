%% Defining Rotations
%
% In this section we describe many different ways to define or to describe
% rotations. In the end however, every description results in an variable
% of type <rotation.rotation.html>. 
%
%% Euler Angles
%
% One of the most common ways to describe a rotation is as three subsequent
% rotations about fixed axes, e.g., first around the z axis, second around
% the x axis and third again around the z. The corresponding rotational
% angles are commonly called Euler angles. As for the axes different
% conventions are in use. Sorted by popularity in the texture analysis
% community these are
%
% * Bunge (phi1,Phi,phi2)       - ZXZ
% * Matthies (alpha,beta,gamma) - ZYZ
% * Roe (Psi,Theta,Phi)
% * Kocks (Psi,Theta,phi)
% * Canova (omega,Theta,phi)
%
% The default Euler angle convention in MTEX are the Bunge Euler angles,
% with axes Z, X, and Z. The following command defines a rotation by its
% three Bunge Euler angles

rot = rotation.byEuler(30*degree,50*degree,10*degree)

%%
% Note that the angles needs to be multiplied with *degree* since all
% commands in MTEX expect the input in radiant. Furthermore, the order of
% the first and the third Euler angle are interchanged in comparison to
% standard notation for reasons explained <MTEXvsBungeConvention.html
% here>.
%
% In order to define a rotation by a Euler angle convention different to
% the default Euler angle convention you to specify the convention as an
% additional parameter, e.g.

rot = rotation.byEuler(30*degree,50*degree,10*degree,'Roe')

%%
% This does not change the way MTEX displays the rotation on the screen.
% The default Euler angle convention for displaying a rotation can be
% changed by the command <setMTEXpref.html setMTEXpref>, for a permanent
% change the <matlab:edit('mtex_settings.m') mtex_settings> should be
% edited. Compare

setMTEXpref('EulerAngleConvention','Roe')
rot

%%
setMTEXpref('EulerAngleConvention','Bunge')
rot

%% Axis angle parametrisation and Rodrigues Frank vector
%
% A very simple possibility to specify a rotation is to specify the
% rotation axis and the rotation angle.

rot = rotation.byAxisAngle(xvector,30*degree)

%%
% Conversely, we can extract the rotational axis and the rotation angle of
% a rotation by

rot.axis
rot.angle ./degree

%%
% Closely related to the axis angle parameterisation of a rotation is the
% Rodriguess Frank vector. This is the rotational axis scaled by $\tan
% \omega/2$, where $\omega$ is the rotational angle.

R = rot.Rodrigues

2 * atan(norm(R))./degree

%%
% We can also define a rotation by a Rodrigues Frank vector by

rotation.byRodrigues(R)


%% Rotation Matrix
%
% Another common way to represent rotations is by 3x3 matrices. The column
% of such a rotation matrix coincide with the new positions of the x, y and
% z vector after the rotation. For a given rotation we may compute the
% matrix by

M = rot.matrix

%%
% Conversely, we may define a rotation by its matrix with the command

rot = rotation.byMatrix(M)


%% Four vectors defining a rotation
%
% Another useful method to define a rotation is by describing how in acts
% on two given directions. More precisely, given four vectors u1, v1, u2,
% v2 there is a unique rotation |rot| such that |rot * u1 = v1| and |rot *
% u2 = v2|. E.g., to find the rotation the maps the x-axis onto the y-axis
% and keeps the z-axis we do

u1 = vector3d.X;
v1 = vector3d.Y;
u2 = vector3d.Z;
v2 = vector3d.Z;


rot = rotation.map(u1,v1,u2,v2)

%%
% The above definition require that the angle between u1 and u2 is the same
% as between v1 and v2. The function gives an error if this condition is
% not meet. If only two vectors are specified, then the rotation with the
% smallest angle is returned that rotates the first vector onto the second
% one.

rot = rotation.map(xvector,yvector)


%% Logarithm, Exponential Mapping, Spin Tensor
%
% TODO

S = spinTensor(rot)

rotation(S)

vector3d(S)

%%

v = log(rot)

rotation(exp(v))

%% Quaternions
%
% A last possibility to describe a rotation is by quaternions given by
% components a, b, c, d.

q = quaternion(rot)

%%
% Actually, MTEX represents internally every rotation as a
% <quaternion.quaternion.html quaternion>. To transform a quaternion back
% into a rotation do

rot = rotation(q)
