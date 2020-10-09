%% Grain Orientation Parameters
%
%%
%
%% TODO: This page needs a rewrite 
%
% In this section we discuss properties of grains that are related to the
% distribution of orientations within the grains, i.e., 
%
% || |meanOrientation| || mean orientation || |GOS| || grain orientation spread || 
% || |GAM| || grain average misorientation || |GAX| || grain average misorientation axis ||
%
% As usual, we start by importing some EBSD data and computing grains

close all; plotx2east

% import the data
mtexdata ferrite silent

% compute grains
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'));
ebsd(grains(grains.grainSize < 5)) = [];
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'threshold',7.5*degree);
ebsd = ebsd.project2FundamentalRegion;
grains = smooth(grains,5);

% plot the data
plot(ebsd, ebsd.orientations)
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Grain average orientation
%
% As by construction grains consist of pixels with similar orientation. In
% order to access all the orientations that belong to a specific grain we
% make use of the property |ebsd.grainId| where we have stored during grain
% reconstruction for every EBSD pixel to which grain it belongs. Hence, we
% may use <EBSDSelect.html logical indexing> on our EBSD variable |ebsd| to
% find all orientations that belong to a certain |grainId|.

ori = ebsd(ebsd.grainId == 4).orientations

%%
% We could now use the command <orientation.mean |mean|> to compute the
% grain average orietation from these individual orientations. A more
% direct approach, however, is to access the property
% |grain.meanOrientation| which has been filled with the mean orientations
% during grain reconstruction.

plot(grains, grains.meanOrientation)

%% Misorientation to the grain mean orientation
%
% Once we have a reference orientation for each grain - the grain
% meanorientation |ori_ref| - we may want to analyse the deviation of the
% individual orientations within the grain from this reference orientation.
% The _grain reference orientation deviation_ (GROD) is the
% <MisorientationTheory.html misorientation> between each pixel orientation
% to the grain mean orientation defined as

mis2mean = inv(grains(4).meanOrientation) .* ori

%%
% While the above command computes the misorientations to the grain mean
% orientation just for one grain the command <EBSD.calcGROD.html |calcGrod|>
% computes it for all grains simultanously

mis2mean = calcGROD(ebsd, grains)

%% Grain orientation spread (GOS)
%
% The full misorientation to the mean orientation is often not so simple to
% understand. A good starting point is to just look at the misorientation
% angles to the grain mean orientation. The average of the misorientation
% angles to the grain mean orientation is called _grain orientation spread_
% (GOS) and can be computed by the command <EBSD.grainMean.html
% |grainMean|> which averages arbitrary EBSD properties over grains. Here,
% we use it to average the misorientation angle for each grain seperately.

% take the avarage of the misorientation angles for each grain
GOS = ebsd.grainMean(mis2mean.angle);

% plot it
plot(grains, GOS ./ degree)
mtexColorbar('title','GOS in degree')

%%
% It should be noted that the GOS is also directly available as the grain
% property |grains.GOS|. 
%
% The function <EBSD.grainMean.html |grainMean|> can also be used to
% compute the maximum misorientation angle to the mean orientation within
% each grain. To achieve this we have to pass the function |@max| as an
% additional argument. Note, that you can replace this function also with
% any other statistics like the meadian, or some quantile.

% compute the maximum misorientation angles for each grain
MGOS = ebsd.grainMean(mis2mean.angle,@max);

% plot it
plot(grains, MGOS ./ degree)
mtexColorbar('title','MGOS in degree')



%% Grain average misorientation (GAM)
%
% A measure that is often confused with the grain orientation spread is the
% grain average misorientation (GAM). The GAM is defined as the
% <EBSDKAM.html kernel average misorientation (KAM)> averaged over each
% grain. Hence, we can compute is by using the functions <EBSD.KAM.html
% |ebsd.KAM|> and <EBSD.grainMean.html |grainMean|>.

gam = ebsd.grainMean(ebsd.KAM);

plot(grains,gam./degree)
mtexColorbar('title','GAM in degree')
setColorRange([0,3])

%%
% While the GOS measures global orientation gradients within a grain the
% GAM reflect the average local gradient.
%
%% The Axis of deformation
%
% In an ideal world deformation of a grain happens along a specific axis.
% *TODO: add some material science* In such a case we would expect the
% orientations inside a grain to be aligned along a line with a specific
% misorientation axis to the mean orientation. Such a line is called
% <OrientationFibre.html fibre> and we can use the command <fibre.fit.html
% |fibre.fit|> to find the best fitting fibre for a given list of
% orientations. Lets do this for a single grain.

