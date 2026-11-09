%% Cracks and Pores
%
%%
% A map of a natural rock or a sintered material rarely consists of grains
% alone. Wherever a pattern could not be indexed, the map is |notIndexed|.
% On a specimen surface that happens at cracks, at pores and where material
% was plucked out during sample preparation. These regions are of different
% kinds, and grain reconstruction should treat each kind in its own way.
%
% * *Specks* are a few |notIndexed| pixels of any shape, inside a grain or
% along a boundary. They belong to the grains around them.
% * A *pore* is a hole inside one grain. The grain continues around it, and
% its area belongs to the grain.
% * A *pocket* is a compact region between several grains. It is a
% |notIndexed| grain of its own.
% * A *crack* is long compared with its width and cuts grains into pieces.
% The pieces on both sides can be parts of the same former grain.
% * A *void* touches the edge of the map, such as the border of the sample
% or a large hole. It is outside all grains.
%
% This page shows how |calcGrains| tells the kinds apart, and how each of
% them is closed with a radius of its own. It assumes the basic
% reconstruction from <GrainReconstruction.html Grain Reconstruction>, in
% particular the option |'alpha'|.

%% The data
%
% The map is a thin section of a peridotite, a mantle rock made mainly of
% olivine (forsterite), orthopyroxene (enstatite) and clinopyroxene
% (diopside). The step size is 60 micron, so the map is about 33 mm wide.
% The data are courtesy of David Mainprice, Géosciences Montpellier.

mtexdata peridotite silent

plot(ebsd,'micronbar','off')

%%
% The white regions are |notIndexed|. A crack crosses the left half of the
% map from the bottom edge to the top edge. It is wide in its lower part and
% narrow in its upper part. Round pores sit inside some of the large
% forsterite grains, irregular pockets lie between the grains, and specks
% are scattered everywhere.

%% The closing radius
%
% |calcGrains| fills every |notIndexed| region narrower than |2*alpha|
% pixels. A wider region keeps its core, and its narrow arms are filled.
% Such a core is a |notIndexed| grain of its own, a part of the one grain
% around it, or it touches the edge of the map and lies outside all grains,
% bounded by the *outer boundary* between the grains and the area no grain
% covers. Its pixels then get the |grainId| 0.
%
% We reconstruct the grains with the default |alpha| of 3.1. The second
% output is the map with the |grainId| of every pixel. We keep it apart from
% |ebsd|, so that the reconstructions below start from the measured map.

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
% The crack is a white band with a boundary along each of its two walls.
% Its pixels are outside all grains, like the regions cut by the edge of
% the map. The darkened regions are the |notIndexed| grains, pockets between
% several grains. The specks have been absorbed: they show white, without a
% boundary around them, and so do the round pores inside the forsterite
% grains.
%
% To see what |alpha| does, we repeat the reconstruction for increasing
% values and look at the half of the map with the crack. The background is
% the second output of |calcGrains|, coloured by orientation. A |notIndexed|
% pixel has no orientation and stays white, also where a grain has absorbed
% it. The boundaries show which region belongs to which grain.

alpha = [1.1 2.8 6.8 16.1];

newMtexFigure('layout',[2 2]);
for k = 1:numel(alpha)
  [grainsA,ebsdA] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
    'alpha',alpha(k));
  grainsA = smoothBoundary(grainsA);
  nextAxis
  plot(ebsdA,'ipfz','micronbar','off')
  legend off
  hold on
  plot(grainsA.boundary,'linewidth',1.5)
  hold off
  axis([0 16500 0 17940])
  mtexTitle(['alpha = ' num2str(alpha(k))])
  fprintf('alpha = %4.1f: %3d grains, %3d notIndexed, %4.1f%% outside\n', ...
    alpha(k), length(grainsA), length(grainsA('notIndexed')), ...
    100*nnz(ebsdA.grainId==0)/length(ebsdA))
end

