function S2G = refine(S2G)
% refine S2Grid
%% Input
%  S2G - @S2Grid
%
%% Output
%  S2G - @S2Grid with half the resolution

if ~check_option(S2G.options,'INDEXED'), error('not supported for "not indexed" grids');end

S2G.res = S2G.res / 2;
S2G.theta = refine(S2G.theta);
for i=1:length(S2G.rho)  
  S2G.rho(2*i-1) = refine(S2G.rho(i));  
end

theta = double(S2G.theta);
for i = 2:2:GridLength(S2G.theta)
  
  % construct full circle
  nrho= max(round(sin(theta(i)) * 2*pi/S2G.res),1);
  rho = (0:nrho-1)*2*pi/nrho;
    
  % take only those that are close to existing ones
  d = min(dist_outer(S2G.rho(i-1),rho));
  if i+1 <= length(theta)
    d = min(d,min(dist_outer(S2G.rho(i+1),rho)));
  end  
  
  rho = rho(sin(theta(i-1))*d < S2G.res*1.5);
  S2G.rho(i) = S1Grid(rho,...
    getMin(S2G.rho(i-1)),getMax(S2G.rho(i-1)),check_option(S2G.rho(i-1)));
    
end

S2G.vector3d = calcGrid(S2G.theta,S2G.rho);