% select an intersting grain and visualize the orientations within the grain in a pole figure
% id = 32; id = 160; seems to work
id = 91;
h = Miller({1,0,0},ebsd.CS);
plotPDF(ebsd(grainsLarge(id)).orientations,h,'MarkerSize',2,'all')

% fit a fibre to the orientations within the grain
[f,lambda,fit] = fibre.fit(ebsd(grainsLarge(id)).orientations);

% add the fibre to the pole figure
hold on
plotPDF(f.symmetrise,h,'lineColor','orange','linewidth',2)
hold off

%%
% The function <fibre.fit.html |fibre.fit|> has three output arguments. The
% first one |f| is the fittted fibre. From this we can easily detect the
% prominent misorientation axis in specimen coordinates by |f.r| and in
% crystal coordinates by |f.h|.

f.r
f.h

%%
% The second output argument |lambda| are the eigenvalues of the
% orientation matrix. The largest eigenvalue indicates are localized the
% orientations are. The second largest eigenvalue is a measure how much the
% orientation distributed along the fitted fibre. The third and forth
% eigenvalue describe how much the orientations scatter off the fibre.
% The scatter off the fibre is more convinently described in the last
% output argument |fit|, which is the mean misorientation angle of the
% orientations to the fitted fibre.

lambda

fit./degree

%%
% Lets perform the above analysis for all large grains

grainsLarge = grains(grains.grainSize > 50);

% loop through all grains
for k = 1:length(grainsLarge)
  
  % fit a fibre
  [f,lambda(k,:),fit(k)] = fibre.fit(ebsd(grainsLarge(k)).orientations);
  
  % store the misorientation axes in crystal and specimen symmetry
  GAX_C(k) = f.h;
  GAX_S(k) = f.r;
    
end

%%
% And plot the fit, the third and the second largest eigenvalues. We
% clearly see how the fit is related to the third largest eigenvalue
% $\lambda_2$.

plot(grainsLarge,lambda(:,3))
mtexTitle('$\lambda_3$')

nextAxis
plot(grainsLarge,lambda(:,2))
mtexTitle('$\lambda_2$')

nextAxis
plot(grainsLarge,fit./degree)
mtexTitle('fit')

%%
% *The misorientation axes in crystal coordinates*
%
% In order to visualize the misorientatio axes we first need to define an
% approbiate color key for crystal directions. This can be done with the
% command <HSVDirectionKey.html |HSVDirectionKey|>. Note, that we need to
% specify the option |'antipodal'| since for the misorientation axes we can
% not distinguish between antipodal directions.

% define the color key
cKey = HSVDirectionKey(ebsd.CS,'antipodal');

% plot the color key and on top the misorientation axes
plot(cKey)
hold on
plot(GAX_C.project2FundamentalRegion,'MarkerFaceColor','black')
hold off

%%
% Now we can use this colorkey to visualize the misorientation axes in the
% grain map

% compute colors from the misorientation axes
color = cKey.direction2color(GAX_C);

% plot the colored grains
plot(grainsLarge, color)

%% 
% *The misorientation axes in specimen coordinates*
%
% Colorizing the misorientation axes in specimen coordinates is
% unfortunataely much more complicated. In fact, it is mathematically
% impossible to find a corresponding color key without color jumps. Instead
% MTEX visualizes axes in specimen coordinates by compass needles which are
% entierely gray if in the plane and get diveded into black and white to
% indicate which end points out of the plane and which into the plane.

plot(grains,GOS./degree)
mtexColorbar('title','GOS in degree')

hold on
plot(grainsLarge, GAX_S)
hold off


%% Testing on Bingham distribution for a single grain
% Although the orientations of an individual grain are highly concentrated,
% they may vary in the shape. In particular, if the grain was deformed by
% some process, we are interested in quantifications.

cs = ebsd(grain_selected).CS;
ori = ebsd(grain_selected).orientations;
plotPDF(ori,[Miller(0,0,1,cs),Miller(0,1,1,cs),Miller(1,1,1,cs)],'antipodal')


%%
% Testing on the distribution shows a gentle prolatness, nevertheless we
% would reject the hypothesis for some level of significance, since the
% distribution is highly concentrated and the numerical results vague.

calcBinghamODF(ori,'approximated')

%%
%

%T_spherical = bingham_test(ori,'spherical','approximated');
%T_prolate   = bingham_test(ori,'prolate',  'approximated');
%T_oblate    = bingham_test(ori,'oblate',   'approximated');

%[T_spherical T_prolate T_oblate]


