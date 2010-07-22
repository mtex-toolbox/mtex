%% Grain Reconstruction
% Explanation how to create grains from EBSD data.
%
%% Open in Editor
%
%% Contents
%
%% 
% Reconstructing grains and grain boundaries is one of the central problems
% when analyzing EBSD data. It is instrumental for ODF estimation from EBSD
% data as well as <MisorientationAnalysis.html misorientation analysis>.
%

%%
% Let us first import some standard EBSD data with a
% [[matlab:edit loadaachen.m, script file]]

loadaachen;

%% Grain Reconstruction
% Grain reconstruction in MTEX is done via the command <EBSD_segment2d.html
% segment2d>. As an optional argument the desired threshold angle for
% missorientations defining a grains boundary can be specified.

[grains ebsd] = segment2d(ebsd,'angle',12.5*degree)

%%
% In order to verify the result let us plot the grain boundaries into the
% spatial EBSD plot.

plot(ebsd)
hold on
plotboundary(grains)
hold off

%% 
% When plotting the grains directly the associated color is defined by the
% mean orientation within each grain.

plot(grains)


%%
% The reconstructed grains are stored in the variable *grains* which is
% actually a list of single [[grain_index.html,grain objects]] each of which
% can be adressed and plotted individually.

grains(1)

plot(grains([128 201 250]))

%% Grain properties 
%
% There is a long list of properties that can be computed for
% each indiviual grain, e.g.
%
% * perimeter
% * grain size
% * borderlength
%
% As an example lets plot an histogram of the grain sizes.

x = fix(exp(0.5:.5:7.5));
figure, bar(hist(grainsize(grains),x) );


%%
% One can also use these properties to select specific grains. E.g. to
% select all grains with perimeter larger then 150 we have to write

peri = perimeter(grains);

large_grains = grains(peri > 150)

plot(large_grains)

%% Connection between EBSD Data and a Grains
%
% The reconstrcuted grains are connected with its underlaying EBSD data by an
% identification number. The command <grain_link.html link> allows to extract
% all individuell orientations out of an EBSD data set that correspond to a
% certain list of grains

% the grain of maximum size
max_grain = grains(grainsize(grains)==max(grainsize(grains)))

% the corresponding EBSD data
ebsd_max_grain = link(ebsd,max_grain)

% plot the EBSD data for this grain
plot(ebsd_max_grain)

%%
% The other way round one may also ask for the list of all grains that
% contain certain EBSD data. Again the command <grain_link.html link>
% establishes this connection.

% get MAD
mad = get(ebsd,'mad');

% the EBSD data with bad MAD
bad_ebsd = copy(ebsd,mad>1.2)

% select grains containing data with bad MAD
bad_grains = link(grains,bad_ebsd)

% plot them
plot(bad_grains)