%%
% With |alpha = 1.1| many specks between the grains remain grains of their
% own. With |alpha = 2.8| most of them are absorbed and show as white dots
% inside the grains, while the pockets and the whole crack are kept. With
% |alpha = 6.8| almost all pockets are gone. The narrow upper part of the
% crack is closed, and grains of similar orientation on its two sides have
% become one grain. The wider lower part is still open. With |alpha = 16.1|
% the grains bridge the lower part as well, along straight boundaries. Only
% its mouth at the bottom edge of the map remains outside all grains, and no
% |notIndexed| grain is left.
%
% The round pores inside the forsterite grains have no boundary of their
% own in any of the four maps. A hole inside one grain is part of that
% grain, and |calcGrains| fills it whatever its width, as the next section
% explains. The pockets have no such rule. The value that closes the crack
% also absorbs every pocket narrower than |2*alpha| into the neighbouring
% grains, whether or not it belongs there. A single radius cannot treat the
% kinds differently, since it only knows their width.

%% The kinds of notIndexed regions
%
% The regions that the closing with |alpha| leaves open differ in shape and
% in surroundings, and that is how |calcGrains| tells them apart.
%
% * A region whose longest extent is far larger than its area allows for a
% compact shape is a *crack*: the square of its longest diameter is at least
% five times its area.
% * A region touching the edge of the scan is a *void*.
% * A region whose rim is held by one orientation is a *pore*: at least 85
% percent of the indexed pixels around it are connected by the same
% criterion that |calcGrains| uses to join pixels into grains.
% * Every other region is a *pocket*.
% * A pocket or a pore joined to a crack by |notIndexed| pixels and lying
% between its pieces is part of the crack. The closing with |alpha| cuts a
% crack where it narrows, and its widenings would otherwise count as
% pockets.
%
% Of the first four rules the first that applies decides, so a crack that
% reaches the edge of the map is a crack. The command
% <EBSD.notIndexedKinds.html |notIndexedKinds|> applies these rules with the
% same |alpha| and the same threshold angle as |calcGrains|. It returns a
% kind for every pixel, with |"speck"| for the regions that |alpha| closes
% and |"indexed"| for the measured pixels. We plot the kinds over the map:
% pores blue, pockets orange, cracks red, voids black and specks grey.

kinds = notIndexedKinds(ebsd,'angle',10*degree);

color = [0.2 0.4 1; 1 0.6 0; 1 0 0; 0 0 0; 0.7 0.7 0.7];
isNotIndexed = ~ebsd.isIndexed;

plot(ebsd,'micronbar','off')
legend off
hold on
plot(ebsd(isNotIndexed),color(double(kinds(isNotIndexed)),:))
hold off

%%
% The whole crack is red, from its mouth at the bottom edge to the top edge,
% with its narrow middle and the widenings there. The narrow strip along the
% bottom right edge passes the crack test as well. The regions cut by the
% map edge are black, the pores inside the large forsterite grains are blue
% and the pockets between the grains are orange.
%
% The second output is a table with one row per region: its kind, its area
% in pixels, its longest diameter, the ratio of the two that decides on a
% crack, and the share of its rim that one orientation holds. We show the
% eight largest regions.

[~,parts] = notIndexedKinds(ebsd,'angle',10*degree);
parts = sortrows(parts,'area','descend');
disp(head(parts(:,{'kind','area','feret','elong','share'}),8))

%% A radius for each kind
%
% |calcGrains| closes every region with a radius that depends on its kind.
% The options |'alphaPore'|, |'alphaPocket'| and |'alphaCrack'| give the
% radius of the three kinds, in pixels like |alpha|. A pore or a pocket
% narrower than twice its radius is filled, a wider one keeps its core. A
% crack is bridged wherever it is narrower than twice |'alphaCrack'|. The
% value |inf| fills a kind whole, and a radius below |alpha| acts as
% |alpha|. Voids keep the radius |alpha|.
%
% By default |'alphaPore'| is |inf|, so that a pore is part of its grain,
% and the other two radii are |alpha|. We bridge the crack where it is
% narrower than 30 pixels and leave the pockets at the default radius.

[grainsK,ebsdK] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alphaCrack',15);
grainsK = smoothBoundary(grainsK);

