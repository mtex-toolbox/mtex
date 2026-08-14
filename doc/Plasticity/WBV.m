%% Weighted Burgers Vector Analysis
%
% The "Weighted Burgers Vector" is a method to analyze geometrically
% necessary dislocations from EBSD maps, complementary (or alternatively)
% to <GND.html GND analysis>. The reference description is in
% <https://doi.org/10.1111/j.1365-2818.2009.03136.x Wheeler et. al., The weighted
% Burgers vector: a new quantity for constraining dislocation densities and
% types using electron backscatter diffraction on 2D sections through
% crystalline materials>
%
% The "Weighted Burgers Vector" is a moving window technique interpreting
% the orientation gradient in a given neighborhood and at a given distance
% to be caused by dislocation lines which crosscut the observation surface.
% It is weighted/biased by the cosine of the angle between the map-normal
% the dislocation line direction.
%
% In MTEX the weighted Burgers vector is computed by the function
% <EBSD.weightedBurgersVec.html |ebsd.weightedBurgersVec|>, which offers two
% methods. This page is in two parts, one for each.
%
% The *integral method* is the default. It derives the WBV from the
% orientation gradient in x- and y- direction, obtained using a convolution
% kernel similar to a Prewitt operator, except that the corners are weighted
% by 0.5. This is comparable to what is termed the "integral method" by
% other implementations. The size of the kernel can be adjusted in order to
% cope with noisy data.
%
% The *gradient method* derives the WBV from the last column of the
% <curvatureTensor.dislocationDensity.html dislocation density tensor>.
% It resolves finer detail, but it differentiates the data directly and so
% amplifies whatever noise is in it - high angular resolution EBSD data, or
% denoising prior to the analysis, is required. Which neighbours enter that
% derivative can be chosen, and that choice is what the second half of this
% page is about.
%
%%
% We start by importing the same data as for the <GND.html GND example>.

% import the EBSD data
mtexdata single

%%
% We reconstruct grains because later on, we do not want to compute the WBV
% across grain boundaries

[grains,ebsd] = calcGrains(ebsd,'angle',2.5*degree,'minPixel',6);

% we will use the noisy data later on
ebsdN = ebsd;

% denoise the data
F = halfQuadraticFilter;
ebsd = smooth(ebsd,F,'fill',grains);

%% Part 1: the integral method
% The default integral method is a moving window over the map, so it needs
% the data in matrix form. Our map already is - that is how it was imported,
% see <EBSDGrid.html Square and Hex Grids> - and for a map that is not,
% <EBSD.gridify.html |gridify|> is called internally. The gradient method in
% part 2 has no such requirement, see there.

wbv = weightedBurgersVec(ebsd)

%%
% The WBV is returned in specimen coordinates as a list of @vector3d. We
% can inspect its magnitude (in 1/scanunit) and direction.

plot(ebsd,wbv.norm,'refFrame','on')
mtexColorbar
mtexTitle('WBV magnitude')

%% Visualizing the WBV
% In order to visualize the direction of the WBV in specimen coordinates,
% we can use a directional color key.

cK = HSVDirectionKey(wbv);
plot(ebsd,cK.direction2color(wbv),'FaceAlpha',wbv.norm/0.22)
mtexTitle('WBV in specimen coordinates')

nextAxis
plot(cK,'figSize','tiny')
mtexTitle('directional color key')

%%
% We could also display the WBV as small arrows. If we allow for any
% magnitude, the plot would become quite cluttered. Hence, we will only
% display those vectors which have a reasonably large magnitude.
% Next to it we plot the distributions of WBV in a spherical projection. 

cond = wbv.norm > quantile(wbv.norm,0.85);

plot(ebsd,cK.direction2color(wbv),'FaceAlpha',wbv.norm/0.22)
hold on
quiver(ebsd(cond),wbv(cond),'color','k','autoScaleFactor', 2, 'antipodal','linewidth',0.5);
hold off
mtexTitle('WBV in specimen coordinates')

nextAxis
plot(wbv,'weights',wbv.norm,'contourf')
mtexTitle('WBV density distribution')

%% The WBV in crystal coordinates
% In order to inspect the WBV in crystal coordinates we transform them
% using the orientations and choose a fitting directional color key

% transform to crystal reference frame
wbvC = inv(ebsd.orientations) .* wbv;

% define a directional color key respecting crystal symmetry
cKC = HSVDirectionKey(wbvC);

% plot the data
plot(ebsd,cKC.direction2color(wbvC),'FaceAlpha',wbv.norm/0.22)
mtexTitle('WBV in crystal coordinates')

% plot the color key
nextAxis
plot(cKC)
mtexTitle('directional color key')

% overlaid with the contour lines of its density distribution
hold on
plot(wbvC,'weights',wbvC.norm,'contour', ...
    'contours',0.2:0.1:2,'linecolor','k','ShowText','on', ...
    'linewidth',2)
hold off

%% Effect of windowSize
% In case there are reasons why the EBSD data cannot be denoised, the WBV
% can also be computed with respect to a larger neighborhood. The integer
% specified with with |'windowSize'| gives a 2*n+1 square across which the
% WBV is computed. The default is a 3-by-3 box.

close all
newMtexFigure('layout',[2,4])

% first we plot again the WBV form the denoised dataset
wbv = weightedBurgersVec(ebsd);
nextAxis(1,1)
plot(ebsd,wbv.norm); hold on
mtexTitle('WBV norm (denoised) / box = 3')

nextAxis(2,1)
plot(wbv,'weights',wbv.norm,'contourf','antipodal')
mtexTitle('density distribution')

