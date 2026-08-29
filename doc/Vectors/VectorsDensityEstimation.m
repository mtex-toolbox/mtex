%% Spherical Density Estimation
%
%%
% A long list of measured directions is often easier to interpret as a
% smooth density on the sphere. High values identify directions that occur
% more often than they would in a uniform population.
%
% This page applies kernel density estimation to |vector3d| data. It assumes
% the vector construction from <VectorDefinition.html Defining
% Three-Dimensional Vectors>, the direction-axis distinction from
% <VectorsAxes.html Axes and Antipodal Symmetry>, and the plots introduced in
% <SphericalProjections.html Spherical Projections>. The general statistical
% idea is developed in <DensityEstimation.html Density Estimation>.

plottingConvention.default('y↑→x');

%% From Measured Axes to a Density
%
% The forsterite example map supplies one crystallographic c-axis for every
% indexed Forsterite pixel.

mtexdata forsterite silent

cAxes = ebsd('Fo').orientations * ebsd('Fo').CS.cAxis;
numCAxes = numel(cAxes)

%%
% The calculation uses 152345 axes. One |vector3d| variable holds the entire
% list, which is why the object summary itself is suppressed above.
%
% A crystallographic c-axis is an unoriented line: |c| and |-c| represent the
% same physical axis. The |antipodal| flag records that assumption.

cAxes.antipodal = true;

plot(cAxes,'upper','MarkerFaceColor','none',...
  'MarkerEdgeAlpha',0.01,'MarkerSize',4)

%%
% The projected sphere is almost covered by markers. Some concentrations are
% visible, but their relative strengths cannot be read from this overlap.
%
% <vector3d.calcDensity.html |calcDensity|> replaces the point cloud by a
% continuous spherical function.

pdf = calcDensity(cAxes)

%%
% The summary identifies a harmonic spherical function with bandwidth 25.
% It also reports |antipodal: true| because the estimate inherited the axis
% symmetry of |cAxes|.

plot(pdf,'complete')
mtexColorbar

%%
% The upper- and lower-hemisphere patterns repeat through the centre of the
% sphere. Their unequal colour levels show the concentrations hidden by the
% scatter plot.
%
% Overlaying the observations checks that the high-density regions coincide
% with the most crowded parts of the point cloud.

contourf(pdf)
mtexColorMap LaboTeX

hold on
plot(cAxes,'upper','MarkerFaceColor','none','MarkerEdgeColor','k',...
  'MarkerEdgeAlpha',0.01,'MarkerSize',4)
hold off

%%
% The darkest clusters of points lie inside the highest filled contours.
% The estimate summarizes their concentration without inventing a new
% location for a peak.
%
% MTEX normalizes the density to have mean value one.

pdfMean = mean(pdf)

%%
% Values are therefore multiples of uniform density (m.u.d.). A value of 3
% means three times the density expected from uniformly distributed axes.
% It is not the fraction of axes at one exact direction; fractions require
% integration over a finite region.

%% Choosing the Halfwidth
%
% The kernel halfwidth controls how far each observation is spread. The
% |'halfwidth'| option defaults to 10 degrees for |vector3d.calcDensity|.
% Compare four choices on the same axes.

hw = [2.5 5 10 20] * degree;
mtexFig = newMtexFigure('layout',[1 4]);

for k = 1:length(hw)

  plot(calcDensity(cAxes,'halfwidth',hw(k)),'upper')
  mtexTitle(['$' xnum2str(hw(k)./degree) '^{\circ}$'])

  if k < length(hw), nextAxis; end
end
mtexFig.drawNow

%%
% At 2.5 degrees the estimate contains many narrow peaks. At 20 degrees
% those peaks have merged into broad regions. A small halfwidth can preserve
% measurement-scale variation, while a large one can erase real structure.
% Neither choice is automatically more accurate.
%
% The halfwidth also sets the harmonic bandwidth needed to represent the
% kernel. Print both the peak density and bandwidth for the four estimates.

for k = 1:length(hw)
  pdfK = calcDensity(cAxes,'halfwidth',hw(k));
  disp(['halfwidth: ' xnum2str(hw(k)./degree) mtexdegchar ...
    ' -> maximum: ' xnum2str(max(pdfK)) ' mud' ...
    ', bandwidth: ' xnum2str(pdfK.bandwidth)])
end

