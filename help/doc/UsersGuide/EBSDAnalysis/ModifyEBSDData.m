%% Modify EBSD Data
% How to use MTEX to correct EBSD data for measurement errors.
%
%% Open in Editor
%
%% Contents
%

%%
% Let us first import some standard EBSD data with a [[matlab:edit mtexdata, script file]]

mtexdata aachen;

%% 
% and plot the raw data
plot(ebsd)

%%
% These data consist of two phases, Iron and Magnesium. In order to to
% plot the data with there phase one can use the command

plot(ebsd,'property','phase')


%% Selecting certain phases
% In order to restrict the data to a certain phase the following syntax is
% supported

ebsd_Fe = ebsd('Fe')

%%
% In order to extract more then one phase, the mineral names has to be
% grouped in curled parethesis. 

ebsd({'Fe','Mg'})

%%
% As an example let us plot only all Magnesium data

plot(ebsd('Mg'))

%% Realign / Rotate the data
%
% Sometimes its required to realign the EBSD data, e.g. by rotating,
% shifting or flipping them. This is done by the commands 
% <EBSD.rotate.html rotate>, <EBSD.fliplr.html fliplr>, <EBSD.flipud.html
% flipud> and <EBSD.shift.html shift>.

% define a rotation
rot = rotation('axis',zvector,'angle',5*degree);

% rotate the EBSD data
ebsd_rot = rotate(ebsd,rot);

% plot the rotated EBSD data
close all, plot(ebsd_rot)

%%
% It should be stressed, that the rotation does not only effect the spatial
% data, i.e. the x, y values, but also the crystal orientations are rotated
% accordingly. This is true as well for the flipping commands
% <EBSD.rotate.html rotate> and <EBSD.fliplr.html fliplr>. Observe, how not
% only the picture is flipped but also the color of the grains chages!

ebsd_flip = fliplr(ebsd_rot);
close all, plot( ebsd_flip )

%% See also
% EBSD/rotate EBSD/fliplr EBSD/flipud EBSD/shift EBSD/affinetrans

%% Restricting to a region of interest
% If one is not interested in the whole data set but only in those
% measurements inside a certain polygon, the restriction can be
% constructed as follows. Lets start by defining a rectangle.


% the region
region = polygon('rectangle',120, 100, 200, 130);

% plot the ebsd data
plot(ebsd)

% plot the rectangle on top
hold on
plot(region,'color','r','linewidth',2)
hold off


%%
% In order to restrict the ebsd data to the polygon we may use the command
% <EBSD.inpolygon.html inpolygon> to find the ebsd inside the region

ind = inpolygon(ebsd,region);

%%
% and use subindexing to restrict the data

ebsd(ind)

%%
% However, it is much more convinient to use subindexing to restrict the
% data to the rectangle
ebsd = ebsd(region)

% plot
plot(ebsd)


%% Remove Inaccurate Orientation Measurements
%
% *By MAD*
%
% Most EBSD measurements contain quantities indicating inaccurate
% measurements. Here we will use the MAD value to identify and eliminate
% inaccurate measurements.

% extract the quantity mad 
mad = get(ebsd,'mad');

% plot a histogram
hist(mad)

%%

% take only those meassurements with MAD smaller then one
ebsd_corrected = ebsd(mad<1)

%%
%
plot(ebsd_corrected)


%% 
% *By grain size*
%
% Sometimes measurements that belongs to grains consisting of only very
% few measurements can be regarded as inaccurate. In order to detect such
% measuremens we have first to reconstruct grains from the EBSD
% measurements using the command <EBSD.calcGrains.html segment2d>

grains = calcGrains(ebsd_corrected,'threshold',10*degree)

%%
% The histogram of the grainsize shows that there a lot of grains
% consisting only of very few measurements.

hist(grainSize(grains),50)

%%
% Lets find all grains containing at least 5 measurements

large_grains = grains(grainSize(grains) >= 5)

%%
% and remove all EBSD measurements not belonging to these grains

ebsd_corrected = ebsd_corrected(large_grains)

plot(ebsd_corrected)

%% 
% Now reconstruct again grains in our reduced EBSD data set

grains_corrected = calcGrains(ebsd_corrected,'threshold',10*degree)

plot(grains_corrected)

%%
% we observe that there are no small grains anymore

hist(grainSize(grains_corrected),50)


