%% Contour Plots
%
%%
% Contour lines let a reader take numbers off a figure instead of guessing
% them from a colour. They are worth adding whenever a value will be quoted
% in the text, and worth labelling whenever more than one level matters.
%
% The function used here has no physical meaning; it stands in for a pole
% figure, an inverse pole figure, a Schmid or Taylor factor map, anything
% defined on the sphere.

% define the spherical function
plottingConvention.default('y↑→x');
sF = 0.01 + 10*S2Fun.smiley

% and plot it as a smooth function
plot(sF,'upper')
mtexColorMap blue2red
mtexColorbar

%%
% Contours can be laid over the smooth plot rather than replacing it, which
% keeps the resolution of the one and the readability of the other. The
% levels are given explicitly here, since default levels chosen by the
% plotting command are not comparable between two figures.

% enable on top plotting
hold on

% specify the contour levels
levels = -4:5;

% plot the contours
h = plot(sF,'contour',levels,'linewidth',2,'linecolor','k')

% disable on top plotting
hold off

%%
% The command returns a handle to the contours, so MATLAB's own
% <matlab:doc('clabel') |clabel|> can write the values onto the lines. Label
% the few levels that carry the argument rather than all of them.

levels2label = [-2,0:5];
clabel(h.ContourMatrix,h,levels2label,'FontSize',15)

%% On a figure with several axes
%
% The same over a real pole figure - and over several of them at once, where
% |'ShowText','on'| does the labelling since there is no single handle to
% pass to |clabel|.

mtexdata dubna
odf = calcODF(pf,'silent')

%%

h = pf{4:5}.h;
plotPDF(odf,h)
mtexColorMap LaboTeX
mtexColorbar

hold on
plotPDF(odf,h,'contour',1:2:15,'linecolor','black','linewidth',2,'ShowText','on')
hold off

%%
% Both pole figures now carry the same levels, 1 to 15 in steps of 2, so the
% two can be compared line by line - which is the point of naming the levels
% rather than letting each figure choose its own.