plot(ebsdK,'ipfz','micronbar','off')
legend off
hold on
plot(grainsK.boundary,'linewidth',1.5)
plot(grainsK(~grainsK.isIndexed),'FaceColor','black','FaceAlpha',0.35)
hold off

fprintf('%d grains, %d notIndexed, %.1f%% of the map outside all grains\n', ...
  length(grainsK), length(grainsK('notIndexed')), ...
  100*nnz(ebsdK.grainId==0)/length(ebsdK))

%%
% The grains reach across the whole crack, and no |notIndexed| grain is left
% in it. The pockets elsewhere are kept as the darkened grains. Only the
% voids at the edge of the map and the mouth of the crack, wider than 30
% pixels, remain outside all grains.

%% Grains across the crack
%
% Bridging the crack connects the grains on its two sides. Where both sides
% have nearly the same orientation, they become one grain. Where they
% differ by more than the threshold angle, a new boundary runs through the
% crack.
%
% We compare the grains with the crack bridged to the default ones. The
% pixels of the crack are outside all grains by default, and inside one with
% |'alphaCrack',15|.

inCrack = ebsdGrains.grainId == 0 & ebsdK.grainId > 0;

%%
% For each grain that covers a part of the crack, we count how many of its
% pixels belong to each of the default grains. Two default grains with more
% than 200 pixels each are the two pieces of a grain that the crack cut.

isJoined = false(size(grainsK));
for id = unique(ebsdK.grainId(inCrack)).'
  [pieces,~,j] = unique(ebsdGrains.grainId(ebsdK.grainId == id & ...
    ebsdGrains.isIndexed));
  pieces = pieces(accumarray(j,1) > 200);
  if numel(pieces) < 2, continue, end
  isJoined(grainsK.id2ind(id)) = true;
  fprintf('%s: two pieces with misorientation %.1f°\n', ...
    grainsK('id',id).mineral, ...
    angle(grains('id',pieces(1)).meanOrientation, ...
    grains('id',pieces(2)).meanOrientation) / degree)
end

%%
% The joined pieces differ by less than five degrees. They are therefore
% parts of single forsterite grains which the crack cut in two. We highlight
% them on the map, with the default grain boundaries in red.

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grains.boundary,'linewidth',1,'LineColor','r')
plot(grainsK(isJoined),'FaceColor','black','FaceAlpha',0.4)
plot(grainsK.boundary,'linewidth',1)
hold off
axis([2500 12500 7000 17940])

%%
% The darkened grains extend across the crack, which shows through them as a
% lighter band. The other grains along the crack meet their neighbour from
% the other side at a boundary inside the crack. Those boundaries are not
% measured. |calcGrains| draws each of them as a straight line between the
% points where it meets the two walls of the crack, the shortest boundary
% the bridged crack allows.
%
% How a boundary crosses a closed |notIndexed| region is set by the option
% |'straighten'|, which is |true| by default. With |'straighten',false| the
% boundaries follow the bisectors between the measured pixels on either side.

grainsNoSt = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alphaCrack',15,'straighten',false);

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grains.boundary,'linewidth',1,'LineColor','r')
plot(grainsNoSt(isJoined),'FaceColor','black','FaceAlpha',0.4)
plot(grainsNoSt.boundary,'linewidth',1)
hold off
axis([2500 12500 7000 17940])

%%
% The boundaries crossing the crack now have kinks, where in the previous map
% they run straight from one wall of the crack to the other. A kinked
% boundary through an unmeasured region is rarely the physically most
% reasonable one.

%% Correcting the kinds
%
% The rules above read the shape and the surroundings of a region, and they
% can be wrong for a map. The strip along the bottom right edge is long and
% narrow enough to pass the crack test, yet it is the rim of a region
% plucked out of the specimen, a void. |kinds| is a categorical array with
% one entry per pixel, so it can be edited and handed back to |calcGrains|
% with the option |'kinds'|. Every region then takes the kind that its
% pixels say. We mark the strip as a void and plot the bottom right corner
% of the kinds map before and after.

kindsEdited = kinds;
isStrip = kinds(:) == "crack" & ebsd.x(:) > 20000;
kindsEdited(isStrip) = "void";

