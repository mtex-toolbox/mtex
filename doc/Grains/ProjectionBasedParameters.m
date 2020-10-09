%% Projection Based Shape Parameters
%
%%
% In this section we discuss shape parameters grains that depend on one
% dimensional projections, i.e., 
%
% || <grain2d.caliper.html |caliper|>  || caliper or Feret diameter in $\mu m$ || <grain2d.diameter.html |diameter|>  || diameter in $\mu m$ || 
%
% In order to demonstrate these parameters we first import a small sample
% data set.
 
% load sample EBSD data set
mtexdata forsterite silent
 
% reconstruct grains, discard boudnary grains and smooth them
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
ebsd(grains(grains.grainSize<5)) = [];
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
 
outerBoundary_id = any(grains.boundary.grainId==0,2);
grain_id = grains.boundary(outerBoundary_id).grainId;
grain_id(grain_id==0) = [];
grains(grain_id) = [];
 
grains=smooth(grains('indexed'),10,'moveTriplePoints');
 
 
% plot all grains and highlight a specific one
plot(grains)
 
id = 734;
hold on
plot(grains('id',id).boundary,'lineWidth',5,'linecolor','blue')
hold off
 
%%
% The most well known projection based parameter is the
% <grain2d.diamter.html |diameter|> which refers to the longest distance
% between any two boundary points and is given in $\mu m$.
 
grains(id).diameter
 
%%
% The diameter is a special case of the <grain2d.caliper.html |caliper|> or
% Feret diameter of a grain. By definition the caliper is the length of a
% grain when projected onto a line. Hence, the length of the longest
% projection is coincides with the diameter, while the quotient between
% longest and shortest projection gives an indication about the shape of
% the grain
 
grains(id).caliper('longest')
grains(id).caliper('shortest')
 
%% 
% We may trace the caliper with respect to projection direction
 
close all
omega = linspace(0,180);
plot(omega,grains('id',id+(-1:2)).caliper(omega*degree),'LineWidth',2)
xlim([0,180])
 
 
 
%%
% The difference between the longest and the shortest caliper can also be
% taken as a measure how round a grain is. The function
% <grain2d.caliper.html |caliper|> provides as second output argument also
% the angle |omega| of the longest distance between any vertices of the
% grain. This direction is comparable to the <grain2d.longAxis.html
% |grains.longAxis|> computed from an ellipse fitted to the grain.
 
[cMin, omega_min] = grains.caliper('shortest');
[cMax, omega] = grains.caliper('longest');
 
longAxis = vector3d.byPolar(pi/2,omega,'antipodal');
normal_to_shortest = vector3d.byPolar(pi/2,omega_min+pi/2,'antipodal');
 
plot(grains,(cMax - cMin)./cMax,'micronbar','off')
mtexColorbar('title','TODO')
 
% and on top the long axes
hold on
quiver(grains,grains.longAxis,'Color','white')
quiver(grains,normal_to_shortest,'Color','blue')
quiver(grains,longAxis,'Color','red')
hold off
 
%%
% In the case of rectangular particles, one might not primarily be
% interested in the longest diameter of a grain but rather of the "long
% axis" of the particle, which is better represented by the normal to the
% shortest diameter. If we imagine a very strong alignment of the long
% axes of orthorhombic particles, the maximum diameter may show a bimodal
% distribution (the two, roughly equally distributed diagonals of the
% particle).
testgrains = mtexdata('testgrains');
testgrains = smooth(testgrains([6 8]),5);
 
[~, o_min] = testgrains.caliper('shortest');
[~, o_max] = testgrains.caliper('longest');
 
lax = vector3d.byPolar(pi/2,o_max,'antipodal');
ntshax = vector3d.byPolar(pi/2,o_min+pi/2,'antipodal');
 
plot(testgrains,'micronbar','off')
hold on
quiver(testgrains,ntshax,'Color','blue')
quiver(testgrains,lax,'Color','red')
hold off

%%
% Back to the peridotite sample.
% If we look at the grains, we might wonder if there is a characteristic
% difference in the grain shape fabric - shape and alignment of the
% grains- between e.g. Forsterite and Enstatite.
 
plot(grains)
 
% In order to say something about the bulk shape fabric, sometimes referred
% to as SPO (shape preferred "orientation", totally unrelated to a crystal 
% orientation as defined in Mtex), the most basic attempt is to look at a
% length weighted rose diagram (circular histogram) of the directions of 
% the best fit ellipse long axes <grain2d.fitEllipse.html|fitEllipse|>,<EllipseBasedParameters.html>.
 
