function [NS2G,ind] = sort(S2G,varargin)
% sorts the vectors in a S2Grid according to theta / rho
%
%% Input
%
%% Output
%
%


NS2G = S2G;
[theta,rho] = polar(NS2G.Grid);

[x,ind] = sort(fix(theta/NS2G.res)*100000+rho);

NS2G.Grid = NS2G.Grid(ind);
