%% Reconstructing a Crystal Habit with Smorf
%
%%
% <CrystalShapes.html Crystal Shapes> explains how MTEX builds a polyhedron
% from face normals. This page shows how to estimate the relative face
% distances from a published drawing with the
% <https://www.smorf.nl/draw.php Smorf crystal drawing tool>, then transfer
% the result to MTEX.
%
% The example reproduces the olivine growth form in
% <https://doi.org/10.1093/petrology/egs077 Welsch et al. (2013)>.
%
% <<smorf_1.png>>
%
% Notice the broad (010) and (110) faces, the narrow (001) cap and the
% bevels formed by the other three crystal forms. These relative face sizes
% are the target of the reconstruction.
%
% A *crystal habit* is the characteristic external shape of a crystal and
% the development of its forms. The model reconstructed here is an
% idealized habit, not the measured three-dimensional morphology of an EBSD
% grain. Its fitted distances are geometric parameters, not growth rates or
% surface energies.

plottingConvention.default('y↑→x');

%% Match the Symmetry and Unit Cell
%
% Smorf is a free browser-based drawing tool maintained by Mark Holtkamp.
% Select the point group and enter the unit-cell lengths and angles from the
% source you want to reproduce. For an imported phase, these values are
% available from its crystal symmetry.
%
% Choose |Crystallographic (Kristall2000)| for the face-distance
% interpretation. This is the convention that transfers to the MTEX
% construction below; the other choices scale the face normals differently.
%
% <<smorf_2.png>>
%
% The screenshot pairs point group |mmm| with the three forsterite lattice
% parameters and highlights the required distance convention. The same
% crystal symmetry in MTEX is

cs = crystalSymmetry('mmm',[4.756 10.207 5.98], ...
  'mineral','Forsterite');

%% Enter the Crystal Forms
%
% A crystal form is the set of faces generated from one face by the point
% group. Enter one representative Miller index for every form visible in
% views along $\vec a$, $\vec b$ and $\vec c$. Start every form at distance
% 1 so that differences in the first drawing come only from the lattice
% metric and symmetry.
%
% <<smorf_3.png>>
%
% The slide sets the published views along $\vec a$, $\vec b$ and $\vec c$
% beside the Smorf drawing of the same views, with the interfacial angles to
% compare against. The equal-distance drawing in the previous screenshot is
% only a starting block: at distance 1 the (010), (001) and (110) forms do
% not reach the surface at all.
% The same six plane normals are a list of
% <Miller.Miller.html |Miller|> indices in MTEX.

N = Miller({0,1,0},{0,0,1},{0,2,1}, ...
  {1,1,0},{1,0,1},{1,2,0},cs);

%% Tune the Face Distances
%
% Change one distance at a time and redraw the crystal. A larger distance
% moves that form away from the origin, so the neighbouring forms cut its
% faces back and they shrink, until the form can disappear from the
% polyhedron altogether. Steps of 0.05 are small enough for this example.
%
% Match the largest faces and the overall aspect ratio first. Then tune the
% smaller bevels. Smorf does not redraw automatically, so press _Draw
% crystal_ after each change.

dist = [0.4, 1.3, 1.4, 1.05, 1.85, 1.35];

%%
% <<smorf_4.png>>
%
% The tuned drawing now has the broad (010) and (110) sides, the small (001)
% cap and the bevels of the other three forms seen in the source figure.
% Only relative distances matter:
% multiplying every entry of |dist| by the same number leaves the normalized
% shape unchanged.

%% Transfer the Distances to MTEX
%
% <crystalShape.crystalShape.html |crystalShape|> describes each limiting
% plane by a normal $\mathbf{n}$ and the half-space
% $\mathbf{x}\cdot\mathbf{n}\leq 1$. A longer normal therefore moves its
% plane inward. To preserve the distances entered in Smorf, divide each
% Miller normal by its corresponding distance:
%
% $$\mathbf{n}_{\mathrm{MTEX}} =
% \mathbf{n}_{hkl} / d_{\mathrm{Smorf}}.$$

cS = crystalShape(N ./ dist)

%%

plot(cS,'colored');

%%
% The MTEX figure reproduces the published habit. The (010) and (110) faces
% form the broad prism sides, the (021) faces terminate the ends around the
% small (001) caps, and the narrow (120) and (101) faces truncate the
% remaining edges and corners.

%% Check the Developed Faces
%
% The constructor applies the point group to each input normal. The
% multiplicity is the number of symmetry-related faces in a form. The table
% separates the area of one face from the total area of its complete form.

multiplicity = N.multiplicity;
areaPerFace = zeros(size(multiplicity));
formArea = zeros(size(multiplicity));
for k = 1:length(N)
  areas = cS(N(k).symmetrise('unique')).faceArea;
  areaPerFace(k) = mean(areas);
  formArea(k) = sum(areas);
end
formName = ['(010)';'(001)';'(021)';'(110)';'(101)';'(120)'];
formSummary = table(formName,dist(:),multiplicity,areaPerFace,formArea, ...
  'VariableNames',{'Form','Distance','Multiplicity','AreaPerFace','FormArea'})

%%
% The six input forms generate 20 faces. An individual (010) face is the
% largest at 0.13897, just above an individual (021) face at 0.13840. The
% four (021) and four (110) faces have the largest total form areas, 0.55362
% and 0.53841. The two (001) caps are the smallest at 0.01977 each.
%
% These areas belong to MTEX's normalized polyhedron and have no physical
% unit. Use them to compare relative face development within this shape.

%% Further Reading
%
% * <https://dictionary.iucr.org/Habit IUCr Online Dictionary of
% Crystallography: Habit> defines habit and distinguishes face development.
% * B. Welsch, F. Faure, V. Famin, A. Baronnet and P. Bachèlery,
% <https://doi.org/10.1093/petrology/egs077 Dendritic Crystallization: A
% Single Process for all the Textures of Olivine in Basalts?>, _Journal of
% Petrology_ 54 (2013), 539--574, is the source of the target growth form.
% * J. Enderlein,
% <https://library.wolfram.com/infocenter/Articles/3279 A Package for
% Displaying Crystal Morphology>, _The Mathematica Journal_ 7(1) (1997),
% 72--78, describes the geometric construction underlying |crystalShape|.

%% Next
%
% Return to <CrystalShapes.html Crystal Shapes> to rotate, scale and place
% this idealized habit as an orientation glyph. See
% <CrystalDirections.html Miller Indices> for the distinction between plane
% normals and crystal directions, and <CrystalSymmetries.html Crystal
% Symmetries> for point groups and unit-cell definitions.

%#ok<*NOPTS>
