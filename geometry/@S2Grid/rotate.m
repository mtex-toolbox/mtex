function S2G = rotate(S2G,q)
% rotate S2Grid
%% Input
%  S2G      - @S2Grid
%  rotation - @quaternion
%% Output
%  S2G      - @S2Grid (not indexed)

if isa(q,'double'), q = axis2quat(zvector,q);end

for i = 1:length(S2G)
	%S2G(i).theta = [];
	%S2G(i).rho = [];
	S2G(i).Grid = q*S2G(i).Grid;
	S2G(i).options = delete_option(S2G(i).options,'INDEXED');
end
