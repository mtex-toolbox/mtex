function [theta,rho,itheta,prho,rhomin] = getdata(S2G)
% return index of all points in a epsilon neighborhood of a vector
%
%% Input
%  S2G     - @S2Grid
%
%% Output
%  theta  - double
%  rho    - double
%  itheta - double
%  prho   - double

theta = double(S2G.theta);
itheta = cumsum([0,GridLength(S2G.rho)]);
rho = double(S2G.rho);
rhomin = S2G.rho(1).min;
rhomax = S2G.rho(1).max;
prho = S2G.rho(1).max;
