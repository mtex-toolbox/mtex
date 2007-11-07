function G = union(G1,G2)
% union of two SO3Grids
%% Input
%  G1, G2 - @SO3Grid
%% Output
%  "points" - @SO3Grid

G.alphabeta = [];
G.gamma    = [];
G.resolution = min(G1.resolution,G2.resolution);
G.options = {};
G.CS      = G1.CS;
G.SS      = G1.SS;
G.Grid    = [G1.Grid,G2.Grid];
G.dMatrix = [];

G = class(G,'SO3Grid');
