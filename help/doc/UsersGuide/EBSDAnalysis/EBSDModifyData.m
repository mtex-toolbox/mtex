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

mtexdata aachen;
plot(ebsd)

%%
% These data consist of two indexed phases, _Iron_ and _Magnesium_ and not
% indexed data called phase _not Indexed_. They can be visualized by a
% spatial phase plot

close, plot(ebsd,'property','phase')

%% Selecting certain phases
% In order to restrict the data to a certain phase, the data is indexed by
% its mineral name with the following syntax

ebsd_Fe = ebsd('Fe')

%%
% In order to extract a couple of phases, the mineral names have to be
% grouped in curled parethesis.

ebsd({'Fe','Mg'})

%%
% As an example, let us plot only all not indexed data

close, plot(ebsd('notIndexed'),'facecolor','r')

%% See also
% EBSD/subsref EBSD/subsasgn
%
%% Realign / Rotate the data
%
% Sometimes its required to realign the EBSD data, e.g. by rotating,
% shifting or flipping. This is done by the commands <EBSD.rotate.html
% rotate>, <EBSD.fliplr.html fliplr>, <EBSD.flipud.html flipud> and
% <EBSD.shift.html shift>.

% define a rotation
rot = rotation('axis',zvector,'angle',5*degree);

% rotate the EBSD data
ebsd_rot = rotate(ebsd,rot);

% plot the rotated EBSD data
close, plot(ebsd_rot)

%%
% It should be stressed, that the rotation does not only effect the spatial
% data, i.e. the x, y values, but also the crystal orientations are rotated
% accordingly. This is true as well for the flipping commands
% <EBSD.rotate.html rotate> and <EBSD.fliplr.html fliplr>. Observe, how not
% only the picture is flipped but also the color changes!

ebsd_flip = fliplr(ebsd_rot);
close, plot( ebsd_flip )

%% See also
% EBSD/rotate EBSD/fliplr EBSD/flipud EBSD/shift EBSD/affinetrans

%% Restricting to a region of interest
% If one is not interested in the whole data set but only in those
% measurements inside a certain polygon, the restriction can be constructed
% as follows:

%%
% First define a region

region = [120 100;
          200 100;
          200 130; 
          120 130;
          120 100];

%%
% plot the ebsd data together with the region of interest

close, plot(ebsd)
line(region(:,1),region(:,2),'color','r','linewidth',2)

%%
% In order to restrict the ebsd data to the polygon we may use the command
% <EBSD.inpolygon.html inpolygon> to locate all EBSD data inside the region

in_region = inpolygon(ebsd,region);

%%
% and use subindexing to restrict the data

ebsd = ebsd( in_region )

%%
% plot

close, plot(ebsd)

%% Remove Inaccurate Orientation Measurements
%
% *By MAD*
%
% Most EBSD measurements contain quantities indicating inaccurate
% measurements. 

close, plot(ebsd,'property','mad')

%%
% Here we will use the MAD value to identify and eliminate
% inaccurate measurements.

% extract the quantity mad
mad = get(ebsd,'mad');

% plot a histogram
close, hist(mad)

%%

% take only those meassurements with MAD smaller then one
ebsd_corrected = ebsd(mad<1)

%%
%

close, plot(ebsd_corrected)



