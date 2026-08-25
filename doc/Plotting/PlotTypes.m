%% Plot Types
%
%%
% The same data can be drawn in several ways, and the choice is not
% cosmetic. Individual measurements should be shown as individual markers,
% because that is what they are. A function can be drawn as a smooth field,
% and gets contours when values have to be read off it. This page shows the
% four styles MTEX uses and what each one is for.

plottingConvention.default('y↑→x');

%% The example data
%
% One model ODF, one pole figure computed from it, and a hundred
% orientations sampled from it - a function and some measurements of it.

cs = crystalSymmetry('-3m');
odf = fibreODF(Miller(1,1,0,cs),zvector)
pf = calcPoleFigure(odf,Miller(1,0,0,cs),equispacedS2Grid('antipodal'));

%%

ori = discreteSample(odf,100)

%% Scatter plots
%
% One marker per data point, and nothing between them. This is the honest
% way to show individual orientations: the eye sees how many there are and
% where they are missing, which a smooth field hides.

close all
scatter(ori)

%%
% Vectors, Miller indices and spherical grids are drawn the same way, as
% markers in a spherical projection. The marker itself is controlled by the
% usual MATLAB properties, see
% <matlab:doc('scattergroupproperties') scattergroup_properties>:
%
% |Marker|, |MarkerSize|, |MarkerFaceColor|, |MarkerEdgeColor|

plot(zvector,'Marker','p','MarkerSize',15,'MarkerFaceColor','red','MarkerEdgeColor','black')

%%
% A marker may carry a label, with the text properties of
% <matlab:doc('text_props') text_properties>:
%
% |Label|, |Color|, |BackgroundColor|, |FontSize|

plot([Miller(1,1,1,cs),Miller(-1,1,1,cs)],...
  'label',{'X','Y'},...
  'Color','blue','BackgroundColor','yellow','FontSize',20,'grid')

%%
% Measured pole figure data are scattered too, one dot per measured
% direction coloured by its intensity. The dots trace the measurement grid,
% which is exactly the information a smooth plot would throw away.

plot(pf)

%% Contour plots
%
% Contour lines are for reading values off a figure. The levels can be left
% to MTEX or given explicitly - here every half multiple of random up to 4:

plotPDF(odf,Miller(1,0,0,cs),'contour',0:0.5:4,'antipodal')

%%
% Naming the levels is what makes two figures comparable, and it is worth
% doing whenever two plots are meant to be read against each other. Further
% options are the MATLAB
% <https://de.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.contour-properties.html contourgroup properties>.

%% Filled contour plots
%
% |contourf| fills the bands between the lines. It reads more easily than
% bare lines and it quantizes: everything inside a band gets one colour, so
% a gentle gradient becomes a staircase.

plotPDF(odf,Miller(1,0,0,cs),'contourf','antipodal')

%% Smooth plots
%
% The default for pole figures and ODFs. No contours, a colour at every
% point, and |resolution| decides how finely the function is evaluated
% before it is drawn.

plotPDF(odf,Miller(1,0,0,cs),'antipodal','resolution',10*degree)

%%
% Note the difference to the scatter plot of the measured pole figure
% earlier. This one is a function evaluated on a grid of our choosing; that
% one was a measurement on the grid the diffractometer used. They look
% similar and mean different things.

%% Line plots
%
% One dimensional sections through a function - along a
% <OrientationFibre.html fibre>, over harmonic degrees, or through a kernel.
% The usual <matlab:doc('linespec') linespec> options apply.

f = fibre(Miller(1,0,0,cs),xvector);

plot(odf,f,'linewidth',2,'linestyle','-.')

%%
% A line plot is the only one of the four that puts numbers on an axis
% rather than on a colorbar, which makes it the right choice when the shape
% of a peak matters - its height, its width, whether it has a shoulder.
