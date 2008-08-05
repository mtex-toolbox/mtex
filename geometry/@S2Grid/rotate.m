function G = rotate(S2G,q)
% rotate S2Grid
%% Input
%  S2G      - @S2Grid
%  rotation - @quaternion
%% Output
%  "not - indexed" - grid

if isa(q,'double')
  q = axis2quat(zvector,q);
end

G = S2G;

for i = 1:length(G)
	G(i).theta = [];
	G(i).rho = [];
	G(i).Grid = q*S2G(i).Grid;
	G(i).options = delete_option(S2G(i).options,'INDEXED');
end
