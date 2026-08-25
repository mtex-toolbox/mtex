%% Inverse Pole Figures
%
%%
% An inverse pole figure answers the question a
% <OrientationPoleFigure.html pole figure> asks in reverse: given a
% direction in the specimen, which crystal direction points along it? It is
% the natural view when the specimen direction is the meaningful one - the
% normal of a rolled sheet, the axis a load was applied along, the sample
% surface an EBSD map was measured on.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('321');

ori = orientation.rand(cs)

%% Building One by Hand
%
% Fix a specimen direction.

r = vector3d.Z;

%%
% The inverse orientation takes it into crystal coordinates.

h = inv(ori) * r

%%
% Plotted with its symmetric equivalents, in the part of the sphere that
% holds one representative of each - the
% <FundamentalSector.html fundamental sector>.

plot(h.symmetrise,'fundamentalRegion')

%%
% A single point, because all six equivalents fall onto the same place once
% the sector is reduced. That is the whole purpose of the sector: it removes
% the ambiguity that symmetry introduces.

%% The Shortcut
%
% <orientation.plotIPDF.html |plotIPDF|> takes a list of specimen directions
% and does the above for each of them.

plotIPDF(ori,[vector3d.X,vector3d.Y,vector3d.Z])

%%
% Three sectors, one per specimen axis, and each shows where that axis lies
% within the crystal.

%% Contour Plots
%
% As for pole figures, |'contourf'| turns the markers into filled contours,
% which is how a whole population of orientations is read.

plotIPDF(ori,[vector3d.X,vector3d.Y,vector3d.Z],'contourf')
mtexColorbar

%%
% By default only the fundamental sector is drawn. The complete sphere shows
% what the reduction hid - the symmetric copies.

plotIPDF(ori,[vector3d.X,vector3d.Y,vector3d.Z],'contourf','complete','upper')
mtexColorbar

%%
% Inverse pole figures are also where the colours of an EBSD map come from:
% an <EBSDIPFMap.html IPF map> gives every pixel the colour of the position
% its orientation occupies in this sector.

%% Next
%
% The sector itself, and how symmetry determines its shape, is
% <FundamentalSector.html Fundamental Sector>. Its counterpart for whole
% orientations rather than directions is the
% <OrientationFundamentalRegion.html Fundamental Region>.

%#ok<*MINV>
%#ok<*NOPTS>
