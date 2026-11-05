%% Cracks and Pores
%
%%
% A map of a natural rock or a sintered material rarely consists of grains
% alone. Wherever a pattern could not be indexed, the map is |notIndexed|.
% On a specimen surface that happens at cracks, at pores and where material
% was plucked out during sample preparation. These regions are of different
% kinds, and grain reconstruction should treat them differently.
%
% * A *pore* inside a grain is a hole in that grain. The grain continues
% around it, and its area belongs to the grain.
% * A transgranular *crack* that opened after the material formed, cuts
% grains into pieces. The pieces on both sides of the crack can be parts of 
% the same former grain.
% * A wide region with no indexed material, such as the border of a sample
% or a large void, is not part of any grain.
%
% This page shows how |calcGrains| treats each of them, and which options
% give control over the result. It assumes the basic reconstruction from
% <GrainReconstruction.html Grain Reconstruction>, in particular the option
% |'alpha'|.

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
% forsterite grains, and irregular pockets lie between the grains.

%% Pores, pockets and the outer boundary
%
% We reconstruct the grains with the default |alpha|, which closes
% |notIndexed| regions narrower than about six pixels. The second output is
% the map with the |grainId| of every pixel. We keep it apart from |ebsd|, so
% that the reconstructions below start from the measured map.

[grains,ebsdGrains] = calcGrains(ebsd,'angle',10*degree,'minPixel',5);

%%
% Every |notIndexed| region that survives the closing is either a
% |notIndexed| grain, or it touches the border of the map and lies outside
% all grains. Such a region is bounded by the *outer boundary*: the boundary
% between the grains and the area not covered by any grain. Its pixels get
% the |grainId| 0.
%
% A |notIndexed| grain enclosed by a single grain is an intragranular pore 
% of that grain. The command <grain2d.isInclusion.html |isInclusion|> finds 
% them.

isPore = grains.isInclusion & ~grains.isIndexed;
isPocket = ~grains.isIndexed & ~isPore;

plot(grains,'micronbar','off')
hold on
plot(grains(isPore),'FaceColor','red','DisplayName','pore')
plot(grains(isPocket),'FaceColor','black','DisplayName','pocket')
hold off

%%
% Red marks the |notIndexed| grains enclosed by one grain, and black those
% between several grains. The crack is white. It reaches the border of the
% map and is therefore outside all grains. The grains on its two sides do not
% touch, and so they are never compared. The closing has bridged the crack
% only in its middle, where it is narrowest.

fprintf('%d pores, %d pockets, %.1f%% of the map outside all grains\n', ...
  nnz(isPore), nnz(isPocket), 100*nnz(ebsdGrains.grainId==0)/length(ebsd))

%% The effect of alpha
%
% A larger |alpha| closes wider |notIndexed| regions. We repeat the
% reconstruction for increasing values, and look at the lower part of the
% crack. The background is the second output of |calcGrains|, coloured by
% orientation. A |notIndexed| pixel has no orientation and stays white, also
% where a grain has absorbed it. The boundaries show which region belongs to
% which grain. 

alpha = [1.1 2.1 6.1 16.1];

newMtexFigure('layout',[2 2]);
for k = 1:numel(alpha)
  [grainsA,ebsdA] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
    'alpha',alpha(k));
  grainsA = smoothBoundary(grainsA);
  nextAxis
  plot(ebsdA,'ipfz','micronbar','off')
  %plot(grainsA,'ipfz','micronbar','off')
  legend off
  hold on
  plot(grainsA.boundary,'linewidth',1.5)
  hold off
  axis([2500 12500 7000 17940])
  mtexTitle(['alpha = ' num2str(alpha(k))])
  fprintf('alpha = %4.1f: %3d grains, %3d notIndexed, %4.1f%% outside\n', ...
    alpha(k), length(grainsA), length(grainsA('notIndexed')), ...
    100*nnz(ebsdA.grainId==0)/length(ebsdA))
end

%%
% With |alpha = 1.1| many |notIndexed| specks between the grains remain
% grains of their own. With |alpha = 2.1| most of those specks are absorbed,
% while the larger pores, the pockets and the crack are kept. With |alpha = 6.1|
% the pores and almost all pockets of the map are gone. The narrow upper part 
% of the crack is closed, with a common boundary connecting the sufficiently 
% similar indexed areas across the crack. The wider lower part is still open.
% With |alpha = 16.1| the grains bridge the lower part as well. Only its
% mouth at the bottom edge of the map remains outside all grains, and no 
% |notIndexed| grain is left.
%
% No single |alpha| value treats all regions as we would like. The value 
% that closes the crack also absorbs every pore and pocket of the map into
% the neighbouring grains, whether or not they belong there.
%
% Note that the direction of the boundary inside a |notIndexed| region
% depends on the distance to the indexed region and is not necessarily the
% shortest connection between the two opposing parts on each crack side. 

