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
% between several grains are *pockets*. White patches of a few pixels,
% scattered over the whole map, are *specks*. The white regions cut by the
% edge of the map, at the bottom and on the right, are *voids*.

%% The default reconstruction
%
% We reconstruct the grains with the default settings. The second output is
% the map with the |grainId| of every pixel; a pixel outside all grains has
% the |grainId| 0.

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
% around it. The crack and the voids are outside all grains: white regions
% with a boundary along each wall. The crack is whole from its mouth at the
% bottom edge to the top edge, also where it is only a few pixels wide.
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
% pixel, so we can look at what |calcGrains| saw. We plot the kinds in
% colour over the indexed pixels in light grey.

kinds = notIndexedKinds(ebsd,'angle',10*degree);

names = ["pore" "pocket" "crack" "void" "speck"];
color = [0.2 0.4 1; 1 0.6 0; 1 0 0; 0 0 0; 0.55 0.55 0.55];

plot(ebsd('indexed'),'FaceColor',[0.9 0.9 0.9],'micronbar','off')
legend off
hold on
for k = 1:5
  plot(ebsd(kinds == names(k)),'FaceColor',color(k,:),'DisplayName',names(k))
end
hold off

%%
% The whole crack is one red band, from its mouth at the bottom edge to the
% top edge. The round pores inside the large grains are blue, the pockets
% between the grains are orange and the regions cut by the map edge are
% black. The grey specks are everywhere; they make up more than half of all
% |notIndexed| pixels.
%
% Each kind is closed with a radius of its own, in pixels. A region
% narrower than twice its radius is filled, a wider one keeps its core.
%
% * Specks are what the radius |alpha| fills, 3.1 pixels by default, as in
% <GrainReconstruction.html Grain Reconstruction>.
% * Pores are closed with |'alphaPore'|, which is |inf| by default: a pore
% is filled whatever its size.
% * Pockets are closed with |'alphaPocket'|, which is |alpha| by default: a
% pocket that |alpha| leaves open stays open.
% * Cracks are closed with |'alphaCrack'|, which is 0 by default: a crack is
% never closed, not even where it is narrower than |2*alpha|.
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
% the two widest pockets keep a core as a |notIndexed| grain, and
% |'alphaPocket',inf| fills those as well. The crack is as open as before.

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
% We look at the crack, with the boundaries of the reconstruction with the
% pockets closed in red and the new boundaries in black.

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grainsP.boundary,'linewidth',2,'LineColor','r')
plot(grainsC.boundary,'linewidth',2)
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
% they can be wrong for a map. |kinds| is a categorical array with one entry
% per pixel, so it can be edited and handed back to |calcGrains| with the
% option |'kinds'|. Every region then takes the kind that its pixels say. To
% treat the crack as a void, for example, so that |'alphaCrack'| leaves it
% alone:
%
%   kinds(kinds == "crack") = "void";
%   grains = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'kinds',kinds);

%% How the kinds are told apart
%
% The closing with |alpha| fills every |notIndexed| region narrower than
% |2*alpha| pixels; what it fills are the specks. What it leaves open are
% the thick parts of the white regions, and each of them gets its kind from
% its shape and its surroundings, in this order. A region that is long
% compared with its area and walled by grains is a crack: the square of its
% longest diameter is at least five times its area, and at least half of its
% boundary runs along grains. A region touching the edge of the map is a
% void. A region whose rim is held by one grain is a pore: at least 85
% percent of the indexed pixels around it are connected by the same
% criterion that |calcGrains| uses to join pixels into grains. Every other
% region is a pocket. Finally, whatever lies between two pieces of a crack,
% joined to both by |notIndexed| pixels, counts as part of the crack, so
% that a crack stays whole where it widens and where it narrows.

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
