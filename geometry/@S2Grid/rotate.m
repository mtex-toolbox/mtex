function S2G = rotate(S2G,q)
% rotate S2Grid
%% Input
%  S2G      - @S2Grid
%  rotation - @quaternion
%% Output
%  S2G      - @S2Grid (not indexed)

if isa(q,'double'), q = axis2quat(zvector,q);end

S2G.vector3d = q*S2G.vector3d;
S2G.options = delete_option(S2G.options,'INDEXED');
