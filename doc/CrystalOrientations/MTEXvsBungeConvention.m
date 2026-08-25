%% MTEX vs. Bunge Convention
%
%%
% MTEX defines an orientation as the coordinate map from the crystal frame
% into the specimen frame. Bunge, and much of the literature following him,
% defines it in the opposite direction: from the specimen frame into the
% crystal frame.
%
% A *reference frame* is the coordinate system in which data are expressed.
% The *crystal frame* is fixed to the lattice, while the *specimen frame* is
% fixed to the sample. Their definitions are developed in
% <DefinitionAsCoordinateTransform.html Crystal Orientation as Coordinate
% Transformation>.
%
% This page assumes the Miller indices introduced in
% <CrystalDirections.html Crystal Directions> and the Euler angles from
% <RotationDefinition.html Defining Rotations>. Its purpose is practical:
% translating orientation data and formulas between MTEX and sources that
% use Bunge's map direction.
%
% The two maps are inverses. This single fact explains the vector, matrix,
% and misorientation formulas below.

plottingConvention.default('y↑→x');

cs = crystalSymmetry('m-3m');
reportedEuler = [10,50,20] * degree;
ori = orientation.byEuler(reportedEuler,'Bunge',cs);
h = Miller(1,0,0,cs,'uvw');

%% Which Way the Coordinates Travel
%
% An MTEX orientation takes a crystal direction, here $[100]$, into specimen
% coordinates.

r = ori * h

%%
% <Miller.rotate.html |rotate|> performs the same operation. The zero angular
% residual confirms that the two forms agree.

rotateResidual = angle(r,rotate(h,ori)) ./ degree

%%
% The Bunge map for the same physical orientation is the inverse map.

ori_Bunge = inv(ori);

%%
% It takes the specimen direction |r| back into crystal coordinates.

hBack = ori_Bunge * r;
hBack.dispStyle = 'uvw';
hBack

%% A Visible Consequence of Using the Wrong Direction
%
% Applying the inverse as though it were a crystal-to-specimen map places the
% crystal differently. The red arrow marks the same crystal direction
% $[100]$ in both panels.

cS = crystalShape.cube(cs);
bungeRotation = rotation(ori_Bunge);
rBunge = bungeRotation * vector3d(h);

mtexFig = newMtexFigure('layout',[1,2],'figSize','large');
plot(ori * cS,'faceColor',[0.35 0.6 0.85]);
hold on;
arrow3d(0.9 * normalize(r),'faceColor',[0.8 0.15 0.1]);
hold off;
text(-0.45,0.45,0.45,'MTEX map','FontWeight','bold');

nextAxis;
plot(bungeRotation * cS,'faceColor',[0.85 0.45 0.3]);
hold on;
arrow3d(0.9 * normalize(rBunge),'faceColor',[0.8 0.15 0.1]);
hold off;
text(-0.45,0.45,0.45,'Inverse map used forward','FontWeight','bold');

% plot(crystalShape) sets the camera and the layout only for a figure it created itself
for ax = mtexFig.children(:).'
  view(ax,3);
  axis(ax,'equal','vis3d','off');
end
drawNow(mtexFig,'figSize','large');

%% The Reported Euler Angles Stay the Same
%
% The word "Bunge" is used for two related choices. One is the direction of
% the coordinate map compared on this page. The other is the Bunge
% Euler-angle sequence. MTEX uses that Euler-angle sequence by default.
%
% For the same physical orientation and the same crystal and specimen frames,
% copy a reported Bunge Euler triple directly into MTEX. The MTEX angles of
% |ori| therefore reproduce the input triple.

mtexEuler = [ori.phi1,ori.Phi,ori.phi2] ./ degree

%%
% Do not instead ask MTEX for the angles of |ori_Bunge|. MTEX interprets that
% inverse as another MTEX rotation and reports the inverse rotation's own
% Euler triple.

inverseAsMtexEuler = ...
  [ori_Bunge.phi1,ori_Bunge.Phi,ori_Bunge.phi2] ./ degree

%%
% Thus the orientation object is inverted, but the three numbers used to
% describe the same physical orientation are not. This design keeps MTEX
% Euler angles consistent with common EBSD systems, simulation packages,
% textbooks, and papers.

