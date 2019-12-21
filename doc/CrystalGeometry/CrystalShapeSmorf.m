%% Defining crystal shapes using <https://smorf.nl/draw.php Smorf>
%
% This guide demonstrates how to construct own crystal models and implement
% them in MTEX on the example of replicating the maolivine crystal shape
% published in Welsch et al. (2013, J. Pet.).
% 
% <<smorf_1.png>>
% 
%% Open the smorf website
%
% The crystal drawing tool of the <https://smorf.nl/draw.php Smorf website>
% is an alternative to commercial software packages for defining custom
% crystal shapes. This free tool is made available by Mark Holtkamp.
%
%% Select crystal parameters
%
% Select the point group for crystal symmetry and update the cell
% parameters in celldata. (Hint: use cell parameters from your own EBSD
% file). For the interpretation of face distance, choose |Crystallographic
% (Kristall2000)|, because MTEX follows this convention.
%
% <<smorf_2.png>>
%
% In MTEX define the crystal symmetry accordingly

cs = crystalSymmetry('mmm', [4.756 10.207 5.98], 'mineral', 'Forsterite')

%% Select the face normals
%
% Depending on the complexity of the crystal shape, the drawing of crystal
% can be tedious. Start constructing the crystal shape as seen along the
% main crystallographic axes $\vec a$, $\vec b$ and $\vec c$ and add all
% visible crystal faces from the Welsch et al. (2013) model with distance
% of 1.
%
% <<smorf_3.png>>
%
% Accordingly we define the face normals in MTEX as a variable of type
% @Miller

N = Miller({0,1,0},{0,0,1},{0,2,1},{1,1,0},{1,0,1},{1,2,0},cs)

%% Adapt the distances of the faces
%
% Start modifying the morphology by changing distance values of a given
% crystal face. (Hint: d-step of 0.05 works quite well and is fast).
%
% <<smorf_4.png>>
%
% A higher distance value moves the crystal face farther from the origin,
% and vice versa. Fix first the largest crystal faces and maintain aspect
% ratio of the overall crystal shape by moving faces away or closer to
% origin. Note that the model in the crystal-drawing tool is not updated
% automatically, so you may need to click on _Draw crystal_ button to apply
% changes. When ready, compare the original and replicate olivine
% and take a note on the hkl Miller indices and the corresponding
% distances in Smorf.

dist = [0.4, 1.3, 1.4, 1.05, 1.85, 1.35];

%%
% to define the corresponding crystal shape in MTEX use the command
% @crystalShape and provide as input the quotient between the face normals
% and the distances

% this defines the crystal shape in MTEX
cS = crystalShape( N ./ dist)

% plot the crystal shape
plot(cS,'colored')

%%
% Get inspired by the Smorf mineral database for more crystal morphologies!
