%% Weighted Burgers Vector Analysis

% The "Weighted Burgers Vector" is another method to analyse geometrically
% necessary dislocations from EBSD maps, complementary (or alternatively) 
% to the approach described <GND.html|here|>.

% The reference description can be found here:
% <https://doi.org/10.1111/j.1365-2818.2009.03136.x Wheeler et. al., The weighted 
% Burgers vector: a new quantity for constraining dislocation densities and 
% types using electron backscatter diffraction on 2D sections through
% crystalline materials>

% It is a moving window technique interpreting the orientation
% gradient in a given neighborhood and at a given distance to be caused by
% dislocation lines which crosscut the observation surface. It is 
% weighted/biased by the cosine of the angle between the map-normal 
% the dislocation line direction.

% The implementation in Mtex allows for two different methods. The default 
% method is derived from the orientation gradient in x- and -y directions,
% obtained using a convolution kernel similar to a Prewitt operator, except
% that the corners are weighted by 0.5. This is comparable what is termed
% the "integral method" by other implementations. Here the size of kernel
% can be adjusted in order to cope with noisy data. Alternatively, there is
% the "gradient" method, where the WBV is simply derived from the last 
% column of the <curvatureTensor.dislocationDensity.html|dislocation density tensor|>
% (see <GND.html>). Currently the gradient is only derived from the nearest
% neighbor pixels.



%%
% In this section we want to see how we can generall use the 
% <EBSD.weightedBurgersVec.html|WBV|> function. We will use the same data
% as in the <GND.html> demonstration.

% set up the plotting convention and preference
plotx2east
setMTEXpref('showMicronBar',0)

% import the EBSD data
% mtexdata single
CS = crystalSymmetry('Fm3m',[4.04958 4.04958 4.04958],'mineral','Al');
ebsd = EBSD.load([mtexDataPath filesep 'EBSD' filesep 'single_grain_aluminum.txt'],...
    'CS', CS,'RADIANS','ColumnNames', { 'Euler 1' 'Euler 2' 'Euler 3' 'x' 'y'},...
    'Columns', [1 2 3 4 5]);

% define the color key
ipfKey = ipfHSVKey(ebsd);
ipfKey.inversePoleFigureDirection = yvector;

% and plot the orientation data
plot(ebsd,ipfKey.orientation2color(ebsd.orientations),'micronBar','off','figSize','medium')

% We reconstruct grains because later on, we do not want to compute the 
% WBV across grain boundaries (if present)
[grains,ebsd.grainId] = calcGrains(ebsd,'angle',2.5*degree,'minPixel',6);

% denoise the data
% we will use the noisy data later on
ebsdN = ebsd.gridify;
F = halfQuadraticFilter;
ebsd = smooth(ebsd('indexed'),F,'fill',grains);

%% Computing the WBV

% The function expects the input to a gridified <EBSD.gridify.html|EBSD|>.

ebsd = ebsd.gridify
wbv = weightedBurgersVec(ebsd);

% The WBV is returned as a <vector3d.vector3d.html|vector3d|>
% and we can inspect its magnitude (in 1/scanunit) and direction.


plot(ebsd,wbv.norm); hold on
mtexColorbar
mtexTitle('norm of the WBV')

%% Visualize the WBV
% In order to visualize the direction of the WBV in specimen coordinates,
% we can use a color key.

cK = HSVDirectionKey(specimenSymmetry('1'))
plot(ebsd,cK.direction2color(wbv))
mtexTitle('direction of the WBV in specimen coordinates')

nextAxis
plot(cK)
%%
% We could also display the WBV by small arrows. If we allow for
% any magnitude, the plot would become quite cluttered. Hence, we will only
% display those vectors which have a reasonably large magnitude.

cond = wbv.norm > quantile(wbv.norm,0.85);
% W.antipodal = 1
plot(ebsd,wbv.norm); hold on
quiver(ebsd(cond),wbv(cond),'color','k','autoScaleFactor', 2, 'antipodal'); hold off

% If we are simply interested in the distributions of WBV, we can plot them
% in a spherical projection. Since the WBV is assigned nan at points where 
% it cannot be defined, we need to filter those values
wbv.antipodal = 0
notNan = ~isnan(wbv);
plot(wbv(notNan),'weights',wbv(notNan).norm,'contourf')

%% The WBV in crystal coordinates
% In order to inspect the WBV in crystal coordinates, we can simply

wbvC = inv(ebsd.orientations) .* wbv;

% and plot the direction with a color key presenting crystal directions

cKC = HSVDirectionKey(wbvC.CS)
plot(ebsd,cKC.direction2color(wbvC))
mtexTitle('direction of the WBV in crystal coordinates')
nextAxis
plot(cKC)
hold on
plot(wbvC(notNan),'weights',wbvC(notNan).norm,'contour', ...
    'contours',[0.5:0.25:2],'linecolor','k','ShowText','on', ...
    'linewidth',2)
hold off

%%
close all
%% Effect of windowSize
% In case there are reasons why the EBSD data cannot be denoised, the WBV
% can also be computed with respect to a larger neighborhood.
% The integer specified with with 'windowSize' gives a 2*n+1 square across
% which the WBV is computed. The default is a 3-by-3 box.

newMtexFigure('layout',[4,2])

% first we plot again the WBV form the denoised dataset
wbv = weightedBurgersVec(ebsd);
nextAxis
plot(ebsd,wbv.norm); hold on
mtexTitle('norm (denoised) / box = 3')

nextAxis
notNan = ~isnan(wbv);
plot(wbv(notNan),'weights',wbv(notNan).norm,'contourf','antipodal')

% next we plot the WBV form the noisy dataset

for ws = [1 2 3]

wbv = weightedBurgersVec(ebsdN,'windowSize',ws);
nextAxis
plot(ebsdN,wbv.norm); hold on
mtexTitle(['WBV norm / box =' num2str(2*ws+1)])

nextAxis
notNan = ~isnan(wbv);
plot(wbv(notNan),'weights',wbv(notNan).norm,'contourf','antipodal')
mtexTitle(['WBV direction / box =' num2str(2*ws+1)])

end
mtexColorbar

% Here we see that there is barely a difference between the noisy and the
% denoised data in a 3-by-3 neighborhood, the latter being already
% sufficiently large to filter the noise. For larger window sizes, we see 
% that there is of course a loss of detail and a decrease in the norm 
% of WBV, since high orientation gradients are spread by the larger window 
% size. At the other hand, the distribution of the WBV becomes sharper, 
% because there is less scatter in the WBV.

%%
close