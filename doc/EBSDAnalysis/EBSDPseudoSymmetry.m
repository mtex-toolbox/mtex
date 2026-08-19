%% Correcting Pseudo Symmetry
%
% A pseudo symmetry is a rotation that is *not* a symmetry of the crystal
% but nevertheless maps the diffraction pattern almost onto itself. The
% indexing algorithm has then no reliable criterion to decide between the
% true orientation and the orientation rotated by the pseudo symmetry and
% picks essentially at random. As a consequence single grains appear in the
% orientation map as two or more grains that are separated by a boundary
% with exactly the pseudo symmetric misorientation.
%
% Such boundaries can be told apart from real grain boundaries by their
% shape. A real grain boundary is a physical interface and hence a
% reasonably smooth curve. A boundary that only separates the two indexing
% solutions follows the noise of the indexing and is therefore ragged. This
% is measured by the *tortuosity*
%
% $$ \tau = \frac{\textrm{length of the boundary}}{\textrm{distance between its end points}} $$
%
% which is close to one for a straight boundary and large for a ragged one.
% The command <cleanUpPseudoSym.html |cleanUpPseudoSym|> uses exactly this
% criterion: it merges all grains that are separated by a tortuous boundary
% with a pseudo symmetric misorientation and rotates the orientations of
% the smaller part by the pseudo symmetry.
%
%% A Data Set With Pseudo Symmetry
%
% Olivine is a classical example. Its oxygen sublattice is almost
% hexagonally close packed with the stacking axis along [100], i.e.,
% rotations about [100] by multiples of 60 degree map the oxygen positions
% nearly onto themselves although the true symmetry |mmm| contains only the
% 180 degree rotation. Let us import a Forsterite data set and reconstruct
% the grains.

plottingConvention.default('y↑→x');
mtexdata forsterite

% consider only indexed data
ebsd = ebsd('indexed');

% reconstruct the grain structure
[grains,ebsd] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);

% plot the orientation map of the Forsterite phase
plot(ebsd('Fo'),ebsd('Fo').orientations)

hold on
plot(grains.boundary,'linewidth',1.5)
hold off

%%
% Note that we did *not* smooth the grain boundaries. Since
% <cleanUpPseudoSym.html |cleanUpPseudoSym|> decides by the raggedness of
% the boundaries, smoothing has to be applied after the correction and not
% before.
%
%% Detecting the Pseudo Symmetry
%
% If we do not know the pseudo symmetry beforehand we may look for it in
% the distribution of the boundary misorientations. Since we expect a
% rotation about 60 degree we restrict ourselves to those boundaries and
% plot the distribution of the corresponding rotational axes.

% the misorientations at all Forsterite - Forsterite boundaries
mori = grains.boundary('Fo','Fo').misorientation;

% restrict to those with a rotational angle close to 60 degree
mori = mori(mori.angle > 55*degree & mori.angle < 65*degree);

% and plot the distribution of the rotational axes
plot(mori.axis,'contourf','fundamentalRegion','halfwidth',5*degree)
mtexColorbar

%%
% The sharp maximum at [100] confirms our expectation. Accordingly we
% define the pseudo symmetry as the rotation about [100] by 60 degree.

cs = ebsd('Fo').CS;
psSym = orientation.byAxisAngle(Miller(1,0,0,cs,'uvw'),60*degree)

%%
% Modulo the true symmetry |mmm| the rotations by 60 and by 120 degree are
% two different operations - the latter being the inverse of the former -
% and both occur in the map, since the indexing may have picked either
% solution. It is nevertheless enough to pass one of them. A measurement is
% a fixed representative of an orientation, so the alternative solution is
% not simply |ori * psSym| but |ori * s * psSym| for some symmetry element
% |s|, and <cleanUpPseudoSym.html |cleanUpPseudoSym|> generates all these
% operators itself. Passing 60 degree, 120 degree or both gives the same
% result.
%
% Note also that the pseudo symmetry is a misorientation, i.e., it has the
% same crystal symmetry on both sides. This is required by
% <cleanUpPseudoSym.html |cleanUpPseudoSym|> and at the same time tells the
% command which phase it should correct.
%
%% Pseudo Symmetric Grain Boundaries
%
% Let us select all boundary segments whose misorientation is the pseudo
% symmetry and have a closer look at one of the affected regions. A grain
% boundary has no direction - its misorientation carries the grain exchange
% symmetry - so this catches the segments of both solutions at once.

