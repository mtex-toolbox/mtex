%% Piezoelectricity in Quartz
%
% Mechanical stress creates electric displacement in a piezoelectric
% crystal. This is the *direct piezoelectric effect*. An electric field can
% also create strain, which is the converse effect.
%
% The direct effect relates a symmetric stress tensor $\sigma$ to electric
% displacement $D$ through the rank three piezoelectric strain tensor $d$:
%
% $$ D_i = d_{ijk}\,\sigma_{jk}. $$
%
% This page assumes the tensor rank and compact notation introduced in
% <TensorDefinition.html Defining Tensorial Properties>. Read
% <TensorImport.html Importing Tensor Data> first for units, crystal frames,
% and the |doubleConvention| used by the file below.

plottingConvention.default('y↑→x');

% define the quartz crystal symmetry and crystal frame
csQuartz = crystalSymmetry('32',[4.916 4.916 5.4054],...
  'X||a*','Z||c','mineral','Quartz');

% load the right-handed quartz piezoelectric strain tensor
quartzFile = fullfile(mtexDataPath,'tensor','Single_RH_quartz_poly.P');
P = tensor.load(quartzFile,csQuartz,...
  'propertyname','piezoelectric strain','unit','pC/N',...
  'doubleConvention');

setMTEXpref('defaultColorMap',blue2redColorMap);

%% Why crystal symmetry matters
%
% A material-property tensor must be invariant under every operation of its
% crystal point group. Inversion changes the sign of a polar rank three
% tensor. A centrosymmetric crystal must therefore have $d=0$.
%
% Piezoelectricity is allowed in 20 of the 32 crystallographic point groups:
% every noncentrosymmetric group except |432|. Quartz belongs to point group
% |32|, so symmetry permits the effect and repeats it about the threefold
% crystal axis.
%
% Handedness remains important even though the point-group symbol is the
% same. Inverting right-handed quartz produces left-handed quartz and
% reverses the piezoelectric tensor. The filename identifies |P| as the
% right-handed form.

%% The signed longitudinal response
%
% <tensor.directionalMagnitude.html |directionalMagnitude|> contracts the
% same unit direction $n$ into all three indices:
%
% $$ q(n) = d_{ijk}\,n_i n_j n_k. $$
%
% For a uniaxial stress along $n$, $q(n)$ is the electric-displacement
% component along that direction per unit stress. It is a signed
% longitudinal coefficient, not the magnitude of the displacement vector.

q = P.directionalMagnitude;

% plot one symmetry-reduced sector
plot(P);
mtexColorbar('title','longitudinal coefficient (pC/N)');

%%
% The sector contains both positive and negative response. Blue and red
% therefore mean opposite signs of the longitudinal component, not weak and
% strong polarization.
%
% A rank three directional response is odd: $q(-n)=-q(n)$. Plotting both
% hemispheres makes that sign reversal explicit.

close all;
plot(P,'complete','smooth','upper','lower');
mtexColorbar('title','longitudinal coefficient (pC/N)');

%%
% The same threefold pattern occurs on the two hemispheres with red and blue
% exchanged at antipodal directions. This is the sign reversal expected for
% an odd-rank tensor.

%% A radial surface
%
% <S2Fun.surf.html |surf|> can use the absolute response as distance from the
% origin and the colour as its sign. The |'noScaling'| option keeps the
% physical zero and the original pC/N values.

close all;
surf(q,'noScaling');
mtexColorbar('title','longitudinal coefficient (pC/N)');

%%
% The six lobes have the same radial magnitude in antipodal pairs, while
% their colours have opposite signs. The surface meets the origin in
% directions where the longitudinal response is zero.

%% Planar sections
%
% <S2Fun.plotSection.html |plotSection|> draws the signed response as a polar
% radius in a chosen plane. A negative radius is placed in the opposite
% direction, so each curve is traced twice. Use the coloured hemisphere
% plots above, rather than these outlines, to read the sign.
%
% The basal plane is normal to z.

close all;
plotSection(q,vector3d.Z);
xlabel('x');
ylabel('y');
drawNow(gcm);

