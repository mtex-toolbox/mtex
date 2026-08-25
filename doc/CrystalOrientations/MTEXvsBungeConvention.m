%% MTEX vs. Bunge Convention
%
%%
% MTEX defines an orientation as the coordinate transformation from the
% crystal frame into the specimen frame, see
% <DefinitionAsCoordinateTransform.html Theory>. Bunge, and much of the
% literature following him, defines it the other way round: from the
% specimen frame into the crystal frame.
%
% The two are inverses of each other. That single fact explains every
% difference in the formulas below, and the summary at the end is the list
% to keep at hand when transcribing a formula from a paper.

plottingConvention.default('y↑→x');

% consider cubic symmetry
cs = crystalSymmetry('cubic')

%%

% and a random orientation
ori = orientation.rand(cs)

%% What Each One Transforms
%
% An MTEX orientation takes Miller indices to specimen coordinates.

% either by multiplying from the left
r = ori * Miller({1,0,0},cs)

%%

% or using the command rotate
rotate(Miller({1,0,0},cs),ori)

%%
% The Bunge orientation with the same three Euler angles is its inverse,

ori_Bunge = inv(ori)

%%
% and takes specimen coordinates back to Miller indices.

ori_Bunge * r

%%
% The difference is not bookkeeping. Applied to a crystal, the two put it in
% different places - the blue crystal is where the MTEX orientation says it
% is, the orange one where the same three Euler angles read as a Bunge
% orientation would put it.

cS = crystalShape.cube(cs);

plot(ori * cS,'faceColor',[0.35 0.6 0.85])
nextAxis
plot(ori_Bunge * cS,'faceColor',[0.85 0.45 0.3])

%% Euler Angles Are the Same
%
% MTEX implements Euler angles so that they agree with the Bunge Euler
% angles of the same physical orientation. This is deliberate: the numbers
% MTEX prints are the numbers EBSD systems, simulation packages, textbooks
% and papers report, and no conversion is needed when reading them in or
% writing them out.
%
% What is inverted is the orientation itself, not the way its angles are
% written.

%% The Matrix Is Transposed
%
% Since the two orientations are inverse, and a rotation matrix is
% orthogonal, the MTEX matrix is the transpose of the Bunge matrix.

ori.matrix

%%

ori_Bunge.matrix'

%%
% The same numbers, to the last digit.

max(max(abs(ori.matrix - ori_Bunge.matrix')))

%% Misorientations Come Out the Same
%
% A misorientation transforms crystal coordinates of one grain into crystal
% coordinates of another. With MTEX orientations that is

ori1 = orientation.rand(cs);
ori2 = orientation.rand(cs);

mori = inv(ori1) * ori2

%%
% With Bunge orientations the formula reads differently,

ori1_Bunge = inv(ori1);
ori2_Bunge = inv(ori2);

mori_Bunge = ori1_Bunge * inv(ori2_Bunge)

%%
% but it is the same misorientation - the two inversions cancel.

angle(mori,mori_Bunge) ./ degree

%% Summary
%
% || orientation Euler angles || unchanged ||
% || orientation matrix || transposed ||
% || any formula involving an orientation || invert the orientation ||
% || misorientations || unchanged ||
% || misorientation Euler angles || those of the inverse misorientation ||
%
% The practical consequence: Euler angles may be copied when the source
% uses the Bunge convention and the same crystal/specimen frames. A formula
% written for the opposite coordinate-transform direction still has to be
% translated.

%% Next
%
% Where misorientations are defined and what their symmetry does is
% <MisorientationTheory.html Misorientations>. The other convention that
% silently rotates a data set - which crystal axes the Cartesian frame is
% tied to - is <CrystalReferenceSystem.html The Crystal Reference System>.

%#ok<*NOPTS>
