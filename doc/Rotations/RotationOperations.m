%% Calculating with Rotations
%
%% Rotating Vectors
%
% Let

o = rotation.byEuler(90*degree,90*degree,0*degree)

%%
% a certain rotation. Then the rotation of the xvector is computed via

v = o * xvector

%%
% The grey arrows are the specimen axes, the black arrow is the direction we
% started from and the red arrow is where the rotation sent it.

arrow3d(1.2*[vector3d.X,vector3d.Y,vector3d.Z],'faceColor',[.75 .75 .75])
hold on
arrow3d(1.05*xvector,'faceColor','black')
arrow3d(1.05*v,'faceColor','red')
hold off
axis off

%%
% The inverse rotation is computed via the <rotation.mldivide.html
% backslash operator>

o \ v

%% Concatenating Rotations
%
% Let

rot1 = rotation.byEuler(90*degree,0,0);
rot2 = rotation.byEuler(0,60*degree,0);

%%
% be two rotations. Then the rotation defined by applying first rotation
% one and then rotation two is computed by

rot = rot2 * rot1

%% Rotational angle and the rotational axis
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


%% The inverse Rotation
%
% The inverse rotation you get from the command
% <quaternion.inv.html inv(rot)>

inv(rot)

%% Conversion into Euler Angles and Rodrigues Parametrisation
%
% There are methods to transform rotations in almost any other
% parameterization of rotations as they are:
%
% * <quaternion.Euler.html, Euler(rot)>   in Euler angle
% * <quaternion.Rodrigues.html, Rodrigues(rot)>  in Rodrigues parameter
%

[alpha,beta,gamma] = Euler(rot,'Matthies')