%%
% The basal section is a three-petal rose. Its threefold repetition is the
% clearest planar expression of quartz point group |32|.
%
% A vertical section normal to x has a different outline.

close all;
plotSection(q,vector3d.X);
ylabel('y');
zlabel('z');
drawNow(gcm);

%%
% This section is a single oval rather than a three-petal rose because its
% plane contains the threefold z axis instead of cutting across it.

%% A polycrystal average needs handedness
%
% The Tongue quartzite data contain one orientation for each of 382 grains.
% Mainprice, Lloyd, and Casey (1993) explain a decisive limitation of these
% measurements: routine electron-channelling patterns did not determine the
% handedness of each quartz grain. Every grain was indexed as right-handed.
% The paper therefore states that piezoelectricity cannot be calculated from
% this orientation set.

orientationFile = fullfile(mtexDataPath,'orientation',...
  'Tongue_Quartzite_Bunge_Euler');
ori = orientation.load(orientationFile,csQuartz,...
  'ColumnNames',{'Euler 1','Euler 2','Euler 3'});

orientationCount = length(ori)

%%
% The calculation below is still instructive as a counterexample. It uses
% <orientation.calcTensor.html |calcTensor|> to rotate the right-handed
% tensor by every orientation and take their unweighted arithmetic mean.
% The result is an *apparent* aggregate in which all 382 grains have been
% assumed to be right-handed. It is not a prediction for the rock.

apparentMean = ori.calcTensor(P);
qApparent = apparentMean.directionalMagnitude;

close all;
plot(apparentMean,'complete','smooth','upper','lower');
mtexColorbar('title','apparent longitudinal coefficient (pC/N)');

responseRanges = array2table(...
  [min(q),max(q);min(qApparent),max(qApparent)],...
  'VariableNames',{'minimum','maximum'},...
  'RowNames',{'single crystal','all right-handed average'})

%%
% The single-crystal range is -2.3000 to 2.3000 pC/N. Under the deliberately
% false all-right-handed assumption, the range is -0.5940 to 0.5940 pC/N,
% or 25.8 percent of the single-crystal extreme.
%
% Differently oriented grains partly cancel, which explains the reduction.
% Unknown left-handed grains can reverse additional contributions. Their
% number and orientations are absent from this data set, so the apparent
% average cannot be corrected without new handedness information.

%% Next
%
% <BirefringenceDemo.html Birefringence> continues with a rank two optical
% property, whose even rank makes its directional response antipodal.
% <TensorAverage.html Tensor Averages> develops Voigt, Reuss, and Hill
% estimates for elastic stiffness and explains their mechanical assumptions.

%% Further reading
%
% * D. Mainprice, G.E. Lloyd, and M. Casey,
% <https://doi.org/10.1016/0191-8141(93)90162-4 Individual orientation
% measurements in quartz polycrystals: advantages and limitations for
% texture and petrophysical property determinations>, _Journal of Structural
% Geology_ 15 (1993), 1169-1187, documents the 382-grain data and its
% handedness limitation.
% * <https://dictionary.iucr.org/Piezoelectricity IUCr Online Dictionary of
% Crystallography: Piezoelectricity> lists the 20 piezoelectric point groups
% and relates the direct and converse tensors.
% * <https://standards.ieee.org/ieee/176/356/ IEEE Std 176-1987>, _IEEE
% Standard on Piezoelectricity_, specifies quartz axes, signs, and contracted
% notation. The standard was withdrawn in 2000.
% * J.F. Nye, <https://search.worldcat.org/title/11114089 Physical Properties
% of Crystals: Their Representation by Tensors and Matrices>, Oxford
% University Press, 1985, develops tensor representation surfaces and crystal
% symmetry.
% * C. Frondel,
% <https://search.worldcat.org/title/The-System-of-Mineralogy-%3A-vol.-III-Silica-Minerals/oclc/500448822
% The System of Mineralogy, Volume III: Silica Minerals>, 7th ed., Wiley,
% 1962, is the source named in the bundled quartz coefficient file.

%%

setMTEXpref('defaultColorMap',WhiteJetColorMap);

%#ok<*NOPTS>
