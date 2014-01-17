function [theta,rho,itheta,prho,rhomin] = getdata(S2G)
% return index of all points in a epsilon neighborhood of a vector
%
% Input
%  S2G     - @S2Grid
%
% Output
%  theta  - double
%  rho    - double
%  itheta - double
%  prho   - double

theta = double(S2G.thetaGrid);
rho = double(S2G.rhoGrid);
itheta = cumsum([0,GridLength(S2G.rhoGrid)]);
prho = S2G.rhoGrid(1).max;
rhomin = S2G.rhoGrid(1).min;
rhomax = S2G.rhoGrid(1).max;

