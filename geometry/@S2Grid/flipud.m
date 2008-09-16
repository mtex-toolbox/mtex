function S2G = flipud(S2G)
% flip S2Grid upside down
%% Input
%  S2G      - @S2Grid
%% Output
%  S2G      - @S2Grid (not indexed)

for i = 1:length(S2G)
	S2G(i).theta = [];
	S2G(i).rho = [];
  [theta,rho] = vec2sph(S2G(i).Grid);
	S2G(i).Grid = sph2vec(theta,2*pi-rho);
	S2G(i).options = delete_option(S2G(i).options,'INDEXED');
end
