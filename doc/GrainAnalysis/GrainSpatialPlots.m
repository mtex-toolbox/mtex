%% Plotting grains
% Overview about colorizing grains and (special) grain boundaries 
%
%% Open in Editor
%
%% Contents
%

%%
% One of the central issues analyzing grains is the visualization by
% spatial maps. Therefore, let us first reconstruct some grains

mtexdata forsterite
plotx2east

% consider only indexed data for grain segmentation
ebsd = ebsd('indexed');
% perform grain segmentation
[grains,ebsd.grainId] = calcGrains(ebsd)



%% Plotting grains and combined plots
% When plotting the grains directly the associated color is defined by the
% mean orientation within each grain.

close all
plot(grains)


%%
% Nevertheless, the plot command accepts options as already known from the
% ebsd plot spatial command.

close all
plot(grains)

%%
% Particularly one can apply the color coding of orientations, i.e.
% spatially locate the grains with certain orientation.
% TODO:

%close all
%plot(grains,'colorcoding','ipdfCenter',{Miller(1,1,1),[0 0 1]},...
%  'r',zvector)

%%
% With the *hold on* command, one can combine several plots, e.g. let us
% take a look at the band contrast and the phase at the same time. We can control
% transparency with the option *facealpha*.

close all
plot(ebsd,ebsd.bc)
mtexColorMap black2white

hold on
plot(ebsd,'facealpha',0.5)
hold off

%%
% Please note, that the opengl renderer has to be activated to plot grains
% transparent.
%% 
% The reconstructed grains contain the EBSD data, they were reconstructed
% from, thus we select grains of a GrainSet and plot its corresponding EBSD

close all
ebsd_grain = ebsd(grains(grains.grainSize>15))
plot(ebsd_grain,ebsd_grain.bc)
mtexColorMap black2white

%%
% Also, a property to plot can be given as a Nx1 vector, where N is the
% number of grains.

close all
plot(grains,shapeFactor(grains))


%% Visualizing grain boundaries
% Plotting grain boundaries may be a useful task, e.g. marking special
% grain boundaries, generaly this is done by the <GrainSet.plotBoundary.html
% plotBoundary> command.

close all
plot(grains.boundary)

%%
% A grain boundaries plot can be easily combined with further plots by *hold
% on command, so we can plot various information together

hold on
plot(ebsd,ebsd.bc)
mtexColorMap white2black

%%
% e.g. we want also to see all one-pixel grains

grains_selection = grains( grains.grainSize == 1) ;

hold on
plot(grains_selection.boundary,'linecolor','r','linewidth',2)

%% Visualizing directions
% 
% We may also visualize directions by arrows placed at the center of the
% grains.

% load some single phase data set
mtexdata csl

% compute and plot grains
[grains,ebsd.grainId] = calcGrains(ebsd);
plot(grains,grains.meanOrientation)

% next we want to visualize the direction of the 100 axis
dir = grains.meanOrientation * Miller(1,0,0,grains.CS);

% the lenght of the vectors should depend on the grain diameter
len = 0.25*grains.diameter;

% arrows are plotted using the command quiver. We need to switch of auto
% scaling of the arrow length
hold on
quiver(grains,len.*dir,'autoScale','off')
hold off