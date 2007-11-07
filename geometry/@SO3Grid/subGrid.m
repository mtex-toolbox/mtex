function NG = subGrid(G,q,epsilon)
% sub-SO3Grid as epsilon neigborhood of a node
% usage:  NG = subGrid(G,midpoint,radius)
% 
%% Input
%  SO3G     - @SO3Grid
%  midpoint - @quaternion
%  radius   - double
%
%% Output
%  NG - "not indexed" SO3Grid


Ind = find(G,q,epsilon);

NG.alphabeta = [];
NG.gamma    = [];
NG.resolution = G.resolution;
NG.options = delete_option(G.options,'indexed');
NG.CS      = G.CS;
NG.SS      = G.SS;
NG.Grid    = G.Grid(Ind);
NG.dMatrix = [];
    
NG = class(NG,'SO3Grid'); 
