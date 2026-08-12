%% Geometrically Necessary Dislocations
%
%%
% This example sheet describes how to estimate dislocation densities
% following the reference paper
%
% <https://doi.org/10.1016/j.scriptamat.2008.01.050 Pantleon, Resolving the
% geometrically necessary dislocation content by conventional electron
% back-scattering diffraction, Scripta Materialia, 2008>
%
% Lets start by importing orientation data from 2 percent uniaxial deformed
% steel DC06 and visualize those data in an ipf map.

% import the EBSD data
ebsd = EBSD.load([mtexDataPath filesep 'EBSD' filesep 'DC06_2uniax.ang'],'setting',2);
ebsd.how2plot = plottingConvention(zvector,-yvector);

% define the color key
ipfKey = ipfHSVKey(ebsd);
ipfKey.inversePoleFigureDirection = yvector;

% and plot the orientation data
plot(ebsd,ipfKey.orientation2color(ebsd.orientations),'micronBar','off','figSize','medium')

%%
% In the next step we reconstruct grains, remove all grains with less then
% 5 pixels and smooth the grain boundaries.

% reconstruct grains
[grains,ebsd] = calcGrains(ebsd,'angle',2.5*degree,'minPixel',6);

% smooth grain boundaries
grains = smoothBoundary(grains,5);

hold on
plot(grains.boundary,'linewidth',2)
hold off

%% Data cleaning
% The computation of geometrically necessary dislocations from EBSD maps
% depends on local orientation changes in the map. In order to make those
% visible we switch to a different color key that colorizes the
% misorientation of an pixel with respect to the grain meanorientation.

% a key the colorizes according to misorientation angle and axis
ipfKey = axisAngleColorKey(ebsd);

% set the grain mean orientations as reference orientations
ipfKey.oriRef = grains(ebsd('indexed').grainId).meanOrientation;

% plot the data
plot(ebsd('indexed'),ipfKey.orientation2color(ebsd('indexed').orientations),'micronBar','off','figSize','medium')

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% We observe that the data are quite noisy. As noisy orientation data lead
% to overestimating the GND density we first have to denoise the
% orientation data.

% define the denoising filter
F = halfQuadraticFilter;

ebsd = smooth(ebsd,F,'fill',grains);

% plot the denoised data
ipfKey.oriRef = grains(ebsd('indexed').grainId).meanOrientation;
plot(ebsd('indexed'),ipfKey.orientation2color(ebsd('indexed').orientations),'micronBar','off','figSize','medium')

hold on
plot(grains.boundary,'linewidth',2)
hold off

%% The GND density in one command
% Everything below is done for you by <EBSD.calcGND.html |calcGND|>, which
% takes the EBSD data and a set of
% <dislocationSystem.dislocationSystem.html dislocation systems> and returns
% the total dislocation energy per pixel together with the density of each
% individual system.

% the dislocation systems of a body centered cubic material, with the
% energies of edge and screw dislocations set as discussed further below
dS = dislocationSystem.bcc(ebsd.CS);
dS(dS.isEdge).u = 1;
dS(dS.isScrew).u = 1 - 0.3;

[gnd,rho] = calcGND(ebsd,dS);

close all
plot(ebsd,gnd,'micronbar','off')
mtexColorMap('hot')
mtexColorbar
set(gca,'ColorScale','log');
set(gca,'CLim',[1e11 5e14]);

hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% The remainder of this page walks through what |calcGND| does internally.
%
%% The incomplete curvature tensor
% Starting point of any GND computation is the curvature tensor, which is a
% rank two tensor that is defined for every pixel in the EBSD map by the
% directional derivatives in x, y and z direction.

kappa = ebsd.curvature

kappa(32)

%%
% As expected the curvature tensor is NaN in the third column as this
% column corresponds to the directional derivative in z-direction which is
% usually unknown for 2d-EBSD maps.
%
% We can access the different components of the curvature tensor with

kappa12 = kappa{1,2};

size(kappa12)

%%
% which results in a variable of the same size as our EBSD data. This allows
% us to visualize the different components of the curvature tensor

newMtexFigure('nrows',3,'ncols',3);

% cycle through all components of the tensor
for i = 1:3
  for j = 1:3

    nextAxis(i,j)
    plot(ebsd,kappa{i,j},'micronBar','off')
    hold on; plot(grains.boundary,'linewidth',2); hold off

  end
end

% unify the color rage  - you may also use setColoRange equal
setColorRange([-0.005,0.005])
drawNow(gcm,'figSize','large')

%%
% If you prefer to address the curvature by pixel coordinates rather than by
% a linear index, <EBSD.gridify.html |gridify|> the map first. The tensor
% then comes back in the shape of the map, and |kappa(2,3)| is the curvature
% of the pixel in row 2, column 3.

kappaGrid = ebsd.gridify.curvature;

kappaGrid(2,3)

%% The incomplete dislocation density tensor
% According to Kroener the curvature tensor is directly related to the
% dislocation density tensor.

alpha = kappa.dislocationDensity

%%
% which has the same unit as the curvature tensor and is incomplete as well
% as we can see when looking at a particular one.

