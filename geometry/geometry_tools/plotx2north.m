function plotx2north
% set the default plot direction of the x-axis

plotOptions = getpref('mtex','defaultPlotOptions');
plotOptions = set_option(plotOptions,'rotate',90*degree);
setpref('mtex','defaultPlotOptions',plotOptions);
