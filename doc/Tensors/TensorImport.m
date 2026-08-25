%% Importing Tensor Data
%
% Importing a coefficient table is only the first step in defining a tensor.
% The physical property, unit, compact-matrix convention, crystal symmetry,
% and crystal frame must agree with the source that published the values.
% MTEX cannot infer that scientific context from plausible-looking numbers.
%
% This page assumes the ranks and physical classes introduced in
% <TensorDefinition.html Defining Tensorial Properties>.
% Read <CrystalReferenceSystem.html Crystal Reference System> first if the
% alignment between lattice axes and Cartesian axes is new to you.
%
% A reference frame is the coordinate system in which data are expressed.
% It is distinct from crystal symmetry, which states the point group under
% which the property is invariant.

%% Load a generic tensor
%
% <tensor.load.html |tensor.load|> selects a file interface automatically.
% Interface detection identifies how to read the coefficient table; it does
% not establish what the coefficients mean.
%
% The bundled quartz file contains descriptive header lines, but its |.P|
% interface imports only the compact $3\times6$ coefficient table.
% The point group and alignment options below attach the crystal frame used
% by the source. The alignment belongs to the frame, not to point group |32|.

% define the quartz crystal symmetry and frame
csQuartz = crystalSymmetry('32',[4.916 4.916 5.4054],...
  'X||a*','Z||c','mineral','Quartz');

% define the file name
quartzFile = fullfile(mtexDataPath,'tensor','Single_RH_quartz_poly.P');

% import and display the piezoelectric strain tensor
P = tensor.load(quartzFile,csQuartz,...
  'propertyname','piezoelectric strain','unit','pC/N',...
  'doubleConvention')

%% Read the import summary
%
% The display is an import audit. It identifies a rank 3 tensor in the
% quartz crystal frame, labels its values in pC/N, and reports
% |doubleConvention: true| before printing the compact coefficient table.
%
% The |propertyname| and |unit| options are labels stored with |P|.
% They do not convert the numbers, so the file values must already be in
% pC/N. These labels are the imported object's record of the physical meaning
% and unit; retain the publication itself as the record of provenance.

%% Check the compact-matrix convention
%
% The six compact columns represent the index pairs
% $(11,22,33,23,13,12)$. With |doubleConvention|, columns 4 to 6 contain
% twice the corresponding off-diagonal tensor components.
% MTEX divides those entries by two when expanding the table to
% $3\times3\times3$.
%
% This is the engineering-shear convention used by the quartz file.
% Do not infer it from the shape of a table: omitting the option for this
% source would silently double part of the tensor.

%% Load a physically specific tensor
%
% Common physical tensors have dedicated loaders. The
% <stiffnessTensor.stiffnessTensor.html |stiffnessTensor.load|> method returns
% the physically typed class, fixes rank 4, uses the stiffness form of the
% Voigt convention, and supplies GPa as the default unit label.
%
% Those defaults are correct for this olivine file, but they are still
% assumptions rather than unit conversion or validation. The file also gives
% a density of 3355 kg/m$^3$. The numeric interface does not attach it, so it
% is converted to 3.355 g/cm$^3$ and supplied explicitly.

% define the file name
olivineFile = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

% define the olivine crystal symmetry and frame
csOlivine = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],...
  'mineral','Olivine');

% import and display the elastic stiffness tensor
C = stiffnessTensor.load(olivineFile,csOlivine,'density',3.355)

%% Read the typed result
%
% The display now reports a rank 4 |stiffnessTensor| in GPa, the attached
% density, and the $6\times6$ Voigt matrix. The typed result provides elastic
% moduli and wave-velocity operations that a generic |tensor| does not.
% <WaveVelocities.html Wave Velocities> explains why density is required for
% seismic velocities.

%% Check compatibility with crystal symmetry
%
% <tensor.checkSymmetry.html |checkSymmetry|> tests whether each imported
% tensor is invariant under its attached crystal point group.
% The two logical values below correspond to quartz and olivine.

symmetryMatches = [checkSymmetry(P),checkSymmetry(C)]

%%
% Both values are true for these files. This check can detect an incompatible
% point group, and for the quartz file it also catches a missing
% |'doubleConvention'|. It cannot verify units, axis sense, handedness, or
% whether the correct physical property was selected.
% Compare those items with the source publication before using the tensor.

%% Next
%
% Continue with <TensorArithmetics.html Tensor Arithmetic> to rotate and
% contract imported tensors. <TensorVisualisation.html Tensor Visualization>
% shows how to inspect their directional dependence, and
% <TensorAverage.html Tensor Averages> combines a single-crystal property with
% orientations or an ODF.
%
% The quartz example continues in <PiezoElectricity.html Piezoelectricity>.
% The olivine example continues in <AnisotropicTheory.html Anisotropic
% Elasticity> and <WaveVelocities.html Wave Velocities>.

%% Further reading
%
% * J. F. Nye, <https://search.worldcat.org/title/11114089 Physical
%   Properties of Crystals: Their Representation by Tensors and Matrices>,
%   Oxford University Press, 1985, develops crystal axes, tensor components,
%   and contracted matrix notation.
% * A. Authier, editor, <https://doi.org/10.1107/97809553602060000113
%   International Tables for Crystallography, Volume D: Physical Properties
%   of Crystals>, 2nd ed., IUCr, 2014, tabulates crystal tensor symmetries and
%   Voigt notation.
% * <https://standards.ieee.org/ieee/176/356/ IEEE Std 176-1987>, _IEEE
%   Standard on Piezoelectricity_, specifies historical quartz axis, sign,
%   and compact-matrix conventions. The standard was withdrawn in 2000.
% * E. H. Abramson, J. M. Brown, L. J. Slutsky, and J. Zaug,
%   <https://doi.org/10.1029/97JB00682 The elastic constants of San Carlos
%   olivine to 17 GPa>, _Journal of Geophysical Research_ 102 (1997),
%   12253-12263, is the source of the olivine stiffness example.

%#ok<*NOPTS>
