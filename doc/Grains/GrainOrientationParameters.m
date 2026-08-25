%% Grain Orientation Parameters
%
%%
% A grain is not one orientation but a few thousand of them that happen to
% lie close together. The parameters on this page describe that cloud: where
% its centre is, how wide it is, and whether it is spread out along a
% particular direction rather than in all directions equally.
%
% || |meanOrientation| || mean orientation || |GOS| || grain orientation spread ||
% || |GAM| || grain average misorientation || |GAX| || grain average misorientation axis ||
%
% The example is a ferrite map, where the deformation has left orientation
% gradients inside the grains.

% import the data
mtexdata ferrite silent

% compute grains
[grains, ebsd] = calcGrains(ebsd,'threshold',7.5*degree,'minPixel',5);
ebsd = ebsd.project2FundamentalRegion;
grains = smoothBoundary(grains,5);

% plot the data
plot(ebsd, ebsd.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% The mean orientation
%
% The orientations that make up a grain are reached through |ebsd.grainId|,
% which the reconstruction wrote into the map - see
% <SelectingGrains.html Selecting Grains>.

% select a grain by x and y coordinates
grainSel = grains(42,17)

% all EBSD orientations within the grain
ori = ebsd(grainSel).orientations

%%
% Their <orientation.mean.html |mean|> is what |grains.meanOrientation|
% holds; the reconstruction computed it once, so there is no reason to
% compute it again.

plot(grains, grains.meanOrientation,'micronbar','off')

%% Deviation from the mean
%
% With a reference orientation per grain, every measurement can be described
% by how far it departs from it. That departure is a
% <MisorientationTheory.html misorientation>, and it is called the grain
% reference orientation deviation, GROD.

mis2mean = inv(grainSel.meanOrientation) .* ori

%%
% <EBSD.calcGROD.html |calcGROD|> does the same for the whole map at once.

mis2mean = calcGROD(ebsd, grains)

%% Grain orientation spread
%
% A misorientation is three numbers, which is more than one wants when
% comparing grains. Averaging only its angle over a grain gives the grain
% orientation spread, GOS, in degrees. <EBSD.grainMean.html |grainMean|>
% averages any per-measurement quantity over grains.

% take the average of the misorientation angles for each grain
GOS = ebsd.grainMean(mis2mean.angle, grains);

% plot it
plot(grains, GOS ./ degree,'micronbar','off')
mtexColorbar('title','GOS in degree')

%%
% The same number is available as |grains.GOS| without computing it. Grains
% that are uniform inside are dark; the ones that carry a gradient stand
% out, and it is those that the rest of this page is about.
%
% |grainMean| takes a function as a further argument, so the same
% calculation with |@max| gives the largest deviation in each grain rather
% than the average one. Any other statistic - a median, a quantile - works
% the same way.

% compute the maximum misorientation angles for each grain
MGOS = ebsd.grainMean(mis2mean.angle, grains, @max);

% plot it
plot(grains, MGOS ./ degree,'micronbar','off')
mtexColorbar('title','MGOS in degree')

%% Grain average misorientation
%
% The GOS compares every measurement with the mean of its grain, so it grows
% with any gradient however gentle, as long as the grain is large enough.
% The grain average misorientation, GAM, compares each measurement with its
% immediate neighbours instead - it is the
% <EBSDKAM.html kernel average misorientation> averaged over the grain.

gam = ebsd.grainMean(ebsd.KAM, grains);

plot(grains,gam./degree,'micronbar','off')
mtexColorbar('title','GAM in degree')
setColorRange([0,3])

%%
% The two maps do not agree, and they are not meant to. GOS measures the
% total orientation change across a grain, GAM the steepness of the local
% gradient: a grain bent smoothly from one side to the other scores high on
% GOS and low on GAM, whereas one containing a subgrain boundary scores high
% on GAM. The two are regularly confused in the literature.

%% The crystal dispersion axis
%
% If deformation is carried by slip on one dominant system, the orientations
% inside a grain do not scatter in all directions: they line up along a
% curve in orientation space, and the axis of that curve says something about
% the slip system that produced it. Such a curve is a
% <OrientationFibre.html fibre>, and <fibre.fit.html |fibre.fit|> finds the
% one that fits a list of orientations best.

% visualize the orientations within the selected  grain in a pole figure
figure(2)
h = Miller({1,0,0},ebsd.CS);
plotPDF(ebsd(grainSel).orientations,h,'MarkerSize',2,'all')

% fit a fibre to the orientations within the grain
[f,lambda,fit] = fibre.fit(ebsd(grainSel).orientations,'local');

% add the fibre to the pole figure
hold on
plotPDF(f.symmetrise,h,'lineColor','orange','linewidth',2)
hold off

%%
% The orientations of this grain lie in short streaks rather than in blobs,
% and the orange fibre follows them. Its axis is available in specimen
% coordinates as |f.r| and in crystal coordinates as |f.h|.

f.r
f.h

%%
% A rotation about that axis leaves the axis itself where it is, so the one
% crystal direction that does not scatter is |f.h|. Adding it to the pole
% figure shows exactly that: a tight cluster where everything else is
% smeared.

hold on
plot(ebsd(grainSel).orientations.*f.h,'MarkerSize',2,'all',...
  'MarkerFaceColor','k','antipodal','micronbar','off')
hold off

%%
% The second output of |fibre.fit| are the four eigenvalues of the
% orientation matrix, in ascending order. The largest says how concentrated
% the orientations are, the second largest how far they run along the fitted
% fibre, and the two smallest how far they scatter off it. The third output
% puts that scatter in degrees: it is the mean angle between the
% orientations and the fibre.

lambda

fit./degree

%%
% Repeating this for every grain large enough to say something about takes a
% loop, since each grain is fitted on its own.

grainsLarge = grains(grains.isIndexed & grains.numPixel > 50);
lambda = nan(length(grainsLarge),4);

% loop through all grains
for k = 1:length(grainsLarge)

  % fit a fibre
  [f,lambda(k,:),fit(k)] = fibre.fit(ebsd(grainsLarge(k)).orientations,'local');

  % store the misorientation axes in crystal and specimen symmetry
  GAX_C(k) = f.h; %#ok<*SAGROW>
  GAX_S(k) = f.r;

end

%%
% The fit and the two middle eigenvalues describe how fibre-like a grain is
% at all, which decides whether its axis is worth looking at.

plot(grainsLarge,lambda(:,3),'micronbar','off')
mtexTitle('$\lambda_3$')

nextAxis(1,2)
plot(grainsLarge,lambda(:,2),'micronbar','off')
mtexTitle('$\lambda_2$')

nextAxis(1,3)
plot(grainsLarge,fit./degree,'micronbar','off')
mtexTitle('fit')

%%
% The eigenvalues are returned in ascending order, so $\lambda_3$ here is the
% second largest - how far the orientations run along the fibre - and
% $\lambda_2$ the third largest, how far they scatter off it. The fit map is
% the $\lambda_2$ map again: across these 161 grains the two correlate at
% 0.92, while the fit and $\lambda_3$ correlate at only 0.61. That is as it
% should be, the fit being a measure of the scatter off the fibre and
% nothing else.
%
% A grain worth reading a dispersion axis from is therefore one with a large
% $\lambda_3$ and a small $\lambda_2$. The fit angles here run from 0.25 to
% 2.2 degrees.
%
% *In crystal coordinates*
%
% The axes are crystal directions, so a colour key for directions displays
% them. <HSVDirectionKey.html |HSVDirectionKey|> builds one, and it needs
% |'antipodal'|, since an axis and its negative are the same axis.

% define the color key
cKey = HSVDirectionKey(ebsd.CS,'antipodal');

% plot the color key and on top the dispersion axes
plot(cKey)
hold on
plot(GAX_C.project2FundamentalRegion,'MarkerFaceColor','black')
hold off

%%
% The dots cover the sector rather than gathering anywhere in it, so on this
% map the dispersion axes prefer no particular crystal direction. In a
% material deforming on one dominant slip system they would cluster, and
% that is what this figure is for - the same colours on the map below then
% show which grains share an axis.

% compute colors from the misorientation axes
color = cKey.direction2color(GAX_C);

% plot the colored grains
plot(grainsLarge, color,'micronbar','off')

%%
% *In specimen coordinates*
%
% There is no colour key for directions in specimen coordinates - one cannot
% colour a whole sphere without a jump somewhere. MTEX draws them as compass
% needles instead: grey for a direction lying in the plane of the map, and
% split into a black and a white half to show which end points out of it.

plot(grains, GOS./degree,'micronbar','off')
mtexColorbar('title','GOS in degree')

hold on
plot(grainsLarge, GAX_S,'micronbar','off')
hold off

%%
% What one hopes to see here is an alignment, because in many materials the
% dispersion axes relate directly to the flow. Under simple shear they tend
% to align with the vorticity axis; under pure shear they form a girdle
% whose normal is the shortening direction. Plotted together in one pole
% figure:

plot(GAX_S,'antipodal','MarkerSize',4)

%%
% Contours make a preference easier to judge than a scatter of dots. The
% weights are the fits, so that the grains whose axis is well defined count
% for more.

hold on
plot(GAX_S,'contour','antipodal','weights', fit,'contours',[1 2 3],'halfwidth',10*degree,'linewidth',2)
hold off

%%
% This map gives no clean answer. The dots fill the whole projection, and
% the contours reach 3 only in two small spots, one on the rim near X and
% one in the lower left. Neither a vorticity axis nor a girdle, in other
% words - which is a fair outcome to report rather than to hide. It is a
% piece of steel rather than a sheared rock, and only 161 grains are large
% enough to enter the calculation at all.

%#ok<*NASGU>
%#ok<*NOPTS>
