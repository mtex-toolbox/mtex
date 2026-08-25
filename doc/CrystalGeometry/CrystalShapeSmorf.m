%% Defining Crystal Shapes with Smorf
%
%%
% <CrystalShapes.html Crystal Shapes> shows how a shape is built from face
% normals and their distances from the origin. Finding those distances for a
% real mineral is fiddly work by hand, and it is much easier done with a
% drawing tool that redraws the crystal as the numbers change. This page
% walks through it on the olivine shape published by Welsch et al. (2013,
% J. Pet.).
%
% <<smorf_1.png>>
%
%% The Drawing Tool
%
% The crystal drawing tool of the <https://smorf.nl/draw.php Smorf website>
% is a free alternative to the commercial packages, made available by Mark
% Holtkamp.
%
%% Crystal Parameters
%
% Select the point group and enter the cell parameters under celldata - the
% ones from your own EBSD file, if you have one. For the interpretation of
% the face distance choose |Crystallographic (Kristall2000)|, which is the
% convention MTEX follows; the other choices scale the distances
% differently and the numbers would not carry over.
%
% <<smorf_2.png>>
%
% The same symmetry in MTEX:

cs = crystalSymmetry('mmm', [4.756 10.207 5.98], 'mineral', 'Forsterite')

%% The Face Normals
%
% Building a complicated shape face by face is tedious, so start from the
% views along $\vec a$, $\vec b$ and $\vec c$ and enter every face visible
% in the published model, each at distance 1.
%
% <<smorf_3.png>>
%
% In MTEX the same set of faces is a list of
% <Miller.Miller.html |@Miller|> indices.

N = Miller({0,1,0},{0,0,1},{0,2,1},{1,1,0},{1,0,1},{1,2,0},cs)

%% Adjusting the Distances
%
% Now change the distance of one face at a time - steps of 0.05 work well.
% A larger distance moves the face away from the origin, reducing its
% influence on the shape until it may stop cutting the crystal altogether.
% Fix the largest faces first and keep the overall aspect ratio while moving
% the others. The drawing does not update by itself; press _Draw crystal_
% after each change, and compare against the published crystal until they
% match.
%
% <<smorf_4.png>>
%
% Then note the indices and their distances.

dist = [0.4, 1.3, 1.4, 1.05, 1.85, 1.35];

%%
% <crystalShape.crystalShape.html |crystalShape|> takes normals whose length
% encodes the distance, so the two lists are combined by dividing.

% this defines the crystal shape in MTEX
cS = crystalShape( N ./ dist)

%%

% plot the crystal shape
plot(cS,'colored')

%%
% The habit of the published crystal is reproduced. |cS.faceArea| says how
% much of the surface each face got: the two $(010)$ faces are the largest
% individual ones at 0.139, which is what makes the crystal tabular, while
% $(001)$ came out as a small cap of 0.02 and the four faces each of
% $\{021\}$ and $\{110\}$ carry most of the total area.

max(cS.faceArea)

%
% The Smorf mineral database holds many more morphologies, and each of them
% transfers to MTEX in exactly these two lines.

%% Next
%
% What the shapes are used for - orientations on a map, twinning, slip
% systems - is <CrystalShapes.html Crystal Shapes>.

%#ok<*NOPTS>
