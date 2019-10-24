%% Improper Rotations
%
%%
% Improper rotations are coordinate transformations from a left handed into
% a right handed coordinate system as, e.g. a mirroring or hte inversion.
% In MTEX the inversion is defined as the negative identical rotation

I = - rotation.byEuler(0,0,0)

%%
% Note that this is convenient as both groupings of the operations "-" and
% "*" should give the same result

- (rotation.byEuler(0,0,0) * xvector)
(- rotation.byEuler(0,0,0)) * xvector

%% Mirroring
% As a mirroring is nothing else then a rotation about 180 degree about the
% normal of the mirroring plane followed by a inversion we can defined
% a mirroring about the axis (111) by

mir = -rotation.byAxisAngle(vector3d(1,1,1),180*degree)

%%
% A convenient shortcut is the command

mir = reflection(vector3d(1,1,1))

%%
% To check whether a rotation is improper or not you can do

mir.isImproper
