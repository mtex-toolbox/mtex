%% Contour Plots
% How to customize contour plots in MTEX


%%
% Lets consider an arbitrary spherical function which has no practical
% meaning at all but serves as a prototype for pole figures, inverse pole
% figures, Schmidt or Taylor factor maps, etc.

% define the spherical function
sF = 0.01 + 10*S2Fun.smiley

% and plot it as a smooth function
plot(sF,'upper')
mtexColorMap blue2red
mtexColorbar

%%
% Passing the option |contour| to the plot command we may add contours at
% specific levels on top of the smooth plot

% enable on top plotting
hold on

% specify the contour levels
levels = -4:5;

% plot the contours
h = plot(sF,'contour',levels,'linewidth',2,'linecolor','k')

% diable on top plotting
hold off

%%
% The plotting command return a handle |h| to the plotted contours. This
% handle can be used to customize the contour lines. In particular, one can
% use the Matlab command <matlab:doc('clabel') clabel> to add labels to
% specific contour levels.

levels2label = [-2,0:5];
clabel(h.ContourMatrix,h,levels2label,'FontSize',15)


%% A practical example
% The situation becomes a little bit more involved if contour lines should
% be added to multiple plot. Let us consider the pole figures of the
% following ODF

mtexdata dubna
odf = calcODF(pf,'silent')

%%
% Then we may use the option |'ShowText','on'| to display contour labels.

h = pf{4:5}.h;
plotPDF(odf,h)
mtexColorMap LaboTeX
mtexColorbar

hold on
plotPDF(odf,h,'contour',1:2:15,'linecolor','black','linewidth',2,'ShowText','on')
hold off

