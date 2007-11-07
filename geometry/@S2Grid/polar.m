function [theta,rho] = polar(S2G)
% polar coordinates of S2Grid
%
%% Input
%  S2G - S2Grid
%  indece - int32 (optional)
%% Output
% [theta,rho] - double

if check_option(S2G(1).options,'INDEXED')
	theta = double([S2G.theta]);
	theta = rep(theta,GridLength([S2G.rho]));
	rho = double([S2G.rho]);
  if length(S2G)==1
    theta = reshape(theta,GridSize(S2G));
    rho = reshape(rho,GridSize(S2G));
  end
elseif length(S2G) == 1
  [theta,rho] = polar(S2G.Grid);
else
  for i = 1:length(S2G), S2G(i).Grid = reshape(S2G(i).Grid,1,[]);end  
	[theta,rho] = polar([S2G.Grid]);
end

if nargout == 0
  disp('theta:');
  disp(theta);
  disp('rho:');
  disp(rho);
	theta = [];rho = [];
end
