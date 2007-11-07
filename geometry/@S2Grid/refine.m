function NG = refine(S2G)
% refine S2Grid
%% Input
%  S2G - @S2Grid
%
%% Output
%  S2Grid with half the resolution

if ~check_option(S2G.options,'INDEXED'), error('not supported for "not indexed" grids');end

NG = S2G;
NG.res = S2G.res / 2;
NG.theta = refine(S2G.theta);
for i=1:length(S2G.rho)  
  NG.rho(2*i-1) = refine(S2G.rho(i));  
end

theta = double(NG.theta);
for i = 2:2:GridLength(NG.theta)
  
  % construct full circle
  nrho= max(round(sin(theta(i)) * 2*pi/NG.res),1);
  rho = (0:nrho-1)*2*pi/nrho;
    
  % take only those that are close to existing ones
  d = min(dist_outer(NG.rho(i-1),rho));
  if i+1 <= length(theta)
    d = min(d,min(dist_outer(NG.rho(i+1),rho)));
  end  
  
  rho = rho(sin(theta(i-1))*d < NG.res*1.5);
  NG.rho(i) = S1Grid(rho,...
    getMin(NG.rho(i-1)),getMax(NG.rho(i-1)),check_option(NG.rho(i-1)));
    
end

NG.Grid = calcGrid(NG.theta,NG.rho);
