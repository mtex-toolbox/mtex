%% Ellipse Based Shape Parameters
%
%%
% In this section we discuss geometric properties of grains that are
% related to ellipses fitted to the grains. The table below summarizes all
% these propeties
%
% || <grain2d.centroid.html |grains.centroid|>  || midpoint of the ellipse || 
% || <grain2d.longAxis.html |grains.longAxis|>  || long axis of the ellipse ||
% || <grain2d.shortAxis.html |grains.shortAxis|>  || short axis of the ellipse ||
% || <grain2d.aspectRatio.html |grains.aspectRatio|>  || quotient long axis / short axis ||
% || <grain2d.equivalentPerimeter.html |grains.equivalentPerimeter|>  || perimeter of the circle/ellipse || 
% || <grain2d.equivalentRadius.html |grains.equivalentRadius|>  || radius of the circle/ellipse || 
% || <grain2d.shapeFactor.html |grains.shapeFactor|>  || quotient grain perimeter / ellipse perimeter || 
% || <grain2d.principalComponents.html |grains.principalComponents|>  || angle, length and width of the fitted ellipse || 
%
% In order to demonstrate these properties we start by reconstructing the
% grain structure from a sample EBSD data set.

% load sample EBSD data set
mtexdata forsterite

% restrict it to a subregion of interest.
ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));

% remove all not indexed pixels
ebsd = ebsd('indexed');

% reconstruct grains
[grains, ebsd.grainId] = calcGrains(ebsd,'angle',5*degree);

% smooth them
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

%% Radius and Perimeter of the Ellipses
%
% Remember that the fitted ellipses are scaled shuch that they have the
% same area as the grains. However, the <grain2d.equivalentRadius.html
% radius> and the <grain2d.equivalentPerimeter.html perimeter> of the
% ellipses are usually different then the actual perimeter of the grains.
% Hence, the difference between grain perimeter and ellipse perimeter can
% be interpreted as a measure for the goodness of fit.

plot(grains,(grains.perimeter - grains.equivalentPerimeter)./grains.perimeter)
setColorRange([0,0.5])
mtexColorbar

%%
% In this plot round shapes will have values close to zero while concave
% shapes will get large values. A similar measure is the
% <grain2d.shapeFactor.html shape factor> which is defined as the ratio
% between the grain perimeter and the equivalent perimeter

plot(grains,grains.shapeFactor)
setColorRange([1,2])
mtexColorbar('title','shape factor')

%%
% A similar measure is the <grain2d.paris.html paris> which stands
% for Percentile Average Relative Indented Surface and gives the relative
% difference between the actual perimeter and the perimeter of the convex
% hull.

plot(grains,grains.paris)
mtexColorbar('title','paris')

