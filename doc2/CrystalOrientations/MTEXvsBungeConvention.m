%% MTEX vs. Bunge Convention
%
%%
% For historical reasons MTEX defines orientations in a slightly different
% way than they have been defined by Bunge. As explained in topic
% <CrystalOrientations.html orientations> MTEX defines them as coordinate
% transformations from the crystal reference frame into the specimen
% reference frame. In contrast to this Bunge orientations are coordinate
% transformations from the specimen reference frame into the crystal
% reference frame. Lets demonstrate this by a simple example:

% consider cubic symmetry
cs = crystalSymmetry('cubic')

% and a random orientation
ori = orientation.rand(cs)

%%
% This is now an MTEX orientation and can be used to translate crystal
% coordinates, i.e., Miller indices into specimen coordinates, 

% either by multiplying from the left
r = ori * Miller({1,0,0},cs)

% or using the command rotate
rotate(Miller({1,0,0},cs),ori)

%%
% A Bunge orientation is exactly the inverse of an MTEX orientation, i.e.,

ori_Bunge = inv(ori)

%%
% and translates specimen coordinates into Miller indices
ori_Bunge * r

%% Euler angles
%
% Since the Euler angles are the most common way to describe orientations
% MTEX implements them such that the Euler angles of an MTEX orientation
% coincide with the Euler angles of a Bunge orientation. Thus the Euler
% angles of orientations in MTEX agree with the Euler angles reported by
% all common EBSD devices, simulation software, text books and paper.
%

%% Matrix notation
%
% Due to the above explained inverse relationship of orientations defined 
% in MTEX and in Bunge convention, a matrix generated from an orientation 
% in MTEX is the inverse, or equivallently, the transpose of the matrix in 
% Bunge notation.

ori.matrix
ori_Bunge.matrix^(-1)
ori_Bunge.matrix'

%% Misorientations
%
% Since, MTEX orientations translates crystal to specimen coordinates
% misorientations are defined by the formula

ori1 = orientation.rand(cs);
ori2 = orientation.rand(cs);

mori = inv(ori1) * ori2

%%
% as they are commonly defined coordinate transformations from crystal to
% crystal coordinates. This formula is different to the misorientation
% formula for Bunge orientations


ori1_Bunge = inv(ori1);
ori2_Bunge = inv(ori2);

mori = ori1_Bunge * inv(ori2_Bunge)

%%
% However, both formula result in exactly the same misorientation. 
%
%% Summary
% 
% This list summarizes the differences between MTEX orientations and Bunge
% orientations.
%
% * formulas involving orientations - invert orientation
% * orientation Euler angles - unchanged
% * orientation matrix - transpose matrix
% * misorientations - unchanged
% * misorientation Euler angles - take Euler angles of inverse misorientation
%




