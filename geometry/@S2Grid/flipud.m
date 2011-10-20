function S2G = flipud(S2G)
% flip S2Grid upside down
%% Input
%  S2G      - @S2Grid
%% Output
%  S2G      - @S2Grid (not indexed)

S2G.rho = 2*pi - S2G.rho;
[theta,rho] = polar(S2G.vector3d);
S2G.vector3d = vector3d('polar',theta,2*pi-rho);
S2G = delete_option(S2G,'INDEXED');