gB = grains.boundary('Fo','Fo');
gB = gB(any(angle(gB.misorientation,psSym) < 2*degree,2))

%%

% a region containing one of the pseudo symmetric grains
region = [27300 1900 1000 700];

% plot the orientation map of this region
ebsdS = ebsd(inpolygon(ebsd,region));
plot(ebsdS('Fo'),ebsdS('Fo').orientations)

% and on top the grain boundaries
hold on
plot(grains.boundary,'linewidth',1.5)
plot(gB,'linewidth',3,'linecolor','r')
hold off

%%
% The blue region has been indexed with the second solution. Note how the
% red boundary meanders around single pixels instead of following a smooth
% curve - this is the signature we are after.
%
%% The Tortuosity Criterion
%
% Internally <cleanUpPseudoSym.html |cleanUpPseudoSym|> splits the selected
% boundary segments into connected components and computes for each
% component its total length and the distance between its extreme points.

% the connected components of the pseudo symmetric boundaries
compId = gB.componentId;

% the length of each component
len = accumarray(compId,gB.segLength);

% the extent of each component
xmin = accumarray(compId,gB.midPoint.x,[],@min);
xmax = accumarray(compId,gB.midPoint.x,[],@max);
ymin = accumarray(compId,gB.midPoint.y,[],@min);
ymax = accumarray(compId,gB.midPoint.y,[],@max);
dist = sqrt((xmax-xmin).^2 + (ymax-ymin).^2);

% the tortuosity and the number of segments of each component
tortuosity = len ./ dist;
numSeg = accumarray(compId,1);

% components above the threshold are considered as pseudo symmetric
plot(numSeg,tortuosity,'o','MarkerFaceColor','b')
hold on
plot(xlim,[1.5 1.5],'r--')
hold off
xlabel('number of segments'), ylabel('tortuosity')

%%
% Very short components are unreliable - a component consisting of a single
% segment has zero extent and hence infinite tortuosity, which is why two
% of the components are missing in the plot above. For this reason only
% components with more than four segments are taken into account.
%
%% Correcting the Map
%
% All this is done by a single call to <cleanUpPseudoSym.html
% |cleanUpPseudoSym|>. It returns the corrected EBSD data, the grains after
% merging and the number of pixels that have been rotated.

[ebsdC,grainsC,numChanged] = cleanUpPseudoSym(ebsd,grains,psSym);

numChanged

%%
% Plotting the same region again we see that the two indexing solutions
% have been unified into a single grain.

ebsdS = ebsdC(inpolygon(ebsdC,region));
plot(ebsdS('Fo'),ebsdS('Fo').orientations)

hold on
plot(grainsC.boundary,'linewidth',1.5)
hold off

%%
% Only now, with the pseudo symmetric boundaries removed, it makes sense to
% smooth the grain boundaries
%
%   grainsC = smoothBoundary(grainsC,5);
%
%% Options
%
% The tolerance within which a boundary misorientation has to match the
% pseudo symmetry is controlled by the option |'delta'|, the tortuosity
% above which a component is considered as pseudo symmetric by the option
% |'threshold'|
%
%   [ebsdC,grainsC] = cleanUpPseudoSym(ebsd,grains,psSym,...
%     'delta',2*degree,'threshold',1.5)
%
% Lowering the threshold corrects more boundaries but eventually starts to
% remove real grain boundaries as well. It is therefore a good idea to look
% at the tortuosity plot above before choosing it.
%
% Since the pseudo symmetry determines the phase that is corrected, only a
% single phase is treated per call. In order to clean up several phases
% simply call the command once for every phase, each time with the pseudo
% symmetries of that phase.