alpha(2)

%% Crystallographic Dislocations
% The central idea of Pantleon is that the dislocation density tensor is
% build up by single dislocations with different densities such that the
% total energy is minimum. Depending on the atomic lattice different
% dislocation systems have to be considered. In present case of a body
% centered cubic (bcc) material 48 edge dislocations and 4 screw
% dislocations have to be considered. Those principle dislocations are
% defined in MTEX either by their Burgers and line vectors or by

dS = dislocationSystem.bcc(ebsd.CS)

%%
% Here the norm of the Burgers vectors is important

% size of the unit cell
a = norm(ebsd.CS.aAxis);

% in bcc and fcc the norm of the burgers vector is sqrt(3)/2 * a
[norm(dS(1).b), norm(dS(end).b), sqrt(3)/2 * a]


%% The Energy of Dislocations
% The energy of each dislocation system can be stored in the property |u|.
% By default this value it set to 1 but should be changed according to the
% specific model and the specific material.
%
% According to Hull & Bacon the energy U of edge and screw dislocations is
% given by the formulae
%
% $$ U_{\mathrm{screw}} = \frac{Gb^2}{4\pi} \ln \frac{R}{r_0} $$
%
% $$ U_{\mathrm{edge}} = \frac{1}{(1-\nu)} U_{\mathrm{screw}} $$
%
% where
%
% * |G| is the shear modulus
% * |b| is the length of the Burgers vector
% * |nu| is the Poisson ratio
% * |R| is the outer cut off radius
% * |r_0| is the radius of the dislocation core
%
% In this example we assume
% $$ U_{\mathrm{edge}} = 1 $$
% $$ U_{\mathrm{screw}} = 1-\nu $$

nu = 0.3;

% energy of the edge dislocations
dS(dS.isEdge).u = 1;

% energy of the screw dislocations
dS(dS.isScrew).u = 1 - nu;

%%
% There is no single accepted way of setting these energies. Formulae in use
% include |U = 1 - nu| as above, and |U = c * G * |b|^2| with |G| the shear
% modulus, i.e. an energy per unit length squared. Which one is appropriate
% depends on the model you are comparing against, so |u| is left for you to
% set rather than being fixed by MTEX.

%%
% A single dislocation causes a deformation that can be represented by
% the rank one tensor

dS(1).tensor

%%
% Note that the unit of this tensors is the same as the unit used for
% describing the length of the unit cell, which is in most cases Angstrom
% (au). Furthermore, we observe that the tensor is given with respect to
% the crystal reference frame while the dislocation density tensors are
% given with respect to the specimen reference frame. Hence, to make them
% compatible we have to rotate the dislocation tensors into the specimen
% reference frame as well. This is done by

dSRot = ebsd.orientations * dS


%% Fitting Dislocations to the incomplete dislocation density tensor
% Now we are ready for fitting the dislocation tensors to the dislocation
% density tensor in each pixel of the map. This is done by the command
% <curvatureTensor.fitDislocationSystems.html |fitDislocationSystems|>.

[rho,factor] = fitDislocationSystems(kappa,dSRot);

%%
% As result we obtain a matrix of densities |rho| such that the product
% with the dislocation systems yields the incomplete dislocation density
% tensors derived from the curvature, i.e.,

% the restored dislocation density tensors
alpha = sum(dSRot.tensor .* rho,2);

% we have to set the unit manually since it is not stored in rho
alpha.opt.unit = '1/um';

% the restored dislocation density tensor for pixel 2
alpha(2)

% the dislocation density derived from the curvature in pixel 2
kappa(2).dislocationDensity

%%
% we may also restore the complete curvature tensor with

kappa = alpha.curvature

%%
% and plot it as we did before

newMtexFigure('nrows',3,'ncols',3);

% cycle through all components of the tensor
for i = 1:3
  for j = 1:3

    nextAxis(i,j)
    plot(ebsd,kappa{i,j},'micronBar','off')
    hold on; plot(grains.boundary,'linewidth',2); hold off

  end
end

setColorRange([-0.005,0.005])
drawNow(gcm,'figSize','large');


%% The total dislocation energy
% The unit of the densities |h| in our example is 1/um * 1/au where 1/um
% comes from the unit of the curvature tensor an 1/au from the unit of the
% Burgers vector. In order to transform |h| to SI units, i.e., 1/m^2 we
% have to multiply it with 10^16. This is exactly the values returned as
% the second output |factor| by the function
% <curvatureTensor.fitDislocationSystems.html |fitDislocationSystems|>.

factor

%%
% Multiplying the densities |rho| with this factor and the individual
% energies of the the dislocation systems we end up with the total
% dislocation energy, which is what |calcGND| returned at the top of this
% page. Lets plot it at a logarithmic scale

close all
plot(ebsd,factor*sum(abs(rho .* dSRot.u),2),'micronbar','off')
mtexColorMap('hot')
mtexColorbar

set(gca,'ColorScale','log'); % this works only starting with Matlab 2018a
set(gca,'CLim',[1e11 5e14]);

hold on
plot(grains.boundary,'linewidth',2)
hold off
