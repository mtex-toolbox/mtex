%% Ellipse Based Shape Parameters
%
%%
% In this section we discuss geometric properties of grains that are
% related to ellipses fitted to the grains. Additionally to the orientation
% |omega|, and the lengths |a|, |b| of the long axis and short axes that
% are computed by the command <grain2d.fitEllipse.html |[omega,a,b] =
% grains.fitEllipse|>  the following properties based on the fitted
% ellipses are avaiable.
%
% || <grain2d.longAxis.html |longAxis|> || long axis as @vector3d || <grain2d.shortAxis.html |shortAxis|>  || short axis as @vector3d ||
% || <grain2d.centroid.html |centroid|> || midpoint  || <grain2d.aspectRatio.html |aspectRatio|>  || long axis / short axis ||
%
% In order to demonstrate these properties we start by reconstructing the
% grain structure from a sample EBSD data set.

% load sample EBSD data set
mtexdata forsterite silent

% reconstruct grains and smooth them 
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
ebsd(grains(grains.grainSize<10)) = [];
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
grains(grains.isBoundary) = [];

grains=smooth(grains('indexed'),10,'moveTriplePoints');

% plot the grains
plot(grains,'micronbar','off','lineWidth',2)

%% Fit Ellipses
%
% The basic command for fitting ellipses is <grain2d.fitEllipse
% |fitEllipse|>

[omega,a,b] = grains.fitEllipse;

plotEllipse(grains.centroid,a,b,omega,'lineColor','w','linewidth',2)

%%
% The returned variable |omega| is the angle describing the rotation of the
% ellipses and |a| and |b| are the length of the longest and shortest half
% axis. The midpoints of the ellipses can be computed by the command
% <grain2d.centroid.html |grains.centroid|>.  Note, that the ellipses are
% scaled such that the area of the ellipse coincides with the actual grain
% area. Alternatively, one can also scale the ellipse to fit the boundary
% length by using the option |boundary|.
%
%% Long and Short Axes
%
% The direction of the long and the short axis of the fitted ellipse can be
% obtained by the comands <grain2d.longAxis.html |grains.longAxis|> and
% <grain2d.shortAxis.html |grains.shortAxis|>. These directions are only
% well defined if the fitted ellipse is not to close to a perfect circle. A
% measure for how distinct the ellipse is from a perfect circle is the
% <grain2d.aspectRatio.html aspect ratio> which is defined as the quotient
% $a/b$ between the longest and the shortest axis. For a perfect circle
% the apect ratio is $1$ and increases to infinity when the ellipse becomes
% more and more elongated.
%
% Lets colorize the grains by their apect ratio and plot on top the long
% axis directions:

% visualize the aspect ratio
plot(grains,grains.aspectRatio,'linewidth',2,'micronbar','off')
setColorRange([0,4])
mtexColorbar('title','aspect ratio')

% and on top the long axes
hold on
quiver(grains,grains.longAxis,'Color','white')
hold off

%% Shape perfered orientation
%
% If we look at grains, we might wonder if there is a characteristic
% difference in the grain shape fabric between e.g. Forsterite and
% Enstatite. In contrast to crystal prefered orientations which which
% describe on the alignment of the atome lattices the shape prefered
% orientation (SPO) describes the algnment of the grains by shape in the
% bulk fabric. 
%
% *Long Axis Distribution*
% 
% The most direct way to analyse shape prefered orientations are rose
% diagrams of the distribution of the grain long axes. For those diagrams
% it is useful to weight the long axis by the grain area such that larger
% grains have a bigger impact on the distribution and by the aspect ratio
% as for grains with a small aspect ratio the long axis is not so well
% defined.

numBin = 50;

subplot(1,2,1)
weights = grains('forsterite').area .* (grains('forsterite').aspectRatio-1);
histogram(grains('forsterite').longAxis,numBin, 'weights', weights)
title('Forsterite')

subplot(1,2,2)
weights = grains('enstatite').area .* (grains('enstatite').aspectRatio - 1);
histogram(grains('enstatite').longAxis,numBin,'weights',weights)
title('Enstatite')