%% The Orientation Matrix Is Transposed
%
% Let $\mathbf{G}_{\mathrm{M}}$ be the MTEX matrix and
% $\mathbf{G}_{\mathrm{B}}$ the Bunge matrix for the same physical
% orientation. Since they represent inverse rotations,
%
% $$ \mathbf{G}_{\mathrm{M}} = \mathbf{G}_{\mathrm{B}}^{-1}
%    = \mathbf{G}_{\mathrm{B}}^{\mathrm{T}}. $$
%
% The transpose equality holds because a rotation matrix is orthogonal. The
% MTEX matrix is

mtexMatrix = ori.matrix

%%
% and the difference from the transpose of the Bunge matrix is zero.

bungeMatrix = ori_Bunge.matrix;
matrixResidual = max(max(abs(mtexMatrix - bungeMatrix.')))

%% Misorientations Come Out the Same
%
% A misorientation is a coordinate map from one crystal frame into another.
% With MTEX orientations the formula is

ori1 = ori;
ori2 = orientation.byEuler(70*degree,40*degree,35*degree,'Bunge',cs);

mori = inv(ori1) * ori2;

%%
% With Bunge orientations the product has the opposite-looking formula.

ori1_Bunge = inv(ori1);
ori2_Bunge = inv(ori2);

mori_Bunge = ori1_Bunge * inv(ori2_Bunge);

%%
% Substitution shows that the two inversions cancel. The comparison below
% deliberately ignores crystal symmetry, so a symmetry-equivalent but
% different rotation could not masquerade as equality.

misorientationResidual = ...
  angle(mori,mori_Bunge,'noSymmetry') ./ degree

%%
% The tiny residual is floating-point roundoff. The misorientation map is
% therefore unchanged. Its reported Euler angles are a separate convention:
% when converting a Bunge misorientation triple, use the Euler angles of the
% inverse misorientation.

%% A Practical Check
%
% Before trusting imported orientations, establish all four convention
% choices: the Euler-angle sequence, the map direction, the crystal frame,
% and the specimen frame. A wrong choice still produces valid rotations and
% plausible plots.
%
% The safest check is a known direction. Verify that one indexed crystal
% direction maps to the specimen direction seen in the experiment. For file
% options, see <OrientationImport.html Importing Crystal Orientations>. For
% the independent choice of Cartesian crystal frame, see
% <CrystalReferenceSystem.html The Crystal Reference System>.

%% Summary
%
% || quantity || conversion from Bunge to MTEX ||
% || orientation Euler angles || unchanged ||
% || orientation matrix || transpose the matrix ||
% || any formula involving an orientation || invert each orientation ||
% || misorientation map || unchanged ||
% || misorientation Euler angles || use those of the inverse misorientation ||
%
% The practical consequence is precise. Euler angles may be copied when the
% source uses the Bunge convention and the same crystal and specimen frames.
% A formula written for the opposite coordinate-map direction still has to
% be translated.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, establishes the orientation and Euler-angle conventions used in
% texture analysis.
% * A. Morawiec, <https://doi.org/10.1007/978-3-662-09156-2 Orientations and
% Rotations: Computations in Crystallographic Textures>, Springer, 2004,
% develops coordinate maps, rotation representations, and symmetry.
% * D. Rowenhorst et al.,
% <https://doi.org/10.1088/0965-0393/23/8/083501 Consistent representations
% of and conversions between 3D rotations>, _Modelling and Simulation in
% Materials Science and Engineering_ 23, 083501, 2015, gives reproducible
% conversion rules for common rotation representations.
% * T. B. Britton et al.,
% <https://doi.org/10.1016/j.matchar.2016.04.008 Tutorial: Crystal
% orientations and EBSD -- Or which way is up?>, _Materials
% Characterization_ 117, 113--126, 2016, shows how to validate EBSD
% coordinate frames with known crystallographic features.
% * <https://www.iso.org/standard/82749.html ISO 24173:2024>, _Microbeam
% analysis -- Guidelines for orientation measurement using electron
% backscatter diffraction_, gives guidance for reliable and reproducible
% EBSD orientation measurements.

%% Next
%
% <MisorientationTheory.html Theory of Misorientations> develops the
% crystal-to-crystal map used above and its symmetry. The next page in this
% chapter, <OrientationPoleFigure.html Pole Figures>, applies orientations to
% crystal directions. <OrientationImport.html Importing Crystal
% Orientations> handles orientation files and their convention options.

%#ok<*NOPTS>