%%
% Across this sweep the maximum falls from 14 to 2.5 m.u.d., while the
% bandwidth falls from 92 to 13. A sharper estimate is more expensive as
% well as more sensitive to fine-scale variation.
%
% The relevant sample size is the number of independent observations, not
% merely the number of pixels. Neighbouring EBSD pixels are spatially
% correlated because many sample the same grain. MTEX does not select a
% halfwidth automatically for directional data. For orientation data,
% <EBSD2ODF.html ODF Estimation from EBSD Data> explains this dependence and
% <OptimalKernel.html Optimal Kernel Selection> describes automatic methods.

%% Weighting Changes the Question
%
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels
% produced by segmentation. Reconstruct the indexed map with an example
% 10 degree misorientation threshold, then keep the Forsterite grains.

[grains,ebsd] = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = grains('Fo');

% one c-axis per grain
cAxesGrains = grains.meanOrientation * grains.CS.cAxis;
cAxesGrains.antipodal = true;
numGrainAxes = numel(cAxesGrains)

%%
% The reconstruction gives 1151 Forsterite grain axes instead of 152345
% pixel axes. Giving each grain one vote describes the distribution of
% grains. Weighting by sectional grain area describes the mapped material
% area, which is the question answered by equal pixel weights on this
% regular scan.

mtexFig = newMtexFigure('layout',[1 3]);

plot(pdf,'upper')
mtexTitle('one pixel - one vote')

nextAxis
plot(calcDensity(cAxesGrains),'upper')
mtexTitle('one grain - one vote')

nextAxis
plot(calcDensity(cAxesGrains,'weights',grains.area),'upper')
mtexTitle('weighted by grain area')

setColorRange('equal')
mtexColorbar
mtexFig.drawNow

%%
% With a common colour range, equal grain weights give the flattest panel.
% Area weighting restores the main concentrations of the pixel estimate,
% although replacing every grain by its mean orientation removes the
% within-grain spread. The scientifically correct weights depend on whether
% the population of interest is grains, mapped area, or something else.

%% Working with the Density Function
%
% A density is an <S2FunConcept.html |S2Fun|>, so it can be evaluated,
% integrated, searched for peaks, combined with other spherical functions,
% and sampled. <S2FunOperations.html Operations on Spherical Functions>
% develops that common interface.
%
% First find the global maximum.

[globalDensity,globalPos] = max(pdf)

%%
% The output gives both the density and the specimen direction where it is
% attained. The |'numLocal'| option requests several distinct local maxima.

[localDensity,localPos] = max(pdf,'numLocal',3)

%%
% The first local maximum is the global one. Integrate the density within
% 20 degrees of that axis using <S2Fun.volume.html |volume|>.

smoothedFraction = volume(pdf,localPos(1),20*degree)

%%
% The smoothed estimate assigns 0.1723, or 17.23 percent, of the population
% to that axial neighbourhood. Count the original axes in the same region.

observedFraction = mean(angle(cAxes,localPos(1)) < 20*degree)

%%
% The direct count is 0.1890, or 18.90 percent. Smoothing moves some density
% across the boundary of the 20 degree neighbourhood, so the two questions
% do not have to give the same answer.
%
% Evaluate the density at the three specimen basis directions.

basisDensities = pdf.eval([xvector,yvector,zvector])

%%
% Among X, Y and Z, the Y direction has the largest density in this example.
% If only these values are needed, pass the evaluation directions directly:
%
%   f = calcDensity(cAxes,[xvector,yvector,zvector])
%
% A random sample from the estimate can replace the large point cloud in a
% simulation or exploratory plot.

vRand = discreteSample(pdf,500);

plot(pdf,'upper')
hold on
plot(vRand,'MarkerFaceColor','k','MarkerSize',4)
hold off

%%
% The 500 black points follow the same broad concentrations as the coloured
% density, but retain the sampling variation expected from a finite draw.
% They are simulated representatives, not a lossless compression of the
% original 152345 measurements.

%% Crystal Directions and Symmetry
%
% The previous density lives in the specimen reference frame. An inverse
% pole density instead fixes a specimen direction and asks which crystal
% directions are parallel to it. Express specimen Z in the crystal frame of
% every Forsterite orientation.

h = inv(ebsd('Fo').orientations) .* vector3d.Z;

%%
% The result is a |Miller| array carrying the Forsterite crystal symmetry.
% <Miller.calcDensity.html |Miller.calcDensity|> transfers that symmetry to
% the density automatically.