% next we plot the WBV form the noisy dataset

for ws = [1 2 3]

  wbv = weightedBurgersVec(ebsdN,'windowSize',ws);
  nextAxis(1,ws+1)
  plot(ebsdN,wbv.norm); hold on
  mtexTitle(['WBV norm / box =' num2str(2*ws+1)])

  nextAxis(2,ws+1)
  plot(wbv,'weights',wbv.norm,'contourf','antipodal')
  mtexTitle('density distribution')

end
mtexColorbar

%%
% Here we see that there is some difference between the noisy and the
% denoised data in a 3-by-3 and larger neighborhoods. For larger window
% sizes, we see that there is of course a loss of detail (and empty spaces
% appear around unfilled points) and a decrease in the norm of WBV, since
% high orientation gradients are spread by the larger window size. At the
% other hand, the distribution of the WBV in the pole figures becomes
% sharper, because there is less scatter in the WBV over larger areas.

%% Part 2: the gradient method
% The second method takes the WBV from the last column of the dislocation
% density tensor, i.e. from the <EBSD.curvature.html curvature tensor> and
% ultimately from <EBSD.gradient.html |ebsd.gradient|>. Unlike the integral
% method it is computed on the virtual lattice and needs no grid at all - it
% works on a plain @EBSD, on a phase subset, on rotated or sheared grids,
% and on maps that do not lie in the xy plane. |ebsd| happens to be
% gridified here, which changes nothing.
%
% We use the *denoised* map throughout this part. Differentiating a noisy
% map point by point is exactly what this method must not be given.

wbv = weightedBurgersVec(ebsd,'gradient');

close all
cK = HSVDirectionKey(wbv);
plot(ebsd,cK.direction2color(wbv),'FaceAlpha',wbv.norm/0.2)
mtexTitle('WBV in specimen coordinates' )

nextAxis(1,2) 

plot(wbv,'weights',wbv.norm,'antipodal','contourf')
mtexTitle('density distribution')

%%
% Comparing this with the map from part 1 we observe that for denoised data
% the gradient based method results in a more detailed map.

%% Choosing the stencil
% Which neighbours enter the derivative is selected with the |'stencil'|
% option, passed straight through to <EBSD.gradient.html |ebsd.gradient|>.
% There are three choices, and they trade detail against robustness in the
% same way |'windowSize'| does for the integral method - only at the scale
% of a single pixel.
%
% * |'oneSided'| (the default) uses the neighbour in +a1 and +a2 only,
% falling back to the other side just at the border of the map. It is a
% forward difference: the most local answer, and the noisiest.
% * |'1hop'| fits the gradient by least squares over the lattice's own
% neighbourhood - the 4 axial neighbours of a square grid, the 6 neighbours
% of a hexagonal one. In the interior of a square map that is exactly the
% central difference.
% * |'full'| fits over all eight surrounding pixels, i.e. the 1-hop
% neighbours plus the diagonals. Most averaging, and best conditioned: a
% pixel needs two independent neighbour directions before the gradient is
% defined at all, so the wider stencil also leaves fewer holes. That last
% point does not show on this map, which is dense and single phase - it
% matters on maps broken up by notIndexed regions, phase boundaries or grain
% boundaries, where the three stencils can differ by a factor of twenty in
% how many pixels they define the gradient at.
%
% The default is |'oneSided'| so that existing numbers do not move. Let us
% compute all three on the denoised map.

stencils = {'oneSided','1hop','full'};

close all
newMtexFigure('layout',[2,3])

for k = 1:3

  wbv = weightedBurgersVec(ebsd,'gradient','stencil',stencils{k});

  nextAxis(1,k)
  plot(ebsd,wbv.norm)
  mtexTitle(['WBV norm / ' stencils{k}])
  
  nextAxis(2,k)
  plot(wbv,'weights',wbv.norm,'contourf','antipodal')
  mtexTitle('density distribution')

end
mtexColorbar

%%
% The three maps show the same structures, but progressively smoothed. The
% effect is easiest to read off the extremes rather than the mean, since
% widening the stencil averages the sharpest gradients away first.

for k = 1:3
  wbv = weightedBurgersVec(ebsd,'gradient','stencil',stencils{k});
  notNan = ~isnan(wbv);
  fprintf('%-9s  defined at %d of %d pixels,  mean |W| = %.4f,  max |W| = %.4f\n',...
    stencils{k}, nnz(notNan), numel(wbv), mean(wbv(notNan).norm), max(wbv(notNan).norm));
end

%%
% The mean barely moves - 0.029 to 0.027 - while the maximum drops by half,
% which says the stencil is acting on the sharpest gradients and leaving the
% bulk of the map alone. Whether that is noise being removed or structure
% being lost is a question about the data, not about the method.
%
% So the choice is the familiar one between locality and noise. |'oneSided'|
% keeps the sharpest features and the largest magnitudes, but a forward
% difference over one pixel is the least robust estimator of a derivative
% there is. |'full'| is the most stable, at the price of smoothing genuine
% short range structure. |'1hop'| sits between the two and is symmetric,
% which |'oneSided'| is not.
%
% Note that this is a different knob from |'windowSize'| in part 1, even
% though both trade detail for stability. |'windowSize'| enlarges the
% integration loop and can be pushed to 5-by-5, 7-by-7 and beyond to cope
% with genuinely noisy data; the stencil only ever reaches the immediate
% neighbours of a pixel. If your data is noisy enough that |'full'| is not
% sufficient, denoise it or use the integral method, rather than expecting
% the stencil to make up the difference.
