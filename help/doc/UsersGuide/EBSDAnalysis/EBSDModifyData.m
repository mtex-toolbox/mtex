%% Modify EBSD Data
% How to correct EBSD data for measurement errors.
%
%% Open in Editor
%
%% Contents
%
%%
% First, let us import some example <mtexdata.html EBSD data> and plot
% the raw data

mtexdata forsterite;
plotx2east
close all
plot(ebsd)

%%
% These data consist of two indexed phases, _Iron_ and _Magnesium_ : The not
% indexed data is called phase _not Indexed_. They can be visualized by a
% spatial phase plot

close all
plot(ebsd,'property','phase')

%% Selecting certain phases
% The data coresponding to a certain phase can be extracted by

ebsd_Fe = ebsd('Forsterite')

%%
% In order to extract a couple of phases, the mineral names have to be
% grouped in curled parethesis.

ebsd({'Fo','En'})

%%
% As an example, let us plot only all not indexed data

close all
plot(ebsd('notIndexed'),'facecolor','r')

%% See also
% EBSD/subsref EBSD/subsasgn
%

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



