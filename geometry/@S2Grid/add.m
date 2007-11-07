function G = add(S2G,points)
% add points to a grid
%% Input
%  S2G    - @S2Grid
%  points - @vector3d
%
%% Output
%  @S2Grid

G = S2G;

G.options = delete_option(G.options,'INDEXED');
G.Grid = [G.Grid(:);points(:)]; 
G.theta = [];
G.rho = [];
