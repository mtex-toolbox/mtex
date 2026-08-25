%% Multiplot
%
%%
% A figure with several pole figures in it is not a MATLAB |subplot| grid.
% MTEX manages such figures itself, through
% <mtexFigure.mtexFigure.html |mtexFigure|>, which keeps the axes the same
% size, aligns them, and lets a single colorbar and a single colour range
% apply to all of them. Every command that draws more than one thing -
% |plotPDF| over several lattice planes, |plot| of an ODF in sections -
% builds one of these figures without being asked.
%
% Building one by hand takes two commands: |newMtexFigure| creates the
% figure and its layout, |nextAxis| moves on to the next axis.

mtexFig = newMtexFigure('layout',[2,3]);

plot(xvector,'upper')

%%
% |nextAxis| without an argument takes the next free axis, filling the grid
% row by row.

nextAxis

plot(zvector,'upper')

%%
% With a row and a column it takes that particular axis, so the grid can be
% filled in any order - or left with holes.

nextAxis(2,3)

plot(vector3d.rand(200),'upper')

%%
% The axes are independent otherwise. This one is a full sphere where its
% neighbours show the upper hemisphere only.

nextAxis(2,3)

plot(xvector)

%%
% And an axis may hold something else entirely - here the crystal shape of
% a cubic symmetry beside the spherical plots.

nextAxis(2,1)

plot(crystalSymmetry('432'))

%%
% What |mtexFigure| buys over |subplot| is everything that has to be shared:
% <ColorMaps.html one colour range> across all axes, one colorbar for the
% figure, consistent axis sizes when the figure is resized, and the cropping
% that <PlottingExport.html |saveFigure|> relies on. Use |subplot| when the
% plots have nothing to do with each other - see
% <CombinedPlots.html Combined Plots>.
