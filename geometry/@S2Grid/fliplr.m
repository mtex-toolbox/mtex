function S2G = fliplr(S2G)
% flip S2Grid left to right
%% Input
%  S2G      - @S2Grid
%% Output
%  S2G      - @S2Grid (not indexed)

S2G.rho = pi - S2G.rho;
[theta,rho] = polar(S2G.vector3d);
S2G.vector3d = vector3d('polar',theta,pi-rho);
S2G = delete_option(S2G,'INDEXED');
