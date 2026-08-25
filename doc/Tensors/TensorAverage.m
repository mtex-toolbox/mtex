%% Tensor Averages
%
%%
% A polycrystal has no single stiffness tensor. Each grain has its own,
% turned into the specimen frame by its own orientation, and what the
% aggregate does under load depends on how the stress and strain distribute
% between them - which the orientations alone do not determine.
%
% What can be computed are bounds. This page computes them from EBSD data
% and from an ODF, for a rock of glaucophane and epidote.

% set up a nice colormap
setMTEXpref('defaultColorMap',blue2redColorMap);

mtexdata epidote

% visualize a subset of the data
plot(ebsd(inpolygon(ebsd,[2000 0 1400 375])))

%% Cleaning the data first
%
% An average is only as good as the orientations that enter it, so the
% badly fitted measurements go first - here everything with a mean angular
% deviation above 1.3 degrees.

% define maximum acceptable MAD value
MAD_MAXIMUM= 1.3;

% eliminate all measurements with MAD larger than MAD_MAXIMUM
ebsd(ebsd.mad >MAD_MAXIMUM) = []

plot(ebsd(inpolygon(ebsd,[2000 0 1400 375])))

%% The single crystal tensors
%
% Each phase needs its own stiffness tensor, and each tensor needs the
% crystal frame it was measured in - the |'X||a*','Z||c'| below is part of
% the data, not a formality. Glaucophane, from Bezacier et al. 2010
% (Tectonophysics):

CS_Tensor_glaucophane = crystalSymmetry('2/m',[9.5334,17.7347,5.3008],...
  [90.00,103.597,90.00]*degree,'X||a*','Z||c','mineral','Glaucophane');

%%
% with the density in g/cm^3

rho_glaucophane = 3.07;

%%
% and the coefficients $C_{ij}$ in Voigt matrix notation

Cij = [[122.28   45.69   37.24   0.00   2.35   0.00];...
  [  45.69  231.50   74.91   0.00  -4.78   0.00];...
  [  37.24   74.91  254.57   0.00 -23.74   0.00];...
  [   0.00    0.00    0.00  79.67   0.00   8.89];...
  [   2.35   -4.78  -23.74   0.00  52.82   0.00];...
  [   0.00    0.00    0.00   8.89   0.00  51.24]];

%%
% <stiffnessTensor.stiffnessTensor.html |stiffnessTensor|> puts the three
% together.

C_glaucophane = stiffnessTensor(Cij,CS_Tensor_glaucophane,'density',rho_glaucophane);

%%
% Epidote, from Aleksandrov et al. 1974, 'Velocities of elastic waves in
% minerals at atmospheric pressure and increasing the precision of elastic
% constants by means of EVM (in Russian)', Izv. Acad. Sci. USSR, Geol.
% Ser.10, 15-24:

CS_Tensor_epidote = crystalSymmetry('2/m',[8.8877,5.6275,10.1517],...
  [90.00,115.383,90.00]*degree,'X||a*','Z||c','mineral','Epidote');

%%

rho_epidote = 3.45;

%%

Cij = [[211.50    65.60    43.20     0.00     -6.50     0.00];...
  [  65.60   239.00    43.60     0.00    -10.40     0.00];...
  [  43.20    43.60   202.10     0.00    -20.00     0.00];...
  [   0.00     0.00     0.00    39.10      0.00    -2.30];...
  [  -6.50   -10.40   -20.00     0.00     43.40     0.00];...
  [   0.00     0.00     0.00    -2.30      0.00    79.50]];

% And now we define the Epidote stiffness tensor as a MTEX variable
C_epidote = stiffnessTensor(Cij,CS_Tensor_epidote,'density',rho_epidote);

%% The average over an EBSD map
%
% <EBSD.calcTensor.html |calcTensor|> takes the map and one tensor per
% phase, in the order the phases were named, and returns three averages.

[CVoigt,CReuss,CHill] =  calcTensor(ebsd({'Epidote','Glaucophane'}),C_glaucophane,C_epidote);

%%
% For this rock the bulk modulus comes out as 103.6 GPa by Voigt, 94.4 by
% Reuss and 99.0 by Hill; the shear modulus as 66.5, 60.9 and 63.7.
%
% The three differ because they assume different things about what the
% grains do to each other.
%
% The *Voigt* average assumes the strain is the same everywhere, equal to
% the macroscopic strain, and averages the stiffness over the orientations:
%
% $  \left<T\right>^{\text{Voigt}} = \sum_{m=1}^{M}  T(\mathtt{ori}_{m})$
%
% The *Reuss* average assumes instead that the stress is the same
% everywhere, and averages the compliance:
%
% $ \left<T\right>^{\text{Reuss}} = \left[ \sum_{m=1}^{M}  T(\mathtt{ori}_{m})^{-1} \right]^{-1}$
%
% Neither can be true - a uniform strain field violates the equilibrium of
% stresses across grain boundaries, a uniform stress field violates
% compatibility - but they bound the truth from above and below. How far
% apart they are is a measure of how anisotropic the phases are: 10 percent
% here, and nothing for an isotropic material.
%
% The *Hill* average is the arithmetic mean of the two. Hill (1952) observed
% that it usually lands near the measured value, and there is no physical
% argument for why it should - it is a useful convention rather than a
% result.

%% One phase at a time
%
% With a single phase the syntax is the same with one tensor:

[CVoigt_glaucophane,CReuss_glaucophane,CHill_glaucophane] =  calcTensor(ebsd('glaucophane'),C_glaucophane);

%% From an ODF instead
%
% The average does not need the map - only the distribution of orientations.
% Estimating an ODF for the glaucophane first:

odf_gl = calcDensity(ebsd('glaucophane').orientations,'halfwidth',10*degree);

%%
% and averaging over it:

[CVoigt_glaucophane, CReuss_glaucophane, CHill_glaucophane] =  ...
  calcTensor(odf_gl,C_glaucophane);

%%
% The result agrees with the average over the measurements to within a few
% tenths of a GPa - 102.7 against 102.7 for the Voigt bulk modulus, 91.7
% against 92.1 for the Reuss one. That is the check that the ODF captured
% the orientations, and it is also the route to take when the orientations
% come from pole figures and there is no map to average over.

%% What the average is for
%
% An averaged stiffness tensor predicts how the rock transmits waves, which
% is what connects a thin section to a seismic measurement:

plotSeismicVelocities(CHill_glaucophane)

%%
% The P wave velocity runs from 6.85 to 8.44 km/s depending on direction, an
% anisotropy of 21 percent - a wave crossing this rock arrives at a time
% that depends on which way it travelled.
%
% <CPOSeismicProperties.html Seismic Properties> takes this further,
% including how to weight several phases by their modal composition.

%#ok<*ASGLU>
%#ok<*NOPTS>
