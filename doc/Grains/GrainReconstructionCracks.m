%% Cracks and Pores
%
%%
% A map of a natural rock or a sintered material rarely consists of grains
% alone. Wherever no pattern could be indexed, the map is |notIndexed|. On a
% specimen surface that happens at cracks, at pores and where material was
% plucked out during sample preparation. This page shows what |calcGrains|
% does with these regions, how to close the ones that are not of interest,
% and how to bridge a crack when the grains on its two sides belong
% together. It assumes the basic reconstruction from
% <GrainReconstruction.html Grain Reconstruction>.

%% The data
%
% The map is a thin section of a peridotite, a mantle rock made mainly of
% olivine (forsterite), orthopyroxene (enstatite) and clinopyroxene
% (diopside). The step size is 60 micron, so the map is about 33 mm wide.
% The data are courtesy of David Mainprice, Géosciences Montpellier.

mtexdata peridotite silent

plot(ebsd,'micronbar','off')

%%
% The white regions are |notIndexed|, and they are of several kinds. A
% *crack* crosses the left half of the map from the bottom edge to the top
% edge, wide in its lower part and narrow in its upper part. Round holes
% inside some of the large forsterite grains are *pores*. Irregular gaps
% between several grains are *pockets*. Single white pixels scattered over
% the map are *specks*. The white regions cut by the edge of the map, at the
% bottom and on the right, are *voids*.

%% The default reconstruction
%
% We reconstruct the grains with the default settings. The second output is
% the map with the |grainId| of every pixel. We keep it apart from |ebsd|,
% so that every reconstruction on this page starts from the measured map.

[grains,ebsdGrains] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);
grains = smoothBoundary(grains);

fprintf('%d grains, %d notIndexed, %.1f%% of the map outside all grains\n', ...
  length(grains), length(grains('notIndexed')), ...
  100*nnz(ebsdGrains.grainId==0)/length(ebsd))

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grains.boundary,'linewidth',1.5)
plot(grains('notIndexed'),'FaceColor','black','FaceAlpha',0.35)
hold off

%%
% Each kind has ended up in a different place. The specks and the pores
% are inside the grains: they show white, without a boundary around them,
% and the grain continues around them. The pockets are the darkened regions.
% Each is a |notIndexed| grain of its own, with a boundary to every grain
% around it. The crack and the voids are outside all grains. They are white
% bands with a boundary along each wall, and their pixels have the |grainId|
% 0.
%
% This is usually what one wants. A pore is a hole in a grain and its area
% belongs to that grain. A crack is a fracture, so the grains stop at its
% walls. A pocket is material that was not indexed, and it is a question of
% the map whether it should be a grain of its own.

%% The kinds of notIndexed regions
%
% |calcGrains| sorts the |notIndexed| regions into these kinds and treats
% every kind by a rule of its own. The command
% <EBSD.notIndexedKinds.html |notIndexedKinds|> returns the kind of every
% pixel, so we can look at what |calcGrains| saw. We plot the kinds over the
% map: pores blue, pockets orange, cracks red, voids black and specks grey.

kinds = notIndexedKinds(ebsd,'angle',10*degree);

color = [0.2 0.4 1; 1 0.6 0; 1 0 0; 0 0 0; 0.7 0.7 0.7];
isNotIndexed = ~ebsd.isIndexed;

plot(ebsd,'micronbar','off')
legend off
hold on
plot(ebsd(isNotIndexed),color(double(kinds(isNotIndexed)),:))
hold off

%%
% The whole crack is one red band, from its mouth at the bottom edge to the
% top edge. The round pores inside the forsterite grains are blue, the
% pockets between the grains are orange and the regions cut by the map edge
% are black. The grey specks are everywhere; they make up more than half of
% all |notIndexed| pixels. The narrow strip along the bottom right edge is
% red as well, which we come back to at the end of the page.
%
% Each kind is closed with a radius of its own, in pixels. A region
% narrower than twice its radius is filled, a wider one keeps its core.
%
% * Specks are closed with the radius |alpha|, 3.1 by default, as in
% <GrainReconstruction.html Grain Reconstruction>.
% * Pores are closed with |'alphaPore'|, which is |inf| by default: a pore
% is filled whatever its size.
% * Pockets are closed with |'alphaPocket'| and cracks with |'alphaCrack'|.
% Both are |alpha| by default, so a pocket or a crack that |alpha| leaves
% open stays open.
% * Voids are never closed.

%% Closing the pockets
%
% Often the pockets are not of interest, and we want a map of grains without
% |notIndexed| grains in between, while the crack stays open. We set
% |'alphaPocket'| to 10, which fills every pocket narrower than 20 pixels.

[grainsP,ebsdP] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alphaPocket',10);
grainsP = smoothBoundary(grainsP);

fprintf('%d grains, %d notIndexed, %.1f%% of the map outside all grains\n', ...
  length(grainsP), length(grainsP('notIndexed')), ...
  100*nnz(ebsdP.grainId==0)/length(ebsd))

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grainsP.boundary,'linewidth',1.5)
plot(grainsP('notIndexed'),'FaceColor','black','FaceAlpha',0.35)
hold off

