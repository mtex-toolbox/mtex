%% Modify EBSD Data
% How to correct EBSD data for measurement errors.
%
%% Open in Editor
%
%% Contents
%
%%
% First, let us import some example <mtexdata.html EBSD data>. and plot
% the raw data

mtexdata forsterite

%%
% These data consist of two indexed phases, _Iron_ and _Magnesium_. The not
% indexed phase called phase _not Indexed_. The phases can be visualized by

close all, plotx2east
plot(ebsd,'property','phase')

%% Selecting a certain phase
% In order to restrict the EBSD data to a certain phase just use the
% mineral name as an index, i.e.

ebsd('Forsterite')

%%
% contains only the Forterite measurements. In order to extract a couple of
% phases, the mineral names have to be grouped in curled parethesis.

ebsd({'Fo','En'})

%%
% As an example, let us plot the Forsterite data. 

close all
plot(ebsd('Forsterite'))
%plot(ebsd('notIndexed'),'facecolor','r')

%%
% The data are colorized according to its orientation. By default color of
% an orientation is determined by its position in the 100 inverse pole
% figure which itself is colored as

ebsdColorbar


%% Restricting to a region of interest
% If one is not interested in the whole data set but only in those
% measurements inside a certain polygon, the restriction can be constructed
% as follows:

%%
% First define a region by [xmin ymin xmax-xmin ymax-ymin]

region = [5 2 10 5]*10^3;

%%
% plot the ebsd data together with the region of interest

close all
plot(ebsd)
rectangle('position',region,'edgecolor','r','linewidth',2)

%%
% In order to restrict the ebsd data to the polygon we may use the command
% <EBSD.inpolygon.html inpolygon> to locate all EBSD data inside the region

ebsd = ebsd(inpolygon(ebsd,region))


%%
% plot

close all
plot(ebsd)

%%
% Note, that you can also select a polygon by mouse using the command
%
%   poly = selectPolygon
%
%% Remove Inaccurate Orientation Measurements
%
% *By MAD (mean angular deviation)* in the case of Oxford Channel programs, or *by
% CI (Confidence Index)* in the case of OIM-TSL programs
%
% Most EBSD measurements contain quantities indicating inaccurate
% measurements. 

close all
plot(ebsd,'property','mad')

%%
% or

close all
plot(ebsd,'property','bc')

%%
% Here we will use the MAD to identify and eliminate
% inaccurate measurements.

% plot a histogram
close all
hist(ebsd.mad)


%%

% take only those measurements with MAD smaller then one
ebsd_corrected = ebsd(ebsd.mad<0.8)


%%
%

close all
plot(ebsd_corrected)



