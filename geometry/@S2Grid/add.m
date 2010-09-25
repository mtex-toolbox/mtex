function S2G = add(S2G,points)
% add points to a grid
%% Input
%  S2G    - @S2Grid
%  points - @vector3d
%
%% Output
%  S2G    - @S2Grid

S2G = delete_option(S2G,'INDEXED');
S2G.vector3d = [S2G.vector3d(:);points(:)]; 
