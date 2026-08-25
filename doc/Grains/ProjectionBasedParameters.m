%% Projection Based Shape Parameters
%
%%
% Hold a grain up against the light and measure the width of its shadow.
% Turn it a little and measure again. The whole family of parameters on this
% page comes from that one operation: the width of the shadow as a function
% of the direction it is cast in.
%
% || <grain2d.caliper.html |caliper|>  || caliper or Feret diameter in µm || <grain2d.diameter.html |diameter|>  || diameter in µm ||
%
% Unlike a fitted <EllipseBasedParameters.html ellipse>, which describes a
% grain by four numbers, the projection function keeps a value for every
% direction and can therefore describe fabrics an ellipse cannot.

% load sample EBSD data set
plottingConvention.default('y↑→x');
mtexdata forsterite silent

% reconstruct grains, discard boundary grains and smooth them
[grains, ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',5);
grains(grains.isBoundary) = [];
grains = smoothBoundary(grains('indexed'),10,'moveTriplePoints');

% plot all grains and highlight a specific one
plot(grains)

ind = 515;
hold on
plot(grains(ind).boundary,'lineWidth',5,'linecolor','blue')
hold off

%% The caliper
%
% The <grain2d.diameter.html |diameter|> is the longest distance between any
% two points of the outline.

grains(ind).diameter

%%
% It is one value of the <grain2d.caliper.html |caliper|>, or Feret
% diameter, which is the width of the grain measured along a given
% direction - the shadow above. Traced over all directions it becomes a
% function.

close all
omega = linspace(0,180);
dir = vector3d.byPolar(90*degree,omega*degree);
plot(omega,grains(ind).caliper(dir),'LineWidth',2)
ylabel('length in $\mu$m','Interpreter','latex')
xlabel('angle of the projection line in degree')
xlim([0,180])

%%
% The curve of this grain runs between 1630 and 6930 µm, and it has
% one maximum and one minimum in 180 degrees, which is what an elongated
% and roughly convex shape gives. The two extremes are available directly,
% as vectors pointing along the direction concerned, with the caliper as
% their <vector3d.norm.html |norm|>. The longest one is the diameter again.

plot(grains(ind),'micronbar','off')
legend('off')

norm(grains(ind).caliper('longest'))
norm(grains(ind).caliper('shortest'))

hold on
quiver(grains(ind),grains(ind).caliper('longest'),'noScaling')
quiver(grains(ind),grains(ind).caliper('shortest'),'noScaling')
hold off

%%
% How much the two differ is a measure of how round a grain is, one that
% needs no ellipse to be fitted.

cMin = grains.caliper('shortest');
cMax = grains.caliper('longest');

plot(grains,(norm(cMax) - norm(cMin))./norm(cMax),'micronbar','off')
mtexColorbar('title','c_{max} - c_{min}')

%% Three ways to say which way a grain points
%
% The longest caliper and the long axis of the fitted ellipse usually agree,
% but not always, and for rectangular particles they disagree badly: the
% longest caliper of a rectangle runs along a diagonal, so a strong
% alignment of rectangles produces a bimodal distribution of directions that
% no grain actually points in. The direction normal to the *shortest*
% caliper, |'shortestPerp'|, does not have this problem.

% load some test grains
testgrains = mtexdata('testgrains');
testgrains = smoothBoundary(testgrains([6 8]),10);

% compute the longest caliper and the caliper perpendicular to the shortest
cMax = testgrains.caliper('longest');
cMinPerp = testgrains.caliper('shortestPerp');

% plot the grains and visualize the different long axes
plot(testgrains,'micronbar','off','lineWidth',2)
hold on
quiver(testgrains,cMax,'DisplayName','longest calliper','LineWidth',3)
quiver(testgrains,testgrains.longAxis,'DisplayName','long axis','LineWidth',3)
quiver(testgrains,cMinPerp,'DisplayName','perp to shortest','LineWidth',3)
hold off
legend('Location','east')

%%
% On these two shapes the three arrows point in visibly different
% directions. Which one to use is a decision about the material: the long
% axis for grains that are roughly elliptical, the perpendicular to the
% shortest caliper for anything with flat faces.

%% PAROR and SURFOR
%
% Everything so far described one grain at a time. The projection function
% can also be added up over all grains of a map, which gives a fabric
% measure that needs no averaging of directions and no assumption that a
% grain is an ellipse.
%
% The idea is from Panozzo, R., 1983, "Two-dimensional analysis of shape
% fabric using projections of digitized lines in a plane", Tectonophysics
% 95, 279-294, and its companion paper of 1984, and it goes back to Edwin A.
% Abbott's <https://en.wikipedia.org/wiki/Flatland Flatland> (1884). MTEX
% implements it as <grain2d.paror.html |grains.paror|> for whole grains and
% <grainBoundary.surfor.html |grainBoundary.surfor|> for boundary segments.
%
% |caliper| accepts a list of directions and returns one projection length
% per grain and direction, so the sum over the grains can be drawn directly.

% projection angle
omega = linspace(0,360*degree,361);
dir = vector3d.byPolar(90*degree,omega);
c = grains('Fo').caliper(dir);

subplot(1,2,1)
polarplot(omega,c,'LineWidth',2,'color',[0 0.25 0.5 0.25])
title('Forsterite')

% take the average
hold on
polarplot(omega,5*mean(c),'LineWidth',3,'color','k');
hold off

subplot(1,2,2)
c = grains('Enstatite').caliper(dir);

polarplot(omega,c,'LineWidth',2,'color',[0 0.25 0.5 0.25])
title('Enstatite')

% take the average
hold on
polarplot(omega,5*mean(c),'LineWidth',3,'color','k');
hold off

%%
% Each faint line is one grain and the black line is their average, drawn
% five times too large so that it is visible. The individual grains scatter
% over everything; the average is a smooth, slightly flattened oval, and it
% is that flattening which is the fabric.
%
% <grain2d.paror.html |paror|> computes the same average, normalised to 1.
% Its argument is the angle by which the particle is rotated
% counterclockwise while being projected from the y axis onto the x axis.

close all
cumplF = paror(grains('fo'),omega);
cumplE = paror(grains('en'),omega);

plOpt = {'LineWidth',3,'color','k'};

subplot(2,2,1)
plot(omega/degree,cumplF,plOpt{:}); xlim([0 180]);
title('paror Forsterite')
subplot(2,2,2)
polarplot(omega,cumplF,plOpt{:})
subplot(2,2,3)
plot(omega/degree,cumplE,plOpt{:}); xlim([0 180]);
title('paror Enstatite')
subplot(2,2,4)
polarplot(omega,cumplE,plOpt{:})

%%
% Two numbers are read off this curve. The first is its minimum, which plays
% the role of an average axial ratio $b/a$ for the whole fabric: 1 for an
% isotropic one, small for a strongly anisotropic one.

min(cumplF), min(cumplE)

%%
% Both phases come out at 0.71 and 0.72, within a percent of each other: a
% moderate fabric, and the same one for both minerals.
%
% The second is where the maximum and minimum sit. The maximum marks the
% preferred direction of the longest projection; the normal to the minimum
% marks the preferred direction of the shortest one. For a fabric with
% orthorhombic symmetry the two coincide, so their difference measures how
% far from that symmetry it is.

% using S1Fun for the Forsterite
sF_Fo = S1FunHarmonic.interpolate(omega,cumplF);
[~, maxposfo] = max(sF_Fo);
[~, minposfo] = min(sF_Fo);

[mod(maxposfo,pi) mod(minposfo-pi/2,pi)] /degree

% for the Enstatite
sF_En = S1FunHarmonic.interpolate(omega,cumplE);
[~, maxposen] = max(sF_En);
[~, minposen] = min(sF_En);

[mod(maxposen,pi) mod(minposen-pi/2,pi)]/degree

%%
% For forsterite the two directions are 71 and 74 degrees, for enstatite 87
% and 89: within a few degrees of each other in both cases, so both fabrics
% are close to orthorhombic. That they differ by 16 degrees between the two
% phases is the more interesting number here.
%
% The same, read off the sampled values rather than from a fitted harmonic
% function - the sampling is one degree, so the answers agree to within
% that:

% for the Forsterite
[~, id_max] = max(cumplF);
[~, id_min] = min(cumplF);

[mod(omega(id_max)./degree,180) mod(omega(id_min)./degree-90,180)]

% for the Enstatite
[~, id_max] = max(cumplE);
[~, id_min] = min(cumplE);

[mod(omega(id_max)./degree,180) mod(omega(id_min)./degree-90,180)]

%%
% <grainBoundary.surfor.html |surfor|> is the same construction applied to a
% list of boundary segments instead of to whole grains. Because it needs no
% closed outline, it works on selections that are not grains at all - the
% subgrain boundaries of a map, the twin boundaries, or the contacts between
% two particular phases, which is what we compare here.

close all
pairs = [1 1; nchoosek(1:3,2)];
phase = {'Fo' 'En' 'Di'};
for i=1:length(pairs)

  gB = grains.boundary(phase{pairs(i,:)});
  polarplot(omega, surfor(gB,omega), 'linewidth',2, ...
    'DisplayName',[phase{pairs(i,1)} '-' phase{pairs(i,2)}]);
  hold on

end
hold off
legend('Location','southoutside','Orientation','horizontal')

%%
% The four curves differ in both shape and direction. The contact between
% the two pyroxenes, enstatite and diopside, is the roundest of them, with a
% minimum at 0.87 of its maximum: the least anisotropic boundary population
% in this rock. The most anisotropic is the forsterite-diopside contact at
% 0.68, not the forsterite-forsterite boundary at 0.76. What sets
% forsterite-forsterite apart is its direction rather than its strength: its
% long direction lies at 63 degrees where the other three lie between 75 and
% 85.

%% Characteristic shape
%
% Laying every boundary segment end to end, sorted by direction, closes into
% one polygon: the characteristic shape, an average grain outline that again
% requires no closed grains, only a list of segments.

plotopts = {'normalize','linewidth',2, 'plain'};

shapeF = characteristicShape(grains.boundary('Fo','Fo'))
plot(shapeF,plotopts{:},'DisplayName','Fo-Fo')
hold on
shapeE = characteristicShape(grains.boundary('En','En'));
plot(shapeE,plotopts{:},'DisplayName','En-En')
shapeEF = characteristicShape(grains.boundary('En','Fo'));
plot(shapeEF,plotopts{:},'DisplayName','En-Fo')
hold off

legend('Location','southoutside','Orientation','horizontal')

%%
% The result is a |@shape2d|, which answers to the same commands a grain
% does. The angle between its longest and its shortest caliper, for
% instance, is 90 degrees for a shape with a mirror line and departs from it
% for a skewed one, so it measures asymmetry.

angle(shapeF.caliper('longest'),shapeF.caliper('shortest')) / degree
angle(shapeE.caliper('longest'),shapeE.caliper('shortest')) / degree
angle(shapeEF.caliper('longest'),shapeEF.caliper('shortest')) / degree

%%
% The two single phase shapes come out at 79 degrees, so both are skewed by
% about eleven degrees, and in the same sense. The mixed forsterite-enstatite
% shape is nearly symmetric at 88.5 degrees.