newMtexFigure('layout',[1 2]);
for v = {kinds, kindsEdited}
  nextAxis
  plot(ebsd,'micronbar','off')
  legend off
  hold on
  plot(ebsd(isNotIndexed),color(double(v{1}(isNotIndexed)),:))
  hold off
  axis([24500 29500 14000 17940])
end

%%
% The strip is red on the left and black on the right, like the plucked
% region beside it. The reconstruction with the edited kinds no longer
% bridges it.

[grainsEdited,ebsdEdited] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alphaCrack',15,'kinds',kindsEdited);

fprintf('%d of the %d pixels of the strip are outside all grains, %d as a crack\n', ...
  nnz(isStrip & ebsdEdited.grainId(:) == 0), nnz(isStrip), ...
  nnz(isStrip & ebsdK.grainId(:) == 0))

%% Pores as grains
%
% To measure the pores, reconstruct with |'alphaPore',0|. A pore is then a
% |notIndexed| grain enclosed by a single grain, which
% <grain2d.isInclusion.html |isInclusion|> finds, with the area and the
% shape of any grain.

grainsP = calcGrains(ebsd,'angle',10*degree,'minPixel',5,'alphaPore',0);

isPore = grainsP.isInclusion & ~grainsP.isIndexed;
fprintf('%d pores with a mean area of %.0f pixels\n', ...
  nnz(isPore), mean(grainsP(isPore).numPixel))

%%
% Afterwards <grain2d.merge.html |merge|> with the option |'inclusions'|
% merges every inclusion into the grain that encloses it. A second argument
% restricts it to |notIndexed| inclusions, so that indexed inclusions such
% as the small chromite grains remain grains of their own. Merging reads
% what encloses a region and not its shape, so it takes the pockets inside
% deformed grains along with the pores.

[grainsMerged,parentId] = merge(grainsP,'inclusions',~grainsP.isIndexed);

plot(grainsMerged,'micronbar','off')

%%
% The round pores inside the forsterite grains are gone, while the crack and
% the pockets between several grains are kept. |parentId| gives for every
% original grain the id of the grain it is now part of. The area of a merged
% grain includes its pores. Here they are a small part of it.

poreIds = grainsP.id(isPore);
hostArea = grainsMerged('id',parentId(grainsP.id2ind(poreIds))).area;
poreArea = grainsP('id',poreIds).area;
fprintf('the pores make up %.1f%% of the area of their host grains\n', ...
  100*sum(poreArea)/sum(hostArea))

%% Smoothing the outer boundary
%
% A crack or a pocket at the map border is bounded by the outer boundary. It
% has the same pixel staircase as every other boundary. The command
% <grain2d.smoothBoundary.html |smoothBoundary|> smooths it together with the
% grain boundaries. Junctions on the outer boundary, where a grain boundary
% meets it, and the corners of its convex hull stay where they are. The map
% therefore keeps its extent.

grainsSmooth = smoothBoundary(grainsMerged);

plot(grainsSmooth,'micronbar','off')

%%
% The edges of the crack and of the voids at the bottom right are now smooth
% curves, just like the grain boundaries.

%% Recommended procedure
%
% A map with cracks and pores is best reconstructed in four steps.
%
% # Choose |alpha| for the specks between the grains. The default is usually
% right.
% # Look at the kinds with |notIndexedKinds|, and correct the regions that
% are of another kind than the rules say.
% # Set |'alphaCrack'| to half the width up to which a crack should be
% bridged, if the grains on its two sides should be counted as one. Pores
% are part of their grains by default, and pockets stay |notIndexed| grains
% with the default radius.
% # Smooth all boundaries with |smoothBoundary|.
%
% A large |alpha| closes a crack as well, but also every pocket narrower
% than |2*alpha|, whether or not it belongs to a grain.

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
% criteria, such as a twin relationship.
% <GrainSmoothing.html Grain Boundary Smoothing> compares the smoothing
% filters. To estimate orientations inside pores and
% cracks rather than only assigning them to grains, see
% <EBSDFilling.html Fill Missing Data in Orientation Maps>.
