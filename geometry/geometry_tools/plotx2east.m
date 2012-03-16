function plotx2east
% set the default plot direction of the x-axis

plotOptions = get_mtex_option('default_Plot_Options');
plotOptions = set_option(plotOptions,'rotate',0*degree);
set_mtex_option('default_Plot_Options',plotOptions);
