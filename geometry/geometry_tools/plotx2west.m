function plotx2west
% set the default plot direction of the x-axis

plotOptions = getpref('mtex','defaultPlotOptions');
plotOptions = set_option(plotOptions,'rotate',180*degree);
setpref('mtex','defaultPlotOptions',plotOptions);