%% 
% Instead of the histogram we may also fit a circular density distribution
% to the to the long axes using the command <calcDensity.thml
% |calcDensity|>.

tdfForsterite = calcDensity(grains('forsterite').longAxis,...
  'weights',norm(grains('forsterite').longAxis),'halfwidth');

tdfEnstatite = calcDensity(grains('enstatite').longAxis,...
  'weights',norm(grains('enstatite').longAxis));

plotSection(tdfForsterite, vector3d.Z, 'linewidth', 3)

hold on
plotSection(tdfEnstatite, vector3d.Z, 'linewidth', 3)
hold off

%%
% 

close all
[freq,bc] = calcTDF(grains('fo'),'binwidth',3*degree);
plotTDF(bc,freq/sum(freq));

[freq,bc] = calcTDF(grains('en'),'binwidth',3*degree);
hold on
plotTDF(bc,freq/sum(freq));
hold off
legend('Forsterite','Enstatite','Location','eastoutside')
mtexTitle('long axes')

%% *Shortest Caliper Distribution*
%
% Alternatively, we may wonder if the common long axis of grains is does
% suitably represented by the direction normal to the shortest caliper of
% the grains. This can particularly be the case for aligned rectangular
% particles. The command <calcTDF.html |calcTDF|> also takes a list of
% angles and a list of weights or lengths as input

cPerpF = caliper(grains('fo'),'shortestPerp');
cPerpE = caliper(grains('en'),'shortestPerp');

[freqF,bcF] = calcTDF(cPerpF.rho, 'weights',cPerpF.norm, 'binwidth',3*degree);
[freqE,bcE] = calcTDF(cPerpE.rho, 'weights',cPerpE.norm, 'binwidth',3*degree);

plotTDF(bcF,freqF/sum(freqF));
hold on
plotTDF(bcE,freqE/sum(freqE));
hold off
legend('Forsterite','Enstatite','Location','eastoutside')


%%
% We can also smooth the functions with a wrapped Gaussian

pdfF = circdensity(bcF, freqF, 5*degree,'sum');
pdfE = circdensity(bcE, freqE, 5*degree,'sum');

plotTDF(bcF,pdfF);
hold on
plotTDF(bcE,pdfE);
hold off
mtexTitle('n.t.s. density estimate')
legend('Forsterite','Enstatite','Location','eastoutside')

%%
% Because best fit ellipses are always symmetric and the projection
% function of an entire grain always only consider the convex hull, grain
% shape fabrics can also be characterized by the the length weighted rose
% diagram of the directions of grain boundary segments.
  
[freqF,bcF] = calcTDF(grains('fo').boundary);
plotTDF(bcF,freqF/sum(freqF));
pdfF = circdensity(bcF, freqF, 5*degree,'sum');
hold on
plotTDF(bcF,pdfF);
hold off
mtexTitle('Forsterite grain boundaries')
nextAxis
[freqE,bcE] = calcTDF(grains('en').boundary);
plotTDF(bcE,freqE/sum(freqE));
pdfE = circdensity(bcE, freqE, 5*degree,'sum');
hold on
plotTDF(bcE,pdfE);
hold off
mtexTitle('Enstatite grain boundaries')

%% Characteristic Shape
%
% Note that this distribution is very prone to inherit artifacts based on
% the fact that most EBSD maps are sampled on a regular grid. We tried to
% overcome this problem by heavily smoothing the grain boundary. The little 
% peaks at 0 and 90 degree are very likely still related to this sampling
% artifact.
%
% If we just add up all the individual elements of the rose diagram in
% order of increasing angles, we derive the characteristic shape. It can be
% regarded as to represent the average grain shape.

[csAngleF, csRadiusF] = characteristicShape(bcF,freqF);
[csAngleE, csRadiusE] = characteristicShape(bcE,freqE);

close all
plotTDF(csAngleF,csRadiusF,'nolabels');
hold on
plotTDF(csAngleE,csRadiusE,'nolabels');
hold off
legend('Forsterite','Enstatite','Location','eastoutside')

%%
% We may wonder if these results are significantly different or not
% TODO: get deviation from an ellipse etc