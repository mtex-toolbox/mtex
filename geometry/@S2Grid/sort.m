function [S2G,ind] = sort(S2G,varargin)
% sorts the vectors in a S2Grid according to theta / rho
%
%% Input
%
%% Output
%
%

[theta,rho] = polar(S2G);

[x,ind] = sort(fix(theta/S2G.res)*100000+rho);

S2G.Grid = S2G.Grid(ind);
