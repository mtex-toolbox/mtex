%% Birefringence
%
% An anisotropic crystal has two permitted polarization directions for most
% light-propagation directions. The two waves travel at different speeds.
% Their refractive-index difference is the *directional birefringence*.
%
% Between crossed polarizers, this speed difference becomes a phase lag.
% Some wavelengths are then transmitted more strongly than others, producing
% the interference colours seen in a petrographic microscope.
%
% This page builds a rank-two refractive-index tensor for olivine. It then
% predicts birefringence, optical axes, and interference colours from EBSD
% orientations. The tensor and orientation conventions are introduced in
% <TensorDefinition.html Tensor Definition> and
% <OrientationDefinition.html Orientations>. The distinction between crystal
% symmetry and its frame is explained in <CrystalReferenceSystem.html Crystal
% Reference Systems>.

%% Load an orientation map
%
% The olivine data uses transverse direction (TD) upward and rolling direction
% (RD) to the right. The explicit plotting convention states that specimen
% frame rather than inheriting the session default.

plottingConvention.default('y↑→x');
mtexdata olivine silent

[grains,ebsd] = calcGrains(ebsd,'minPixel',5);
olivine = ebsd('olivine');

ipfKey = ipfColorKey(olivine);
ipfColors = ipfKey.orientation2color(olivine.orientations);

plot(olivine,ipfColors);
hold on
plot(grains.boundary,'lineWidth',1.5);
hold off
drawNow(gcm,'final');

%%
% This inverse pole figure (IPF) map is the orientation reference for the
% optical maps below. Neighbouring grains have different colours because
% their crystal frames have different orientations in the specimen frame.
% These IPF colours do not represent an optical response.

%% Build the refractive-index tensor
%
% The refractive index is $n=c/v$, so a larger index means a slower wave.
% A symmetric rank-two tensor stores its directional dependence.
% <refractiveIndexTensor.refractiveIndexTensor.html
% |refractiveIndexTensor|> attaches that tensor to the crystal frame.
%
% Orthorhombic olivine is optically biaxial. Its three principal indices are
% $n_{\alpha}<n_{\beta}<n_{\gamma}$, with $n_{\alpha}$ parallel to b,
% $n_{\beta}$ parallel to c, and $n_{\gamma}$ parallel to a. The order in
% the diagonal matrix is therefore a, b, c.
%
% The mmm point group forces the off-diagonal components to zero in this
% symmetry-aligned crystal frame. Symmetry constrains the property, while the
% frame states which axes its components refer to. MTEX carries both with the
% tensor.

cs = olivine.CS;

nAlphaFo = 1.635;
nBetaFo = 1.651;
nGammaFo = 1.670;
rIFo = refractiveIndexTensor(...
  diag([nGammaFo,nAlphaFo,nBetaFo]),cs);

nAlphaFa = 1.827;
nBetaFa = 1.869;
nGammaFa = 1.879;
rIFa = refractiveIndexTensor(...
  diag([nGammaFa,nAlphaFa,nBetaFa]),cs);

%% An illustrative solid-solution model
%
% Olivine forms a solid solution between forsterite and fayalite. For this
% example, the forsterite mole fraction is fixed at 0.86 and the two end-member
% tensors are interpolated linearly. This is a modelling assumption, not a
% composition inferred from the EBSD map.

xFo = 0.86;
rI = xFo*rIFo + (1-xFo)*rIFa;

