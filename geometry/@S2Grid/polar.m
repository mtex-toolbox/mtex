function [theta,rho] = polar(S2G,varargin)
% polar coordinates of S2Grid
%
%% Input
%  S2G - S2Grid
%  indece - int32 (optional)
%% Output
% [theta,rho] - double

if check_option(S2G.options,'INDEXED')
  theta = double([S2G.theta]);
  theta = rep(theta,GridLength(S2G.rho));
  rho = double([S2G.rho]);
  theta = reshape(theta,size(S2G));
  rho = reshape(rho,size(S2G));
else
  [theta,rho] = polar(S2G.vector3d);
end

if nargout == 0
  disp('theta:');
  disp(theta);
  disp('rho:');
  disp(rho);
	theta = [];rho = [];
end
