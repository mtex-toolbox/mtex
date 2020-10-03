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

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% reconstruct grains and smooth them 
[grains, ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',5*degree);
grains = smooth(grains,5);

% plot the orientation data of the Forsterite phase
plot(ebsd('fo'),ebsd('fo').orientations)

% plot the grain boundary on top of it
hold on
plot(grains.boundary,'lineWidth',2)
hold off

%% Fit Ellipses
%
% The basic command for fitting ellipses is <grain2d.fitEllipse
% |fitEllipse|>

[omega,a,b] = grains.fitEllipse;
plot(grains,'linewidth',4,'micronbar','off')
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
plot(grains,grains.aspectRatio,'linewidth',4,'micronbar','off')
setColorRange([0,4])
mtexColorbar('title','aspect ratio')

% and on top the long axes
hold on
quiver(grains,grains.longAxis,'Color','white')
hold off
