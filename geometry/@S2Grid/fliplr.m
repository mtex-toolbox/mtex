function S2G = fliplr(S2G)
% flip S2Grid left to right
%% Input
%  S2G      - @S2Grid
%% Output
%  S2G      - @S2Grid (not indexed)

S2G.rho = pi - S2G.rho;
[theta,rho] = vec2sph(S2G.vector3d);
S2G.vector3d = sph2vec(theta,pi-rho);
S2G.options = delete_option(S2G.options,'INDEXED');
