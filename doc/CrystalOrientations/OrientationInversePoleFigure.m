%% Inverse Pole Figure
%
%%
% Inverse pole figures are two dimensional representations of orientations.
% To illustrate this we define a random orientation with trigonal crystal
% symmetry

cs = crystalSymmetry('321');
ori = orientation.rand(cs)

%% 
% Starting point is a fixed specimen direction |r|, e.g.,

% the fixed crystal directions z
r = vector3d.Z

%%
% Next the crystal direction |h| corresponding to the specimen direction
% |r| according to the orientation |ori| is computed

h = inv(ori) * r

%%
% and ploted in a spherical projection

plot(h.symmetrise,'fundamentalRegion')

%%
% A shortcut for the above computations is the command
% |<orientation.plotIPDF.html plotIPDF>|

% an inverse pole figure plot
plotIPDF(ori,[vector3d.X,vector3d.Y,vector3d.Z])

%% Contour plots

plotIPDF(ori,[vector3d.X,vector3d.Y,vector3d.Z],'contourf')
mtexColorbar

%%

plotIPDF(ori,[vector3d.X,vector3d.Y,vector3d.Z],'contourf','complete','upper')
mtexColorbar