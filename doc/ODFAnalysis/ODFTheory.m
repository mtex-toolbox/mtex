%% The Orientation Distribution Function
%
%%
% A texture is a population of orientations, and the orientation
% distribution function (ODF) is how that population is described as a
% whole: not a list of measured orientations, but a *density* over
% orientation space.
%
% Density is the word to hold on to. The ODF does not say what percentage of
% the material sits at one exact orientation - that percentage is zero, as
% for any continuous distribution. It says how much volume is found *per
% unit of orientation space* near that orientation,
%
% $$\mathrm{odf}(g) = \frac{1}{V} \frac{\mathrm{d}V(g)}{\mathrm{d}g},$$
%
% so a volume fraction is only obtained by integrating over a region of
% orientations. The normalisation is chosen so that the uniform texture has
% $\mathrm{odf} \equiv 1$, and values are read as *multiples of a random
% distribution*, mrd.

plottingConvention.default('y↑→x');

%% From Measured Orientations to a Density
%
% A titanium alloy, measured by EBSD: an orientation at every point of a
% hexagonal grid. The crystal shapes drawn on the map show what the colours
% encode.

% import the data
mtexdata titanium

%%

% define the habitus of titanium as a sample hexagonal prism
cS = crystalShape.hex(ebsd.CS);

% plot colored orientations
plot(ebsd,ebsd.orientations,'micronbar','off')

% and on top the orientations represented by rotated hexagonal prism
hold on
plot(reduce(ebsd,4),40*cS)
hold off

%%
% Now forget where each measurement was taken. What is left is a cloud of
% points in orientation space, here drawn in Euler angles.

plot(ebsd.orientations,'Euler')

%%
% Orientation space is curved, so no drawing of it is canonical; the
% alternatives are in <OrientationVisualization3d.html 3D Plots>. What
% matters here is that the cloud is not uniform - it has regions where the
% points crowd together.
%
% <rotation.calcDensity.html |calcDensity|> turns the cloud into the density
% behind it, by placing a kernel at every measurement and adding them up,
% see <DensityEstimation.html Density Estimation>.

odf = calcDensity(ebsd.orientations)

%% Reading Values
%
% The result is a function, so it can be evaluated anywhere - also at
% orientations that were never measured.

ori = orientation.byEuler(0,0,0,ebsd.CS);

odf.eval(ori)

%%
% 0.82 mrd: this orientation is slightly *less* common in the specimen than
% it would be in an untextured one, where the value would be 1 everywhere.
% The strongest orientation of this texture is nine times as common as
% random.

max(odf)

%%
% The mean of an ODF is 1 by construction, whatever the texture, which is
% why a single value only means something relative to it.

mean(odf)

%%
% A volume fraction, the quantity the density is often mistaken for, comes
% from integrating over a region - here all orientations within $10^\circ$
% of the strongest one.

[~,oriMax] = max(odf);

volume(odf,oriMax,10*degree)

%%
% Two percent of the material, not nine: the 9 mrd above is a density, and
% the region it applies to is small.

%% Looking at an ODF
%
% Being a function on a three dimensional space, an ODF can be drawn in 3d,

plot3d(odf,'Euler')
hold on
plot(ebsd.orientations,'Euler','MarkerEdgeColor','k')
hold off

%%
% but Euler angle space distorts volumes, so a concentration there is
% misleading, and the plot is hard to read besides.
% <SigmaSections.html Sigma sections> are the geometrically sounder view and
% the one to prefer.

plotSection(odf,'sigma')

%% Next
%
% How a density is estimated from measurements, and what the halfwidth does
% to it, is <DensityEstimation.html Density Estimation>. Model ODFs, built
% rather than measured, are <ODFModeling.html Modeling>, and the numbers
% that summarise an ODF - texture index, entropy, volume fractions - are
% <ODFCharacteristics.html Properties>.

%#ok<*NOPTS>
