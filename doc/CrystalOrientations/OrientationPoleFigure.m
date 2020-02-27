%% Pole Figures
%
%%
% Pole figures are two dimensional representations of orientations. To
% illustrate this we define a random orientation with trigonal crystal
% symmetry

cs = crystalSymmetry('321')
ori = orientation.rand(cs)

%% 
% Starting point is a fixed crystal direction |h|, e.g.,

% the fixed crystal directions (100)
h = Miller({1,0,0},cs);

%%
% Next the specimen directions corresponding to all crystal directions
% symmetrically equivalent to |h| are computed

r = ori * h.symmetrise

%%
% and ploted in a spherical projection

plot(r)

%%
% Since the trigonal symmetry group has six symmetry elements the
% orientation appears at six possitions.
%
% A shortcut for the above computations is the command

% a pole figure plot
plotPDF(ori,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},ori.CS))

%%
% We observe, that for some crystal directions only the upper hemisphere is
% plotted while for other upper and lower hemisphere are plotted. The
% reason is that if |h| and |-h| are symmetrically equivalent the upper and
% lower hemisphere of the pole figure are symmetric as well.
%
%% Contour plots

plotPDF(ori,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},ori.CS),'contourf')
mtexColorbar