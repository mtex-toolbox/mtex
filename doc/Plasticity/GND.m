%% Geometrically Necessary Dislocations
%
% A spatial change in lattice orientation requires dislocations to preserve
% compatibility. These are *geometrically necessary dislocations* (GNDs).
% Conventional two-dimensional EBSD measures only the in-plane orientation
% gradient, so it cannot identify a unique three-dimensional dislocation
% population.
%
% The workflow on this page follows Pantleon (2008). It computes the measured
% lattice curvature and fits the least-energy combination of candidate
% dislocation systems that reproduces it. Read
% <DislocationSystems.html Dislocation Systems> first for the Burgers vector,
% line vector, tensor basis, and relative line-energy weights used here.

%% Load and segment the map
% The example is a ferritic steel map after two percent uniaxial deformation.
% The |'minPixel'| option marks indexed regions smaller than six pixels as
% |notIndexed| during segmentation. A 2.5 degree threshold separates the
% remaining grains.

plottingConvention.default('y←↑x');
ebsd = EBSD.load([mtexDataPath filesep 'EBSD' filesep ...
  'DC06_2uniax.ang'],'setting',2);

[grains,ebsd] = calcGrains(ebsd,'angle',2.5*degree,'minPixel',6);
grains = smoothBoundary(grains,5);

%%
% An inverse pole figure (IPF) key colors each indexed orientation by the
% crystal direction parallel to specimen $y$. The boundaries provide the
% spatial context for the orientation changes used below.

ipfKey = ipfHSVKey(ebsd);
ipfKey.ipfDirection = yvector;

plot(ebsd,ipfKey.orientation2color(ebsd.orientations), ...
  'refFrame','on','figSize','medium')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% Notice that each grain has a dominant color, while smaller color changes
% remain inside many grains. Those intragranular changes carry the curvature
% signal, together with measurement noise.

%% Denoise before differentiating
% Differentiation amplifies point-to-point orientation noise and therefore
% overestimates GND density. An axis-angle color key makes local departures
% from each grain's mean orientation easier to see before filtering.

axisKey = axisAngleColorKey(ebsd);
axisKey.oriRef = grains(ebsd('indexed').grainId).meanOrientation;

plot(ebsd('indexed'), ...
  axisKey.orientation2color(ebsd('indexed').orientations), ...
  'micronBar','off','figSize','medium')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The pixel-scale color speckle is the symptom to notice. A
% |halfQuadraticFilter| reduces that noise while the |'fill'| option uses the
% grain partition to prevent smoothing across grain boundaries.

F = halfQuadraticFilter;
ebsd = smooth(ebsd,F,'fill',grains);

axisKey.oriRef = grains(ebsd('indexed').grainId).meanOrientation;
plot(ebsd('indexed'), ...
  axisKey.orientation2color(ebsd('indexed').orientations), ...
  'micronBar','off','figSize','medium')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The denoised map retains broad color gradients inside grains but suppresses
% much of the isolated pixel-to-pixel variation. Filtering is therefore part
% of the measurement model, not merely cosmetic preparation for the plot.

%% Estimate GND content in one command
% Ferrite is body-centred cubic, so this example uses the standard BCC set of
% 48 edge and 4 screw systems. Following the normalization on the preceding
% page, the edge weight is one and the screw weight is $1-\nu$, with
% Poisson's ratio $\nu=0.3$.
%
% There is no universally accepted set of line-energy weights. Replace these
% illustrative values with values appropriate to the material and model.

dS = dislocationSystem.bcc(ebsd.CS);
nu = 0.3;
dS(dS.isEdge).u = 1;
dS(dS.isScrew).u = 1 - nu;

%%
% <EBSD.calcGND.html |calcGND|> returns an energy-weighted GND density for
% each pixel and the signed density assigned to each candidate system.
% The first output is often called the total dislocation energy. With the
% dimensionless weights above, it is an energy-weighted density rather than
% an absolute energy measurement.

[gnd,rho] = calcGND(ebsd,dS);

close all
plot(ebsd,gnd,'micronbar','off')
mtexColorMap('hot')
mtexColorbar
set(gca,'ColorScale','log'); % requires MATLAB R2018a or newer
set(gca,'CLim',[1e11 5e14]);
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% Read the map on its logarithmic scale. Bright regions require a larger
% energy-weighted dislocation content to reproduce the measured curvature;
% dark regions require less. Grain boundaries are overlaid for location, but
% the fitted values belong to EBSD pixels rather than boundary segments.

%% The maths behind the workflow
% The remainder of the page expands the operations performed by |calcGND|.
% This sequence is useful when you need to inspect tensor components, change
% the candidate systems, or retain their individual fitted densities.

%% Compute the incomplete curvature tensor
% The curvature tensor $\boldsymbol\kappa$ collects directional derivatives
% of lattice orientation. A two-dimensional map supplies derivatives along
% its two in-plane directions but not along the map normal.

kappaMeasured = ebsd.curvature

%%
% Inspect one pixel and one component. Curly braces select a tensor component
% over the whole map, whereas parentheses select map positions.

kappaMeasured(3,2)
kappa12 = kappaMeasured{1,2};
size(kappa12)

%%
% The component array has the same size as the EBSD map. For this scan the
% unknown out-of-plane derivative occupies the third tensor column, so that
% column contains |NaN|.

newMtexFigure('nrows',3,'ncols',3);
for i = 1:3
  for j = 1:3
    nextAxis(i,j)
    plot(ebsd,kappaMeasured{i,j},'micronBar','off')
    hold on
    plot(grains.boundary,'linewidth',2)
    hold off
  end