%% Grains across the crack
%
% Closing the crack connects the grains on its two sides. Where both sides
% have nearly the same orientation, they become one grain. Where they
% differ by more than the threshold angle, a new boundary runs through the
% crack.
%
% We compare the grains with |alpha = 10| to the default ones. The pixels of
% the crack are outside all grains by default, and inside one with
% |alpha = 10|.

[grains10,ebsd10] = calcGrains(ebsd,'angle',10*degree,'minPixel',5, ...
  'alpha',10);

inCrack = ebsdGrains.grainId == 0 & ebsd10.grainId > 0;

%%
% For each grain that covers a part of the crack, we count how many of its
% pixels belong to each of the default grains. Two default grains with more
% than 200 pixels each are the two pieces of a grain that the crack cut.

isJoined = false(size(grains10));
for id = unique(ebsd10.grainId(inCrack)).'
  [pieces,~,j] = unique(ebsdGrains.grainId(ebsd10.grainId == id & ...
    ebsdGrains.isIndexed));
  pieces = pieces(accumarray(j,1) > 200);
  if numel(pieces) < 2, continue, end
  isJoined(grains10.id2ind(id)) = true;
  fprintf('%s: two pieces with misorientation %.1f°\n', ...
    grains10('id',id).mineral, angle(grains('id',pieces(1)).meanOrientation, ...
    grains('id',pieces(2)).meanOrientation) / degree)
end

%%
% The joined pieces differ by less than two degrees. They are therefore parts
% of single forsterite grains which the crack cut in two. We highlight them
% on the map. We also plot the default grain boundaries in red.

plot(ebsd,'micronbar','off')
legend off
hold on
plot(grains.boundary,'linewidth',1,'LineColor','r')
plot(grains10(isJoined),'FaceColor','black','FaceAlpha',0.4)
plot(grains10.boundary,'linewidth',1)
hold off
axis([2500 12500 7000 17940])

%%
% The darkened grains extend across the crack, which shows through them as a
% lighter band. The other grains along the closed part of the crack meet
% their neighbour from the other side at a boundary inside the crack. Those
% boundaries are not measured. |calcGrains| draws each of them as a straight
% line between the points where it meets the two walls of the crack, the
% shortest boundary the closed crack allows. With the option
% |'straighten',false| they follow the bisectors between the measured pixels
% on either side instead. The wide lower part of the crack remains open.
% The red boundaries are those of the default grains. You can see at the
% top-right corner, that the crack was already closed there, since the crack
% was locally narrower than the 6 pixel wide default.

%% Pores as part of their grain
%
% A pore does not need a large |alpha| to become part of its grain. The
% command <grain2d.merge.html |merge|> with the option |'inclusions'| merges
% every inclusion into the grain that encloses it. A second argument
% restricts it to |notIndexed| inclusions, so that indexed inclusions such as
% the small chromite grains remain grains of their own.

[grainsMerged,parentId] = merge(grains,'inclusions',~grains.isIndexed);

plot(grainsMerged,'micronbar','off')

%%
% The round pores inside the forsterite grains are gone, while the crack and
% the pockets between several grains are kept. Merging acts on what encloses
% a region and not on its width. It therefore merges pores of any size,
% while the crack stays open.
%
% |parentId| gives for every original grain the id of the grain it is now
% part of. The area of a merged grain includes its pores. Here they are a
% small part of it.

poreIds = grains.id(isPore);
hostArea = grainsMerged('id',parentId(grains.id2ind(poreIds))).area;
poreArea = grains('id',poreIds).area;
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
% The edges of the cracks and of the region at the bottom right are now
% smooth curves, just like the grain boundaries.

%% Recommended procedure
%
% A map with cracks and pores is best reconstructed in three steps.
%
% # Choose |alpha| for the specks between the grains. The default is usually
% right. Check that the cracks you want to keep remain open.
% # Merge |notIndexed| inclusions into the enclosing grains with
% |merge(grains,'inclusions',~grains.isIndexed)|.
% # Smooth all boundaries with |smoothBoundary|.
%
% Close a crack with a large |alpha| only if the grains on its two sides
% should be counted as one, and accept that this also closes all smaller
% regions of the map.

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