ipdf = calcDensity(h)

%%
% The summary identifies an antipodal |S2FunHarmonicSym|. Plotting only the
% fundamental sector shows every symmetry-inequivalent crystal direction
% once.

plot(ipdf,'contourf')
mtexColorbar

%%
% The coloured sector contains the complete inverse pole density without
% repeating symmetry-related directions. The |'noSymmetry'| option disables
% crystal symmetrization when that is deliberately required.

%% Choosing a Different Kernel
%
% The default is the non-negative
% <S2DeLaValleePoussinKernel.html de la Vallee Poussin kernel>. Its finite
% harmonic expansion avoids truncation ringing. The |'kernel'| option also
% accepts other <S2Kernels.html spherical kernels>.
%
% Compare the default 10 degree kernel with a
% <S2DirichletKernel.html Dirichlet kernel> truncated at bandwidth 12.

psi1 = S2DeLaValleePoussinKernel('halfwidth',10*degree);
psi2 = S2DirichletKernel(12);

plot(psi1,'linewidth',2)
hold on
plot(psi2,'linewidth',2)
hold off
xlim([0,60])
legend('de la Vallee Poussin','Dirichlet')

%%
% The de la Vallee Poussin curve decreases without crossing zero. The
% Dirichlet curve oscillates above and below zero, and those negative lobes
% pass into a density estimate made with it.

pdf2 = calcDensity(cAxes,'kernel',psi2);

plot(pdf2,'upper')
mtexColorbar

minimumDirichletDensity = min(pdf2)

%%
% The minimum is -0.4029, which is not a valid probability density.
% Non-negative kernels are therefore the appropriate default for density
% estimation. A Dirichlet kernel remains useful for operations where exact
% harmonic truncation, rather than non-negativity, is the objective.

%% Density Estimation While Plotting
%
% Smooth plotting options for a large |vector3d| list perform density
% estimation internally. The |'contourf'|, |'smooth'| and |'pcolor'| modes
% use a 5 degree halfwidth when none is supplied.

plot(cAxes,'contourf','upper')
mtexColorMap LaboTeX
mtexColorbar

%%
% This 5 degree plot is sharper than the explicit 10 degree estimate |pdf|.
% Use <vector3d.calcDensity.html |calcDensity|> explicitly when the density
% itself, its weights, its kernel, or a reproducible smoothing choice matters.

%% The Maths Behind the Estimate
%
% Let $v_n$ be unit directions with non-negative weights $w_n$, and let
% $\psi$ be a normalized radial kernel. MTEX computes the weighted kernel
% estimate
%
% $$f(v) = \frac{1}{\sum_{n=1}^{N}w_n}
%   \sum_{n=1}^{N} w_n\,\psi(v\mathbin{\cdot}v_n).$$
%
% Equal weights reduce the denominator to $N$. For axial input, the result
% is symmetrized so that $f(v)=f(-v)$. The normalization makes the mean of
% $f$ equal to one under MTEX's uniform spherical measure.
%
% The estimate is a model of an unknown population density, not the unknown
% density itself. Decreasing the halfwidth reduces smoothing bias but raises
% sampling variation; increasing it does the reverse.

%% Further Reading
%
% * K. V. Mardia and P. E. Jupp,
% <https://doi.org/10.1002/9780470316979 Directional Statistics>, Wiley,
% 1999, treats probability models and inference for both directions and axes.
% * P. Hall, G. S. Watson and J. Cabrera,
% <https://doi.org/10.1093/biomet/74.4.751 Kernel density estimation with
% spherical data>, _Biometrika_ 74 (1987), 751-762, develops the bias,
% variance and loss of spherical kernel estimators.
% * H. Schaeben and K. G. van den Boogaart,
% <https://doi.org/10.1016/S0040-1951(03)00190-2 Spherical harmonics in
% texture analysis>, _Tectonophysics_ 370 (2003), 253-268, connects
% spherical kernels, harmonic representations and texture analysis.

%% Next
%
% Continue with <SphericalFunctions.html Spherical Functions> to work with
% densities as mathematical objects. Use <EBSD2ODF.html ODF Estimation from
% EBSD Data> when the input is a list of orientations rather than directions,
% and <ODFTutorial.html the ODF tutorial> for the complete texture workflow.
