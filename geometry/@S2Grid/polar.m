function [theta,rho] = polar(S2G,varargin)
% polar coordinates of S2Grid
%
% Input
%  S2G - S2Grid
%  indece - int32 (optional)
% Output
% [theta,rho] - double

theta = double([S2G.theta]);
theta = rep(theta,GridLength(S2G.rho));
rho = double([S2G.rho]);
theta = reshape(theta,size(S2G));
rho = reshape(rho,size(S2G));
  
% correct data
ind = (rho < 0.0001) | (rho > 2.0001*pi);
rho(ind) = mod(rho(ind),2*pi);

if nargout == 0
  
  d = [theta(:)/degree,rho(:)/degree];
  disp('polar angles in degree')
  cprintf(d,'-L','  ','-Lc',{'azimuth angle' 'polar angle'});
  clear theta
  clear rho
end
