function plotzIntoPlane
% set the default plot direction of the z-axis

how2plot = getMTEXpref('xyzPlotting');
how2plot.outOfScreen = -zvector;