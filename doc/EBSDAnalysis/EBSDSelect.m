%% Select EBSD data
%
%%
% An EBSD variable is a list of measurements, so restricting it to part of
% the specimen, to one phase, or to the well indexed points is nothing more
% than taking a sublist. The result is an EBSD variable again and everything
% that worked on the whole map works on it unchanged. This page shows the
% three handles: the phase, the position, and any measured quantity.

plottingConvention.default('y↑→x');
mtexdata forsterite

close all;
plot(ebsd)

%% Selecting a phase
%
% A mineral name used as an index restricts the list to that phase.

ebsd('Forsterite')

%%
% Two things in that display are worth noticing. The list is shorter -
% 152345 of the 245952 measurements are forsterite - and the class has
% changed from |EBSDsquare| to |EBSD|. A selection is in general no longer
% a full grid, and the operations that need one, such as filtering or
% denoising, ask for the grid back with |gridify|; see
% <EBSDGrid.html Square and Hex Grids>.
%
% An unambiguous abbreviation of the mineral name does as well, and several
% phases are selected by grouping their names in curly brackets.

ebsd({'Fo','En'})

%%
% Two names are always available whatever the phases are called:
% |'indexed'| for every point that was matched to a phase, and
% |'notIndexed'| for the rest.

ebsd('indexed')

%%
% Plotting a single phase is then the ordinary plot command, applied to the
% sublist. The colours are those of <EBSDPlotting.html Plot>.

close all
plot(ebsd('Forsterite'),ebsd('Forsterite').orientations)

%% Restricting to a region of interest
%
% A rectangle is given as |[xmin ymin xmax-xmin ymax-ymin]| in the units of
% the map, here microns.

region = [5 2 10 5]*10^3;

%%
% Drawn on top of the map it shows what is about to be kept.

close all
plot(ebsd)
rectangle('position',region,'edgecolor','r','linewidth',2)

%%
% <EBSD.inpolygon.html |inpolygon|> tests each measurement against the
% polygon and returns one |true| or |false| per point.

condition = inpolygon(ebsd,region);

%%
% Indexing the list with that vector keeps the points inside it - 20301 of
% the 245952, one twelfth of the map.

ebsd_region = ebsd(condition)

%%
%

close all
plot(ebsd_region)

%%
% The polygon needs not be a rectangle. Any closed polygon given as a list
% of vertices works, and one can be drawn with the mouse by
%
%   poly = selectPolygon
%
%% Removing inaccurate measurements
%
% Indexing software reports how well each pattern was matched, as the mean
% angular deviation |mad| for Oxford Channel programs or as the confidence
% index |ci| for OIM-TSL. Either can be plotted like any other property.

close all
plot(ebsd_region,ebsd_region.mad)
mtexColorbar

%%
% Most of the map sits at about 0.4°. The deep blue patches are the
% notIndexed points, which report 0, and the yellow speckles - the worst
% fits in the map - lie along the grain boundaries, where the beam sees two
% crystals at once. A histogram says where to put a threshold.

close all
histogram(ebsd_region.mad)

%%
% The tallest bar is at zero, and it is not a population of perfect fits -
% it is the notIndexed points again. The measurements themselves run from
% 0.2° to 1.2° with the bulk at 0.4°, so a cut at 0.8° removes the tail and
% keeps 96% of the points.

% take only those measurements with MAD smaller then 0.8
ebsd_corrected = ebsd_region(ebsd_region.mad<0.8)

%%
%

close all
plot(ebsd_corrected)

%%
% One thing that threshold does *not* do is remove the notIndexed points.
% They have no fit to report, so their |mad| is stored as 0, and 0 passes
% every "smaller than" test - all 4052 of them are still in the map above.
% Dropping them is a separate step, and the name for it is |'indexed'|.

ebsd_corrected('indexed')

%%
% Whether they should be dropped is a question about the analysis to come.
% A notIndexed point is a measurement that failed, and where those failures
% sit is often worth knowing - see <EBSDFilling.html Filling Missing Data>
% for what else can be done with them.
%
