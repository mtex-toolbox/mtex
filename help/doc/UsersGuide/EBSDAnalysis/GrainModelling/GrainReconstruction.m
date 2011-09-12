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
% [[matlab:edit mtexdata, script file]]

mtexdata aachen

%% Grain Reconstruction
% Grain reconstruction in MTEX is done via the command <EBSD.calcGrains.html
% calcGrains>. As an optional argument the desired threshold angle for
% missorientations defining a grains boundary can be specified.

[grains ebsd] = calcGrains(ebsd,'threshold',12.5*degree)

%%
% In order to verify the result let us plot the grain boundaries into the
% spatial EBSD plot.

plot(ebsd)
hold on
plotBoundary(grains)
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
figure, bar(hist(grainSize(grains),x) );


%%
% One can also use these properties to select specific grains. E.g. to
% select all grains with perimeter larger then 150 we have to write

peri = perimeter(grains);

large_grains = grains(peri > 150)

plot(large_grains)

%% Connection between EBSD Data and a Grains
%
% The reconstructed grains are connected with its underlaying EBSD data by an
% grain id which is stored within the grains and the EBSD variable. 
%
% The following command extracts the grain id from a certain grain

id = get(grains(20),'id')

%%
% Next we restrict our EBSD data to those measurements belonging to this
% particular grain
ebsd_grain = ebsd(get(ebsd,'grain_id') == id)

%%
% Let us apply this technique to determine the measurements within the
% largest grain. This grain of maximum size can be determined by

[max_size, id] = max(grainSize(grains));
max_grain = grains(id)

%%
% The corresponding EBSD data may directly adressed by
ebsd_max_grain = ebsd(max_grain)

%%
% plot the EBSD data for this grain
plot(ebsd_max_grain)

%%
% The other way round one may also ask for the list of all grains that
% contain certain EBSD data. Again the command <grain.link.html link>
% establishes this connection.

% get MAD
mad = get(ebsd,'mad');

% the EBSD data with bad MAD
bad_ebsd = ebsd(mad > 1.2)

% select grains containing data with bad MAD
bad_grains = grains(bad_ebsd)

% plot them
plot(bad_grains)
