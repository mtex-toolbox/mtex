function G = union(varargin)
% union of two SO3Grids
%% Input
%  G1, G2 - @SO3Grid
%% Output
%  "points" - @SO3Grid

OG = [varargin{:}];
for i = 1:length(OG), OG(i).Grid = reshape(OG(i).Grid,1,[]);end

G.alphabeta = [];
G.gamma    = [];
G.resolution = min([OG.resolution]);
G.options = {};
G.CS      = OG(1).CS;
G.SS      = OG(1).SS;
G.Grid    = [OG.Grid];

G = class(G,'SO3Grid');
