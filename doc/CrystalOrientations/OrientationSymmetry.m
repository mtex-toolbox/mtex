%% Symmetrically Equivalent Orientations
%
%%
% A crystal cannot distinguish settings related by its point-group
% symmetry. One physical orientation therefore corresponds to a class of
% equivalent orthogonal transformations, not to one stored representative.
% MTEX carries that symmetry with the orientation and uses the whole class
% in symmetry-aware calculations.
%
% This page assumes that an orientation maps crystal coordinates into
% specimen coordinates, as developed in
% <DefinitionAsCoordinateTransform.html Theory>. It also assumes the
% point-group operations introduced in
% <CrystalSymmetries.html Crystal Symmetries>.
%
% A *symmetry* is the point group under which data are invariant. It is
% attached to a reference frame, but is not the frame itself. The crystal
% and specimen symmetries below are therefore attached to opposite sides of
% the orientation map.

plottingConvention.default('y↑→x');

% hexagonal crystal symmetry, with 6 rotations about the c axis
cs = crystalSymmetry('6');

% specimen symmetry with a twofold axis along z
ss = specimenSymmetry('112');

% a generic orientation carrying both symmetries
ori = orientation.byEuler(10*degree,20*degree,30*degree,...
  'Bunge',cs,ss);

%% Which Side Acts
%
% Crystal symmetry acts on the input of the map, from the right. Specimen
% symmetry acts on its output, from the left. If |O| represents the stored
% orientation, every member of its class has the form
%
% $$ \mathbf{S}_{\mathrm{s}}\,\mathbf{O}\,\mathbf{S}_{\mathrm{c}}. $$
%
% The six crystal operations give the following representatives.

% equivalent orientations with respect to crystal symmetry
crystalEquivalents = ori * cs

%%
% Only the third Euler angle $\varphi_2$ changes, in steps of $60^\circ$.
% In the Bunge convention it is the rotation applied first, in crystal
% coordinates, which is where the crystal symmetry acts.
%
% Specimen symmetry produces the other kind of equivalence.

% equivalent orientations with respect to specimen symmetry
specimenEquivalents = ss * ori

%%
% Now $\varphi_1$ changes because it is applied last, in specimen
% coordinates. Combining both sides gives $2 \times 6 = 12$
% representatives.

allEquivalents = ss * ori * cs

%%
% <orientation.symmetrise.html |symmetrise|> is the shortcut for this
% product. It returns a new orientation array; it does not alter |ori|.

classSize = length(symmetrise(ori))

%% Proper and Improper Operations
%
% Both groups in the first example contain only proper rotations. A full
% point group may also contain improper operations such as inversion or
% reflection. For cubic |m-3m| symmetry, |symmetrise| lists 48 orthogonal
% representatives, while the |'proper'| flag retains the 24 that are rigid
% rotations.

cubicOri = orientation.id(crystalSymmetry('m-3m'));

cubicCounts = [length(symmetrise(cubicOri)),...
  length(symmetrise(cubicOri,'proper'))]

%%
% Use the full point group when lattice or diffraction equivalence is the
% subject. Use |'proper'| when the returned transformations themselves must
% be physically realizable rotations.

%% What This Looks Like in a Pole Figure
%
% One orientation and one crystal direction give a family of specimen
% directions. The |'complete'| flag keeps both hemispheres visible here so
% none of the twelve directions is folded into a smaller plotting region.

h = Miller(1,0,0,cs);

plotPDF(ori,h,'complete','MarkerSize',10,'figSize','small')

%%
% Notice six poles in each hemisphere. The sixfold crystal symmetry creates
% the crystallographically equivalent direction family, and the twofold
% specimen symmetry repeats that family in the specimen frame. Without
% |'complete'|, |plotPDF| exploits both antipodal equivalence and specimen
% symmetry and shows only the non-redundant part of this example.
%
% Which member a calculation produces depends on the stored representative.
% Symmetry-aware comparisons avoid making a physical result depend on that
% arbitrary choice.

%% Coincidences
%
% The product of the group sizes is the number of representatives before
% duplicates are removed. Some orientations make a left-side and a
% right-side operation describe the same transformation. At the identity
% orientation the crystal c axis and specimen z axis coincide, so the class
% has 12 entries but only 6 distinct ones. The |'unique'| option removes the
% duplicates.

identityOri = orientation.id(cs,ss);

coincidentCounts = [length(symmetrise(identityOri)),...
  length(symmetrise(identityOri,'unique'))]

%% Symmetry in Every Comparison
%
% Because the class is what matters, the angle between two orientations is
% the smallest rotational angle over their equivalent representatives. A
% fixed probe orientation therefore has the same symmetry-aware angle to
% every equivalent of the rotation returned by |orientation.goss|. The
% named rotation is used only as a reproducible reference here.

probe = orientation.byEuler(37*degree,48*degree,23*degree,cs);
referenceEquivalents = symmetrise(orientation.goss(cs));

symmetryAwareAngles = angle(probe,referenceEquivalents) ./ degree

%%
% Switching symmetry off compares the stored rotations directly. It gives
% six different angles, whose minimum is the repeated value above.

rawAngles = angle(probe,referenceEquivalents,'noSymmetry') ./ degree

%%
% The |'noSymmetry'| flag is implemented by
% <orientation.angle.html |angle|>, <orientation.dot.html |dot|>, and
% <orientation.unique.html |unique|>, among other orientation methods.
% Reach for it when an angle or dot product comes out smaller than expected.
% Leave it alone otherwise, because the symmetry-aware answer is normally
% the physically meaningful one.
%
% Do not pass |'noSymmetry'| to
% <orientation.calcCluster.html |calcCluster|>. That method does not define
% the flag, and an unknown option can be ignored silently.

%% References
%
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations
% and Rotations: Computations in Crystallographic Textures>, Springer,
% 2004, develops orientation space and the effects of crystal and specimen
% symmetry.
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, establishes the Euler-angle and orientation conventions used in
% texture analysis.
% * R. Arnold, P. E. Jupp and H. Schaeben,
% <https://doi.org/10.1107/S1600576723003187 Orientation relationships,
% orientational variants and the embedding approach>, _Journal of Applied
% Crystallography_ 56 (2023), 725-736, describes crystal orientations as
% equivalence classes in $\mathrm{SO}(3)/K$.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam
% analysis -- Guidelines for orientation measurement using electron
% backscatter diffraction_, gives current guidance for reproducible EBSD
% orientation measurements.

%% Next
%
% The region of rotation space that holds exactly one member of each class
% is the <OrientationFundamentalRegion.html Fundamental Region>. Symmetry of
% the specimen, and when it should be imposed at all, is
% <SpecimenSymmetry.html Specimen Symmetry>. The same minimum-angle rule
% becomes central when comparing two crystals in
% <Misorientations.html Misorientations>.

%#ok<*NOPTS>