%%
% The pockets have been shared out between the grains around them. Where
% several grains meet in a former pocket, their boundaries run through it
% as straight lines, the shortest boundaries the filled region allows. Only
% the four widest pockets keep a core as a |notIndexed| grain, and
% |'alphaPocket',inf| fills those as well. The crack is as open as before.
%
% A large |alpha| would close the pockets too. But |alpha| only knows the
% width of a region, so it would also close the narrow upper part of the
% crack and join the grains on its two sides.

%% Bridging the crack
%
% A crack came after the grains, so the pieces on its two sides may be parts
% of one former grain. To count them as one grain, we bridge the crack. We
% set |'alphaCrack'| to 15, which bridges the crack wherever it is narrower
% than 30 pixels. Where the two sides have nearly the same orientation they
% become one grain. Where they differ by more than the threshold angle, a
% new boundary runs through the crack.

[grainsC,ebsdC] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alphaPocket',10,'alphaCrack',15);
grainsC = smoothBoundary(grainsC);

fprintf('%d grains, %d notIndexed, %.1f%% of the map outside all grains\n', ...
  length(grainsC), length(grainsC('notIndexed')), ...
  100*nnz(ebsdC.grainId==0)/length(ebsd))

%%
% We look at the crack, with the boundaries of the default reconstruction in
% red and the new boundaries in black.

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grains.boundary,'linewidth',1,'LineColor','r')
plot(grainsC.boundary,'linewidth',1)
hold off
axis([2500 12500 7000 17940])

%%
% The red walls of the crack have no black boundary on them any more: the
% grains reach across. Where a grain on the left has the same orientation
% as its neighbour on the right, no boundary separates them, and the two
% pieces are one grain. Where the orientations differ, a black boundary
% crosses the crack as a straight line between the points where it meets
% the two walls. Only the mouth of the crack at the bottom edge, wider than
% 30 pixels, remains outside all grains.

%% Correcting a kind
%
% The kinds are read from the shape and the surroundings of a region, and
% they can be wrong for a map. The strip along the bottom right edge is
% long and narrow enough to count as a crack, yet it is the rim of a region
% plucked out of the specimen, a void. With |'alphaCrack',15| it has been
% bridged like the crack.
%
% |kinds| is a categorical array with one entry per pixel, so it can be
% edited and handed back to |calcGrains| with the option |'kinds'|. Every
% region then takes the kind that its pixels say. We mark the strip as a
% void and reconstruct again. The maps show the bottom right corner before
% and after the correction.

kindsEdited = kinds;
kindsEdited(kinds(:) == "crack" & ebsd.x(:) > 20000) = "void";

[grainsE,ebsdE] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alphaPocket',10,'alphaCrack',15,'kinds',kindsEdited);
grainsE = smoothBoundary(grainsE);

newMtexFigure('layout',[1 2]);
for g = {grainsC,grainsE}
  nextAxis
  plot(ebsd,'micronbar','off')
  legend off
  hold on
  plot(g{1}.boundary,'linewidth',1.5)
  hold off
  axis([24500 29500 15500 17940])
end

%%
% On the left the grains reach across the strip to the edge of the map. On
% the right the strip is outside all grains, like the plucked region beside
% it.

%% How the kinds are told apart
%
% The closing with |alpha| fills every |notIndexed| region narrower than
% |2*alpha| pixels; what it fills are the specks. What it leaves open are
% the thick parts of the map, and each of them gets its kind from its shape
% and its surroundings, in this order. A region that is long compared with
% its area is a crack: the square of its longest diameter is at least five
% times its area. A region touching the edge of the map is a void. A region
% whose rim is held by one grain is a pore: at least 85 percent of the
% indexed pixels around it are connected by the same criterion that
% |calcGrains| uses to join pixels into grains. Every other region is a
% pocket. Finally, a pore or a pocket joined to a crack by |notIndexed|
% pixels and lying between its pieces counts as part of the crack, so that a
% crack stays whole where it widens.

%% References
%
% * F. Bachmann, R. Hielscher, and H. Schaeben,
% <https://doi.org/10.1016/j.ultramic.2011.08.002 Grain Detection from 2d
% and 3d EBSD Data---Specification of the MTEX Algorithm>,
% _Ultramicroscopy_ 111 (2011), 1720--1733. This paper derives the Voronoi
% reconstruction used by |calcGrains|, including the closing of
% |notIndexed| regions.

%% Next
%
% <GrainMerge.html Merging Grains> explains merging grains by other
% criteria, such as a twin relationship, and how an inclusion is merged into
% the grain around it. <GrainSmoothing.html Grain Boundary Smoothing>
% compares the smoothing filters. To estimate orientations inside pores and
% cracks rather than only assigning them to grains, see
% <EBSDFilling.html Fill Missing Data in Orientation Maps>.
