function plotx2east
% set the default plot direction of the x-axis

plotOptions = getpref('mtex','defaultPlotOptions');
plotOptions = set_option(plotOptions,'rotate',0*degree);
setpref('mtex','defaultPlotOptions',plotOptions);