%%
% Misorientation to mean orientation
%
% The third output argument is again a list of the same size as the ebsd
% measurements. The entries are the misorientation to the mean orientation
% of the corresponding grain.



[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd,'angle',7.5*degree);

plot(ebsd,ebsd.mis2mean.angle ./ degree)

hold on
plot(grains.boundary)
hold off

mtexColorbar

%%
% We can examine the misorientation to mean for one specific grain as
% follows

% select a grain by coordinates
myGrain = grains(9075,3275)
plot(myGrain.boundary,'linewidth',2)

% plot mis2mean angle for this specific grain
hold on
plot(ebsd(myGrain),ebsd(myGrain).mis2mean.angle ./ degree)
hold off
mtexColorbar




%% Definition
%
% In MTEX the misorientation between two orientations o1, o2 is defined as
%
% $$ mis(o_1,o_2) = o_1^{-1} * o_2  $$
%
% In the case of EBSD data, intragranular misorientations, misorientations
% between neighbouring grains, and misorientations between random
% measurements are of interest.




%% Intragranular misorientations
% The intragranular misorientation is automatically computed while
% reconstructing the grain structure. It is stored as the property
% |mis2mean| within the ebsd variable and can be accessed by

% get the misorientations to mean
mori = ebsd('Fo').mis2mean

% plot a histogram of the misorientation angles
plotAngleDistribution(mori)
xlabel('Misorientation angles in degree')

%%
% The visualization of the misorientation angle can be done by

close all
plot(ebsd('Forsterite'),ebsd('Forsterite').mis2mean.angle./degree)
mtexColorMap hot
mtexColorbar
hold on
plot(grains.boundary,'edgecolor','k','linewidth',.5)
hold off

%%
% In order to visualize the misorientation axis we have two choices. We can
% consider the misorientation axis either with respect to the crystal
% reference frame or with the specimen reference frame. The misorientation
% axes with respect to the crystal reference frame can be computed via

mori.axis

%%
% The axes are unique up to crystal symmetry. Accordingly, the
% corresponding color key needs to colorize only the fundamental sector.
% This is done by

% define the color key
oM = axisAngleColorKey(mori);

plot(oM)


%%
% We see that according to the above color key orientation gradients with
% respect to the (001) axis will be  displayed in red, spins around the
% (010) will be displayed in green and spins around the (100) axis will be
% displayed in blue. Pixels with no misorientation will be displayed in
% gray and as the misorientation angle increases the color gets more
% saturated.

plot(ebsd('Forsterite'),oM.orientation2color(mori))

hold on
plot(grains.boundary,'edgecolor','k','linewidth',2)
hold off


%%
% The misorientation axis with respect to the specimen coordinate system
% can unfortunaltely not be computed from the misorientation alone.
% Therefore, we require the pair consisting of grain mean orientation and
% the orientation of the pixel.
%
% Lets computed first for every pixel the corresponding reference
% orientation, i.e. the mean orientation of the grain the pixel belongs to.

oriRef = grains(ebsd('Forsterite').grainId).meanOrientation

%%
% Now the misorientation axis with respect to the specimen reference system
% is computed via

v = axis(ebsd('Forsterite').orientations,oriRef)


%%
% With respect to the specimen reference frame the misorientation axes are
% unique and not symmetry has to be considered. Accordingly, our color key
% will contain the entire sphere.

oM = axisAngleColorKey(ebsd('Forsterite'));
plot(oM)

plot(discreteSample(v,1000),'add2all','MarkerSize',2,'MarkerEdgeColor','black')

%%
% With respect to the above color key rotations around the 001 specimen
% direction will become visible as a black to white gradient while
% rotations around the 100 directions will show up as a red to magenta
% gradient.

oM.oriRef = oriRef;

color = oM.orientation2color(ebsd('Forsterite').orientations);
plot(ebsd('Forsterite'),color,'micronbar','off')
hold on
plot(grains.boundary,'edgecolor','k','linewidth',2)
hold off




%% Kernel average misorientation (KAM)

KAM = ebsd('fo').KAM;
plot(ebsd('fo'),KAM);
mtexColorbar
hold on
plot(grains.boundary,'linewidth',2)
hold off

%% Grain average misorientation (GAM)
% The grain average misorientation (GAM) is defined as the mean KAM within
% each grain. The following line can be taken as a blueprint how to average
% arbitrary properties within grains. The last argument |@nanmean| in this
% command indicates that the average should be taken as the mean ignoring
% NaNs. In order to a assign the maximum value to each grain replace this
% with |@max|.

GAM = accumarray(ebsd('fo').grainId, KAM, size(grains), @nanmean) ./degree;