[omega, a, b] = grains.fitEllipse; 
hold on
lax = vector3d.byPolar(pi/2,omega,'antipodal');
quiver(grains,lax,'Color','red')
hold off
mtexColorbar('title','grain long axis')
 
% We can compute the length weighted distribution of grain best fit ellipse
% long axes by:
 
[freq,bc] = calcTDF(grains('fo'),'binwidth',3*degree);
plotTDF(bc,freq/sum(freq),'linecolor','g');

[freq,bc] = calcTDF(grains('en'),'binwidth',3*degree);
hold on
plotTDF(bc,freq/sum(freq),'linecolor','b');
hold off
mtexTitle('long axes')
legend('Forsterite','Enstatite','Location','southoutside')
 
% Alternatively, we may wonder if the common long axis of grains
% is does suitably represented by the direction normal to the shortest
% caliper of the grains. This can particularly be the case for aligned
% rectangular particles.
 
% calcTDF also takes a list of angles and a list of weights or lengths as
% input
[~, omega_shortestF, cPerpF] = caliper(grains('fo'),'shortest');
[~, omega_shortestE, cPerpE] = caliper(grains('en'),'shortest');
 
[freqF,bcF] = calcTDF(omega_shortestF+pi/2, 'weights',cPerpF,'binwidth',3*degree);
[freqE,bcE] = calcTDF(omega_shortestE+pi/2, 'weights',cPerpP,'binwidth',3*degree);
nextAxis
plotTDF(bcF,freqF/sum(freqF),'linecolor','g');
hold on
plotTDF(bcE,freqE/sum(freqE),'linecolor','b');
hold off
mtexTitle('normal to shortest axis [n.t.s.]')
legend('Forsterite','Enstatite','Location','southoutside')
 
 
% We can also smooth the functions with a wrapped Gaussian
pdfF = circdensity(bcF, freqF, 5*degree,'sum');
pdfE = circdensity(bcE, freqE, 5*degree,'sum');
nextAxis
plotTDF(bcF,pdfF,'linecolor','g','linestyle',':');
hold on
plotTDF(bcE,pdfE,'linecolor','b','linestyle',':');
hold off
mtexTitle('n.t.s. density estimate')
legend('Forsterite','Enstatite','Location','southoutside')
 
%%
% Because best fit ellipses are always symmetric and the projection function
% of an entire grain always only consider the convex hull, grain shape fabrics
% can also be characterized by the the length weighted rose diagram of the 
% directions of grain boundary segments.
 
 
[freqF,bcF] = calcTDF(grains('fo').boundary);
plotTDF(bcF,freqF/sum(freqF));
pdfF = circdensity(bcF, freqF, 5*degree,'sum');
hold on
plotTDF(bcF,pdfF,'linecolor','g');
hold off
mtexTitle('Forsterite grain boundaries')
nextAxis
[freqE,bcE] = calcTDF(grains('en').boundary);
plotTDF(bcE,freqE/sum(freqE));
pdfE = circdensity(bcE, freqE, 5*degree,'sum');
hold on
plotTDF(bcE,pdfE,'linecolor','b');
hold off
mtexTitle('Enstatite grain boundaries')
 
% Note that this distribution is very prone to inherit artifacts based on
% the fact that most EBSD maps are sampled on a regular grid. We tried to
% overcome this problem by heavily smoothing the grain boundary. The little 
% peaks at 0 and 90 degree are very likely still related to this sampling
% artifact.
 
 
% If we just add up all the individual elements of the rose diagram in order
% of increasing angles, we derive the characteristic shape. It can be
% regarded as to represent the average grain shape.

[csAngleF, csRadiusF] = characteristicShape(bcF,freqF);
[csAngleE, csRadiusE] = characteristicShape(bcE,freqE);
nextAxis
plotTDF(csAngleF,csRadiusF,'nogrid','nolabels','linecolor','g');
hold on
plotTDF(csAngleE,csRadiusE,'nogrid','nolabels','linecolor','b');
hold off
mtexTitle('Characteristic shapes')
legend('Forsterite','Enstatite','Location','southoutside')
 
% We may wonder if these results are significantly different or not
% TODO: get deviation from an ellipse etc



%%
% TODO: some more to explain
% <grain2d.paror.html |grains.paror|>   cummulative particle projection function  


 cumpl = paror(grains);
 plot(grains)
 
 %%
 
 figure
 plot(0:180,cumpl);
