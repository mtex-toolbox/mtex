%% Plotting Individual Orientations
% Basics of the plot types for individual orientations data
%
%%
% A map answers the question where. The plots on this page answer the
% question what: they throw the positions away and show only the
% orientations, as a scatter of points in one space or another. Which space
% is chosen decides what is easy to see - a preferred direction, a fibre, a
% cluster of related orientations - and every one of them is drawing the
% same list.

plottingConvention.default('y↑→x');
mtexdata forsterite

%%
% The list in question is one orientation per measurement of a single
% phase.

ebsd('Fo').orientations

%%
% All 152345 of them would make a solid blot of ink, so the plotting
% commands draw a random subset and say how large it was. Ask for a
% different number with |'points'|, or for the whole list with |'all'|.
%
%% Pole figures
%
% A pole figure asks where one crystal direction ends up in the specimen.
% Each measurement contributes the points at which its $(100)$ axis
% pierces the sphere, drawn by
% <orientation.plotPDF.html |plotPDF|>.

plotPDF(ebsd('Fo').orientations,Miller(1,0,0,ebsd('Fo').CS))

%%
% The points are far from evenly spread: they form a broad girdle running
% from north to south through the centre of the figure, and the eastern rim
% around the |RD| label is almost empty. So the $a$ axes of these
% forsterite crystals lie preferentially in the plane containing the
% specimen normal and the transverse direction, and hardly ever along the
% rolling direction.
%
%% Inverse pole figures
%
% The inverse pole figure asks the same question backwards: given a fixed
% specimen direction, which crystal direction points that way. It is drawn
% by <orientation.plotIPDF.html |plotIPDF|> and its domain is the
% fundamental sector of the crystal, not the whole sphere.

plotIPDF(ebsd('Fo').orientations,xvector)

%%
% The points crowd towards the $[010]$ corner and thin out towards $[100]$,
% which is the previous figure read from the other end - the specimen $x$
% axis is rarely the crystal $a$ axis.
%
%% Sections through orientation space
%
% A pole figure loses information, since many orientations put the same
% axis in the same place. Sections through the orientation space itself
% lose nothing, at the price of needing several plots.
% <orientation.plotSection.html |plotSection|> cuts orientation space into
% slices; the sigma sections used here are described in
% <SigmaSections.html Sigma Sections>.

plotSection(ebsd('Fo').orientations,'points',1000,'sigma','sections',9)

%%
% The thousand points asked for are distributed over the nine sections,
% each of which is one slice of the whole space.
%
%% The orientation space directly
%
% Orientations can also be scattered into a single plot of the orientation
% space, which by default is drawn in Bunge Euler angles.

scatter(ebsd('Fo').orientations)

%%
% The clusters are the same information again - grains that share an
% orientation - but Euler space distorts distances badly near $\Phi = 0$,
% so use it to spot clusters rather than to judge how far apart two
% orientations are. Passing |'axisAngle'| or |'rodrigues'| draws the
% respective parametrization instead, and |'center'| moves the region that
% is being drawn.
%
%% The same plots for grains
%
% Grains carry a mean orientation, so every command above applies to them
% as well, and the two can be drawn on top of each other.

grains = calcGrains(ebsd);

%%
% Here the individual measurements go down first and the grain means on
% top.

plotIPDF(ebsd('Fo').orientations,xvector,'points',1000, 'MarkerSize',3);

hold on
plotIPDF(grains('Fo').meanOrientation,xvector,'points',500, 'MarkerSize',3);
hold off

%%
% The two clouds cover the same region, as they must, but not with the same
% weight. A measurement counts once, so a large grain contributes thousands
% of points; a grain mean counts once whatever the grain's size. The means
% are therefore the more evenly spread of the two, and reach into parts of
% the sector where the measurements are thin.
%
%% Colouring the points
%
% A scatter plot has a second channel free. Passing a list of numbers along
% with the orientations colours each point by it - here the mean angular
% deviation of the fit, so that badly indexed measurements can be told from
% good ones.

h = [Miller(1,0,0,ebsd('Fo').CS),Miller(1,1,0,ebsd('Fo').CS)];
plotPDF(ebsd('Fo').orientations,ebsd('Fo').mad,h,'antipodal','MarkerSize',4)

%%
% Any other quantity works the same way. On grains, the area is the obvious
% one, since it says which of the points in the plot carry weight.

plotSection(grains('Fo').meanOrientation,log(grains('Fo').area),...
  'sigma','sections',9,'MarkerSize',10);

%%
% <PlotTypes.html Plot Types> covers scatter plots in general and
% <SphericalProjections.html Spherical Projections> the projections these
% figures are drawn in.
%