%%

% plot the GAM 
plot(grains('fo'),GAM(grains('fo').id),'micronbar','off')

mtexColorbar

%% Boundary misorientations
% The misorientations between adjacent grains are stored for each boundary
% segment seperately in *grains.boundary.misorientation*

plot(grains)

hold on

bnd_FoFo = grains.boundary('Fo','Fo')

plot(bnd_FoFo,'linecolor','r')

hold off

bnd_FoFo.misorientation


%%

plot(ebsd,'facealpha',0.5)

hold on
plot(grains.boundary)
plot(bnd_FoFo,bnd_FoFo.misorientation.angle./degree,'linewidth',2)
mtexColorMap blue2red
mtexColorbar('title','misorientation angle')
hold off


%%
% In order to visualize the misorientation between any two adjacent
% grains, there are two possibilities in MTEX.
%
% * plot the angle distribution for all phase combinations
% * plot the axis distribution for all phase combinations
%
%% The angle distribution
%
% The following commands plot the angle distributions of all phase
% transitions from Forsterite to any other phase.

plotAngleDistribution(grains.boundary('Fo','Fo').misorientation,...
  'DisplayName','Forsterite-Forsterite')
hold on
plotAngleDistribution(grains.boundary('Fo','En').misorientation,...
  'DisplayName','Forsterite-Enstatite')
plotAngleDistribution(grains.boundary('Fo','Di').misorientation,...
  'DisplayName','Forsterite-Diopside')
hold off
legend('show','Location','northwest')

%%
% The above angle distributions can be compared with the uncorrelated
% misorientation angle distributions. This is done by

% compute uncorrelated misorientations
mori = calcMisorientation(ebsd('Fo'),ebsd('Fo'));

% plot the angle distribution
plotAngleDistribution(mori,'DisplayName','Forsterite-Forsterite')

hold on

mori = calcMisorientation(ebsd('Fo'),ebsd('En'));
plotAngleDistribution(mori,'DisplayName','Forsterite-Enstatite')

mori = calcMisorientation(ebsd('Fo'),ebsd('Di'));
plotAngleDistribution(mori,'DisplayName','Forsterite-Diopside')

hold off
legend('show','Location','northwest')


%%
% Another possibility is to compute an uncorrelated angle distribution from
% EBSD data by taking only into account those pairs of measurements 
% that are sufficiently far from each other (uncorrelated points). The uncorrelated angle
% distribution is plotted by

% compute the Forsterite ODF 
odf_Fo = calcDensity(ebsd('Fo').orientations,'Fourier')

% compute the uncorrelated Forsterite to Forsterite MDF
mdf_Fo_Fo = calcMDF(odf_Fo,odf_Fo)

% plot the uncorrelated angle distribution
hold on
plotAngleDistribution(mdf_Fo_Fo,'DisplayName','Forsterite-Forsterite')
hold off

legend('-dynamicLegend','Location','northwest') % update legend

%%
% What we have plotted above is the uncorrelated misorientation angle
% distribution for the Forsterite ODF. We can compare it to the
% uncorrelated misorientation angle distribution of the uniform ODF by

hold on
plotAngleDistribution(odf_Fo.CS,odf_Fo.CS,'DisplayName','untextured')
hold off

legend('-dynamicLegend','Location','northwest') % update legend

%% The axis distribution
% 
% Let's start with the boundary misorientation axis distribution

close all
plotAxisDistribution(bnd_FoFo.misorientation,'smooth')
mtexTitle('boundary axis distribution')

%%
% Next we plot with the uncorrelated axis distribution, which depends
% only on the underlying ODFs. 

nextAxis
mori = calcMisorientation(ebsd('Fo'));
plotAxisDistribution(mori,'smooth')
mtexTitle('uncorrelated axis distribution')

%%
% and finally the axis misorientation distribution of a random texture

nextAxis
plotAxisDistribution(ebsd('Fo').CS,ebsd('Fo').CS,'antipodal')
mtexTitle('random texture')
mtexColorMap parula
setColorRange('equal')
mtexColorbar('multiples of random distribution')


%% Grain properties
%
% Grains are stored as a long list of several properties. Please find
% below a table of most of the properties that are stored or can be
% computed for grains
%
% || *grains.CS* || crystal symmetry (single phase only) || 
% || *grains.GOS* || grain orientation spread || 
% || *grains.id* || grain id || 
% || *grains.meanOrientation* || meanOrientation (single phase only) ||
% || *grains.mineral* || mineral name (single phase only) || 
% || *grains.phase* || phase identifier || 
%