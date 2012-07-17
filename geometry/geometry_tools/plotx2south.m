function plotx2south
% set the default plot direction of the x-axis

plotOptions = getpref('mtex','defaultPlotOptions');
plotOptions = set_option(plotOptions,'rotate',270*degree);
setpref('mtex','defaultPlotOptions',plotOptions);
