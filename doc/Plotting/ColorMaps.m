%% Color Mapping
%
%%
% A colour in a plot means nothing on its own. It means something once the
% colour range is known, and two plots can only be compared when they share
% one. That is the whole subject of this page: which range MTEX picks, how
% to fix it, and which colormap turns the numbers into colours.

plottingConvention.default('y↑→x');

%%
% One model ODF and two pole figures simulated from it.

cs = crystalSymmetry('-3m');
odf = fibreODF(Miller(1,1,0,cs),zvector)
pf = calcPoleFigure(odf,[Miller(1,0,0,cs),Miller(1,1,1,cs)],...
  equispacedS2Grid('points',500,'antipodal'));

%% The default: tight, and per axis
%
% Without a colour range MTEX uses |'tight'|: each plot gets the range of
% its own data. This makes every plot use its colours fully and makes no two
% of them comparable.

close all
plot(pf)
mtexColorbar

%%
% Read the two colorbars: the (100) figure reaches 3.5 and the (111) figure
% 2.1. The same colour therefore stands for a different pole density in the
% two plots, and nothing in the plots themselves warns you about it.

%% One range for a figure
%
% |'colorRange','equal'| gives all axes of a figure the range of the widest
% one.

plot(pf,'colorRange','equal')
mtexColorbar

%%
% Now one colorbar serves the figure, both plots run to 3.5, and the (111)
% figure is visibly the paler of the two - which is the fact the previous
% figure hid.

%% One range across figures
%
% Comparing two separate figures needs the range stated explicitly, since
% neither knows about the other. Here the same ODF and a version of it
% diluted with half a uniform ODF, both on the range 0 to 4:

close all
plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,1,cs)],...
  'colorrange',[0 4],'antipodal');
mtexColorbar

figure
plotPDF(.5*odf+.5*uniformODF(cs),[Miller(1,0,0,cs),Miller(1,1,1,cs)],...
  'colorrange',[0 4],'antipodal');
mtexColorbar

%%
% The second texture is half as strong, and because the range is the same in
% both figures that is what one sees. On tight ranges the two would have
% looked identical.

%% Contour levels
%
% For a contour plot the levels take the place of the range, and giving them
% explicitly does the same job:

close all
plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,1,cs)],...
  'contourf',0:1:5,'antipodal')
mtexColorbar

%% Changing the range afterwards
%
% <setColorRange.html |setColorRange|> adjusts a figure that has already
% been drawn, which is convenient when the right range only becomes clear
% after seeing the data.

setColorRange([0.38,3.9])

%% Logarithmic scaling
%
% A sharp texture puts most of its values near zero and a few very high,
% and a linear scale then shows a small bright spot on an empty background.
% |'logarithmic'| spreads the low values out.

close all;
plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,1,cs)],'antipodal','logarithmic')
setColorRange([0.01 12]);
mtexColorbar

%%
% The weak parts of the pole figure now carry structure. Note that the
% colorbar is no longer linear, so distances in colour no longer correspond
% to differences in value - which is exactly the trade being made.

%% Colormaps
%
% <mtexColorMap.html |mtexColorMap|> sets the colormap of a figure. MTEX
% ships the ones texture analysis uses, |white2black|, |blue2red| and
% |LaboTeX| among them, beside the MATLAB ones.

plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,1,cs)],'antipodal')
mtexColorMap white2black
mtexColorbar

%%
% Which one to choose is not decoration. A monotone map like |white2black|
% is the honest default for a density, which has no natural middle. A
% diverging map like |blue2red| is for quantities that do - a signed
% curvature, a difference between two pole figures - and it puts its neutral
% colour at the middle of the range, so the range has to be set
% symmetrically or the neutral colour lands somewhere meaningless.

%% Different colormaps in one figure
%
% Passing an axis to |mtexColorMap| colours that axis alone, which is
% occasionally what one wants - when the axes of a figure show different
% quantities rather than the same one.

% initialize an MTEX-figure
mtexFig = newMtexFigure;

% for three different colormaps
for cm = {'hot', 'cool', 'parula'}

  % generate a new axis
  nextAxis

  % plot some random data in different axis
  plot(vector3d.rand(100),'smooth','grid','grid_res',90*degree,'upper');

  % and apply an individual colormap
  mtexColorMap(mtexFig.gca,char(cm))

  % set the title to be the name of the colormap
  mtexTitle(char(cm))
end

% plot a colorbar for each plot
mtexColorbar

%%
% Three plots of the same random data, and three impressions of it. Each
% axis needs its own colorbar here, which is the price of the freedom.