end
setColorRange([-0.005,0.005])
drawNow(gcm,'figSize','large')

%%
% Read columns from left to right in each tensor row. The blank panels in the
% third column make the unmeasured out-of-plane derivative explicit; they are
% not zero-curvature components.

%% Convert curvature to the Nye tensor
% Nye's dislocation-density tensor $\boldsymbol\alpha$ is related to
% curvature by
%
% $$ \boldsymbol\alpha = \boldsymbol\kappa^{T}
%    - \mathrm{tr}(\boldsymbol\kappa)\,\mathbf I. $$
%
% The method <curvatureTensor.dislocationDensity.html
% |dislocationDensity|> applies this relation.

alphaMeasured = kappaMeasured.dislocationDensity
alphaMeasured(3,2)

%%
% This tensor remains incomplete because the map contains no derivative
% normal to its plane. MTEX can recover the $(3,3)$ entry from the two known
% diagonal curvature components, but the other missing entries remain |NaN|.

%% Rotate the candidate systems
% Each tensor supplied by |dS.tensor| is the rank-two dyad
% $\mathbf b\otimes\hat{\mathbf l}$. Its length unit is inherited from the
% unit cell, usually Angstrom and displayed as |au|.
%
% The tensors are initially expressed in the crystal frame. The measured
% curvature is expressed in the specimen frame, so each pixel orientation
% must rotate all candidate systems into that same frame.

dS(1).tensor
dSRot = ebsd.orientations * dS;

%% Fit individual system densities
% <curvatureTensor.fitDislocationSystems.html |fitDislocationSystems|>
% solves a linear program at every pixel. It reproduces the six measured
% curvature components while minimizing
% $\sum_j u_j\lvert\rho_j\rvert$ over the candidate systems.
%
% The Optimization Toolbox function |linprog| is required. The result |rho|
% has one row per EBSD pixel and one column per dislocation system. Its signs
% distinguish the two line senses represented internally during the fit.

[rhoWorked,factor] = fitDislocationSystems(kappaMeasured,dSRot);
size(rhoWorked)
factor

%%
% The scale factor converts the density coefficients from
% $1/(\mathrm{\mu m}\,\mathrm{au})$ to $1/\mathrm{m}^2$. With micrometre scan
% units and Angstrom lattice units it is $10^{16}$.

%% Reconstruct the fitted tensors
% Sum each rotated basis tensor multiplied by its fitted density. The numeric
% matrix |rhoWorked| does not retain units, so the tensor unit must be restored
% explicitly after this manual reconstruction.

alphaFitted = reshape(sum(dSRot.tensor .* rhoWorked,2),size(ebsd));
alphaFitted.opt.unit = '1/um';

alphaFitted(3,2)
kappaMeasured(3,2).dislocationDensity

%%
% The fitted tensor is complete because the chosen dislocation population
% supplies the components that EBSD cannot measure directly. Converting it
% back gives a complete fitted curvature tensor.

kappaFitted = alphaFitted.curvature
kappaFitted(3,2)

newMtexFigure('nrows',3,'ncols',3);
for i = 1:3
  for j = 1:3
    nextAxis(i,j)
    plot(ebsd,kappaFitted{i,j},'micronBar','off')
    hold on
    plot(grains.boundary,'linewidth',2)
    hold off
  end
end
setColorRange([-0.005,0.005])
drawNow(gcm,'figSize','large');

%%
% Unlike the measured grid, this grid has values in all nine panels. The
% fitted in-plane columns reproduce the observations; the third column is a
% model-dependent completion, not an additional EBSD measurement.

%% Reproduce the one-command result
% Multiplying the absolute fitted densities by their line-energy weights and
% by the unit factor gives the scalar returned by |calcGND|.

gndWorked = factor * sum(abs(rhoWorked .* dSRot.u),2);
max(abs(gndWorked-gnd),[],'omitnan')

%%
% The zero difference verifies that the expanded sequence and |calcGND| use
% the same calculation. Plotting the worked result therefore reproduces the
% first GND map.

close all
plot(ebsd,gndWorked,'micronbar','off')
mtexColorMap('hot')
mtexColorbar
set(gca,'ColorScale','log'); % requires MATLAB R2018a or newer
set(gca,'CLim',[1e11 5e14]);
hold on
plot(grains.boundary,'linewidth',2)
hold off

%#ok<*NASGU>

%% References
%
% * W. Pantleon,
% <https://doi.org/10.1016/j.scriptamat.2008.01.050 Resolving the
% geometrically necessary dislocation content by conventional electron
% backscattering diffraction>, _Scripta Materialia_ 58 (2008), 994-997,
% gives the incomplete-curvature and least-energy fitting method used here.
% * J. F. Nye,
% <https://doi.org/10.1016/0001-6160(53)90054-6 Some geometrical relations in
% dislocated crystals>, _Acta Metallurgica_ 1 (1953), 153-162, derives the
% dislocation-density tensor from lattice curvature.
% * E. Kröner,
% <https://link.springer.com/book/9783540022619 Kontinuumstheorie der
% Versetzungen und Eigenspannungen>, Springer, 1958, develops the continuum
% theory in which the curvature-dislocation relation is interpreted.
% * D. Hull and D. J. Bacon,
% <https://doi.org/10.1016/C2009-0-64358-0 Introduction to Dislocations>,
% fifth edition, Butterworth-Heinemann, 2011, derives the edge and screw line
% energies summarized on the preceding page.

%% Next
%
% Continue with <WBV.html Weighted Burgers Vector> for a boundary-based
% measure of lattice-curvature content that does not fit a complete
% population of crystallographic dislocation systems.