principalIndices = array2table(...
  [diag(rIFo.M).';diag(rIFa.M).';diag(rI.M).'],...
  'VariableNames',{'n_a','n_b','n_c'},...
  'RowNames',{'forsterite','fayalite','Fo86_model'})

%%
% The rows show why the axis assignment matters. Sorting the three values and
% placing them on a, b, c in that order would describe a different material.
% The tensor must also remain attached to the same crystal frame as the
% orientations that will rotate it.

%% Directional birefringence
%
% For a propagation direction |vProp|, MTEX restricts the optical response to
% the plane perpendicular to that direction. The two eigenvectors in this
% plane are |pMin| and |pMax|. The former has the lower index and is the fast
% polarization direction; the latter is the slow direction.

vProp = Miller(1,1,1,cs);
[deltaN,pMin,pMax] = rI.birefringence(vProp)

%%
% The printed scalar is $\Delta n=n_{\mathrm{slow}}-n_{\mathrm{fast}}$ for
% the (111) plane normal. The two printed vectors are perpendicular to that
% direction and to each other. They are polarization directions, not two
% different propagation rays.

%% Birefringence over every propagation direction
%
% Omitting |vProp| makes <refractiveIndexTensor.birefringence.html
% |birefringence|> return a spherical function and two spherical axis fields.

[deltaNSphere,pMinField,pMaxField] = rI.birefringence;

plot3d(deltaNSphere,'complete');
mtexColorMap parula
mtexColorbar

hold on
quiver3(pMinField,'color','white');
quiver3(pMaxField);
hold off

%%
% Colour encodes $\Delta n$ on the unit sphere. The white and black line
% fields show the fast and slow polarization directions. The response is
% antipodal: reversing the propagation direction does not change the
% birefringence.

%% Optical axes
%
% An optical axis is a propagation direction for which the perpendicular
% section has equal indices and hence zero birefringence. A biaxial crystal
% has two such axes. Each axis is a line, so its positive and negative senses
% are physically equivalent.

vOptical = rI.opticalAxis
opticalAxisResidual = rI.birefringence(vOptical)

hold on
vOptical.antipodal = false;
arrow3d([vOptical,-vOptical],'faceColor','red');
hold off

%%
% The residual is numerical roundoff rather than physical birefringence.
% Red arrows mark both senses of both optical axes on the preceding surface.
% They point at the dark blue minima where $\Delta n$ falls to zero.

%% Interference colour between polarizers
%
% An ideal isotropic crystal remains dark between crossed polarizers because
% it does not change the state of polarization. An anisotropic crystal splits
% the incident polarization into fast and slow components. Their retardation
% depends on $\Delta n$, thickness, and wavelength.
%
% <refractiveIndexTensor.spectralTransmission.html |spectralTransmission|>
% integrates the transmitted visible spectrum into an RGB triplet. Thickness
% is specified in nanometres, so 30000 corresponds to 30 micrometres.

vProp = Miller(1,1,1,cs);
thickness = 30000;
[~,pFast] = rI.birefringence(vProp);
polarizer = rotation.byAxisAngle(vProp,30*degree) * pFast;

rgbFromDirection = rI.spectralTransmission(vProp,thickness,...
  'polarizationDirection',polarizer)

%%
% The polarizer above is 30 degrees from the fast direction in the plane
% perpendicular to |vProp|. The same calculation can therefore use |tau|,
% the angle between the polarizer and |pMin|. The RGB values are fractions
% on the display colour scale, not measured intensities.

rgbFromTau = rI.spectralTransmission(vProp,thickness,...
  'tau',30*degree)

%% Vary the polarizer angle
%
% With crossed polarizers, the two components have equal magnitude when
% $\tau=45$ degrees. The three spherical maps show how the colour and
% intensity change as the input polarization turns away from the fast axis.

newMtexFigure('layout',[1,3]);

plot(rI.spectralTransmission(thickness,'tau',15*degree),'rgb');
mtexTitle('$\tau = 15^{\circ}$');

nextAxis
plot(rI.spectralTransmission(thickness,'tau',30*degree),'rgb');
mtexTitle('$\tau = 30^{\circ}$');

nextAxis
plot(rI.spectralTransmission(thickness,'tau',45*degree),'rgb');
mtexTitle('$\tau = 45^{\circ}$');

drawNow(gcm,'final');

%%
% The 45-degree panel is brightest because both permitted waves are excited
% equally. Directions near an optical axis remain dark in every panel because
% their retardation is zero.

%% Vary the analyser angle
%
% The option |phi| is the angle from the polarizer to the analyser.
% Crossed polarizers correspond to $\phi=90$ degrees. Here |tau| stays fixed
% at 45 degrees while the analyser changes.

newMtexFigure('layout',[1,3]);

plot(rI.spectralTransmission(thickness,'tau',45*degree,...
  'phi',30*degree),'rgb');
mtexTitle('$\phi = 30^{\circ}$');

nextAxis
plot(rI.spectralTransmission(thickness,'tau',45*degree,...
  'phi',60*degree),'rgb');
mtexTitle('$\phi = 60^{\circ}$');

nextAxis
plot(rI.spectralTransmission(thickness,'tau',45*degree,...
  'phi',90*degree),'rgb');
mtexTitle('$\phi = 90^{\circ}$');

drawNow(gcm,'final');

%%
% The non-crossed panels retain a bright background that would pass without
% a crystal. At 90 degrees that background is extinguished, leaving only the
% wavelength-dependent signal produced by birefringence.

%% From the crystal frame to the specimen frame
%
% Microscope directions are given in the specimen frame, whereas |rI| is
% expressed in the crystal frame. There are two equivalent calculations.
% One can rotate the tensor into every measured crystal orientation, or map
% the specimen directions back into every crystal frame.
%
% The simulated section below is 22800 nm thick. Its light propagates along
% specimen z and its polarizer points along specimen x.

vPropSpecimen = vector3d.Z;
polarizerSpecimen = vector3d.X;
thickness = 22800;
ori = olivine.orientations;

% rotate one crystal tensor into every measured orientation
rISpecimen = ori * rI;
rgbTensorRoute = rISpecimen.spectralTransmission(...
  vPropSpecimen,thickness,...
  'polarizationDirection',polarizerSpecimen);

plot(olivine,rgbTensorRoute);

%%
% Grains that were merely different IPF colours now acquire colours from the
% optical model. Within-grain variation follows the measured pixel
% orientations. The EBSD data supplies orientation only; thickness and
% composition remain explicit model inputs.

%% Verify the equivalent direction route
%
% An @orientation maps crystal coordinates into specimen coordinates.
% Left division therefore maps each specimen direction into the corresponding
% crystal frame before applying the original tensor.

vPropCrystal = ori \ vPropSpecimen;
polarizerCrystal = ori \ polarizerSpecimen;

rgbDirectionRoute = rI.spectralTransmission(...
  vPropCrystal,thickness,...
  'polarizationDirection',polarizerCrystal);

maxRouteDifference = max(abs(...
  rgbTensorRoute-rgbDirectionRoute),[],'all')

%%
% The maximum channel difference is at floating-point roundoff. This check
% is important because plausible colours do not reveal a reference-frame
% mistake.

%% Package the model as a colour key
%
% A <spectralTransmissionColorKey.html
% |spectralTransmissionColorKey|> stores the tensor, thickness, propagation
% direction, polarizer, and analyser angle. Its defaults reproduce the
% specimen-frame setup above.

colorKey = spectralTransmissionColorKey(rI,thickness);
colorKey.propagationDirection = vector3d.Z;
colorKey.polarizer = vector3d.X;
colorKey.phi = 90*degree;

rgbKey = colorKey.orientation2color(ori);
maxKeyDifference = max(abs(rgbKey-rgbDirectionRoute),[],'all')

%% Visualize the colour key
%
% The sigma sections show the colour assigned to orientations throughout
% orientation space. They are the legend for a map made with this key.

plot(colorKey,'sigma');

%%
% Nearby orientations usually have nearby colours. Rapid changes occur where
% a small orientation change moves a wavelength through an interference
% minimum or maximum, so this key is not an IPF key with a different palette.

%% Circular input polarization
%
% Setting |polarizer| to empty selects the circular-polarization branch of
% the colour key. The response then depends on retardation without selecting
% one linear input direction in the specimen plane.

colorKey.polarizer = [];
rgbCircular = colorKey.orientation2color(ori);

plot(olivine,rgbCircular);

%%
% Compared with the linearly polarized map, the circular-input map removes
% extinction caused only by alignment with a particular polarizer. No grain
% in this map is fully dark, because none is viewed close enough to an
% optical axis for its retardation to vanish.

%% Rotate polarizer and analyser together
%
% Rotating both elements preserves their 90-degree separation while changing
% their orientation in the specimen plane. When this script runs, the map
% sweeps through a quarter turn. Each grain reaches extinction when a fast or
% slow direction aligns with the polarizer.

colorKey.polarizer = vector3d.X;
figure
plotHandle = plot(olivine,colorKey.orientation2color(ori),...
  'micronbar','off','unitCell');
textHandle = text(750,-50,sprintf('%.1f\\circ',0),...
  'color','w','backgroundColor','k');

stepSize = 2.5;

for omega = 0:stepSize:90

  colorKey.polarizer = rotate(vector3d.X,omega*degree);
  plotHandle.FaceVertexCData = colorKey.orientation2color(ori);
  textHandle.String = sprintf('%.1f\\circ',omega);
  drawnow

end

% leave the published frame halfway between extinction positions
omega = 45;
colorKey.polarizer = rotate(vector3d.X,omega*degree);
plotHandle.FaceVertexCData = colorKey.orientation2color(ori);
textHandle.String = sprintf('%.1f\\circ',omega);
drawNow(gcm,'final');

%%
% The published frame is left at 45 degrees so the spatial colour variation
% remains visible. The animation, rather than this final frame alone, shows
% that different grains reach extinction at different rotation angles.

%% What the colour model leaves out
%
% This calculation is a qualitative optical simulation. It uses one
% wavelength-independent refractive-index tensor, a linear Fo-Fa mixture,
% ideal polarizers, and a CIE colour conversion. It omits dispersion of the
% principal indices, absorption, scattering, surface effects, illumination,
% and camera calibration.
%
% Consequently, a matching RGB colour does not by itself validate composition,
% thickness, or orientation. Those quantities need independent measurements
% before the result can be compared quantitatively with a microscope image.

%% The maths behind the interference colour
%
% For a unit propagation direction $\vec v$, the relevant refractive indices
% are the two eigenvalues of the tensor section perpendicular to $\vec v$.
% Their difference is
%
% $$ \Delta n(\vec v)=n_{\mathrm{slow}}(\vec v)
% -n_{\mathrm{fast}}(\vec v). $$
%
% A section of thickness $t$ produces retardation
% $\Gamma=t\Delta n$. At wavelength $\lambda$, the phase lag is
% $2\pi\Gamma/\lambda$. For ideal crossed polarizers the transmitted
% intensity is proportional to
%
% $$ \sin^2(2\tau)\,
% \sin^2\left(\frac{\pi t\Delta n}{\lambda}\right). $$
%
% This explains all three zeros seen above: $\Delta n=0$ along an optical
% axis, $t=0$ for no crystal, and $\tau=0$ or 90 degrees at extinction.

%% Next
%
% <MagneticAnisotropy.html Magnetic Anisotropy> is the next worked physical
% property in this chapter. <TensorAverage.html Tensor Averages> combines
% rotated single-crystal tensors into aggregate properties. For orientation
% maps without an optical model, continue with <EBSDIPFMap.html IPF Maps>.

%% Further reading
%
% * J.F. Nye, <https://search.worldcat.org/title/11114089 Physical Properties
% of Crystals: Their Representation by Tensors and Matrices>, Oxford
% University Press, 1985, develops tensor symmetry and optical properties.
% * W.D. Nesse, <https://search.worldcat.org/search?q=bn%3A9780199846276
% Introduction to Optical Mineralogy>, 4th ed., Oxford University Press,
% 2013, develops indicatrices, biaxial optics, extinction, and interference
% colours.
% * A. Echalier, R.L. Glazer, V. Fülöp, and M.A. Geday,
% <https://doi.org/10.1107/S0907444904003154 Assessing crystallization droplets
% using birefringence>, _Acta Crystallographica D_ 60 (2004), 696-702,
% relates directional birefringence, retardation, optical axes, and crossed
% polarizers.
% * L. Casas, <https://doi.org/10.1107/S1600576718003709 Three-dimensional-
% printing aids in visualizing the optical properties of crystals>,
% _Journal of Applied Crystallography_ 51 (2018), 901-908, explains uniaxial
% and biaxial indicatrices and their optical axes.
% * <https://www.handbookofmineralogy.org/pdfs/forsterite.pdf Forsterite> and
% <https://www.handbookofmineralogy.org/pdfs/fayalite.pdf Fayalite>,
% _Handbook of Mineralogy_, Mineral Data Publishing, 2001, give the principal
% indices and the assignments $X=b$, $Y=c$, and $Z=a$ used above.
% * <https://doi.org/10.25039/CIE.DS.xvudnb9b CIE 1931 colour-matching
% functions, 2 degree observer>, International Commission on Illumination,
% is the standard-observer dataset underlying spectral-to-colour conversion.

%#ok<*NASGU>
%#ok<*ASGLU>
%#ok<*NOPTS>
