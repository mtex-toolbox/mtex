%% Crystal Symmetries
% This section covers the unit cell of a crystal, its space, point and Laue
% groups as well as alignments of the crystal coordinate system.
%
%% Open in Editor
%
%% Contents
%
%% Crystallographic Space, Point and Laue Groups
%
% Crystal symmetries are a sets of rotations and mirroring operations that
% leave the lattice of a crystal invariant. They form so called groups
% since the concatenation of to symmetry operations is again a symmetry
% operation. Crystal symmetries are classified in various ways - either
% according to the corresponding space group, or the corresponding point
% group, or the corresponding Laue group. In total there are 32 different
% point groups and  11 different Laue groups in crystallography.
% Traditionally, texture analysis software supports only the 11 different
% Laue groups. Starting with version 4.0 MTEX supports all 32 point groups.
% A crystal symmetry is stored in MTEX as a variable of type
% <crystalSymmetry_index.html crystalSymmetry>.
%

%%
% *Defining a Crystal Symmetry by the Name of its Laue Group*


cs = crystalSymmetry('m-3m')

plot(cs,'upper')

%%
% defines a cubic crystal symmetry using the international notation. Of
% course MTEX understands also the Schoenflies notation

cs = crystalSymmetry('O')
plot(cs,'upper')

%%
% *Defining a Crystal Symmetry by the Name of its Point Group or its Space
% Group*
%
% If not the name of a point group was specified but the name of a space
% group MTEX automatically determines the corresponding point group and
% assigns it to the variable.

cs = crystalSymmetry('Td');
plot(cs,'upper')

%%
% *Defining a Crystal Symmetry by a CIF and PHL Files*
%
% Finally, MTEX allows to define a crystal symmetry by importing a
% crystallographic information file (*.cif)

cs = loadCIF('quartz')

%%
% or a Bruker phl file. As a phl file contains usually many phases the
% output is a list of crystal symmetries

% import a list of crystal symmetries
cs_list = loadPHL('crystal.phl');

% access the first symmetry in list
cs_list{1}

%%
% *Switching between Point, Laue and purely rotational group*
%
% One can easily switch from any symmetry group to the corresponding Laue
% group by the command

cs = crystalSymmetry('Td')
cs.Laue

%%
% Furthermore, the purely rotational part of the corresponding Laue group
% can be extracted by the command

cs.properGroup

%%
% *Extracting the Rotations of a Symmetry Group*
%
% All proper and improper rotations of a symmetry group can be extracted by
% the command

rotation(cs)

%%
% *Alignment of the Two Fold Axes and the Mirroring Planes*
%
% MTEX supports different alignments of two fold axes and mirroring planes.
% Look at the difference between the following plots. The red dot always marks
% the a-axis

cs = crystalSymmetry('2mm');
plot(cs)
annotate(cs.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')

figure
plot(crystalSymmetry('m2m'))
annotate(cs.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')

figure
plot(crystalSymmetry('mm2'))
annotate(cs.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')

%%
% The same differences can be found between the symmetry groups 112, 121,
% 211; 11m, 1m1, m11; 321, 312; 3m1, 31m and -3m1, -31m.


%% The Crystal Coordinate System
%
% Beside the symmetry group a variable of type <crystalSymmetry_index.html
% crystalSymmetry> also contains information about the crystal coordinate
% system. It is specified by a list [a,b,c] of axes length and a list
% [alpha,beta,gamma] of angles between the axes. For crystal symmetries
% with fixed angles the last argument can be ommitted. The syntax for a
% triclinic crystal system is

close all
cs = crystalSymmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree])

%%
% *Aligning the Orthogonal Crystal Reference Frame to the Crystal Axes*
%
% As Euler angles and tensors are usually specified not with respect to a
% skew crystal coordinate frame but with respect to a orthogonal reference
% frame the relationship between the latter one to the crystal coordinate
% system has to be specified. In the case of orthorhombic and cubic crystal
% frames no choice has to be made. In the case of triclinic, monoclinic,
% trigonal and hexagonal symmetries one should explicitly define which of
% the crystal axes a, b, c is parallel to X, Y, Z of the orthogonal
% reference frame. For the axes of the dual crystal frame the notation a*,
% b*, c* is used. In order to specify that X is parallel a and Z is
% parallel to c* the syntax is

cs = crystalSymmetry('-3m',[1.7,1.7,1.4],'X||a','Z||c');
plot(cs)
annotate(cs.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')

%%
% For trigonal system the other commonly used convention is X parallel to
% a* and Z parallel to c which reads in MTEX as

cs = crystalSymmetry('-3m',[1.7,1.7,1.4],'X||a*','Z||c');
plot(cs)
annotate(cs.aAxis,'MarkerFaceColor','r','label','a','backgroundColor','w')


%% Calculations
%
% applying the specimen symmetry from the left and the crystal symmetry from the
% right onto a <orientation_index.html orientation> results in a vector
% containing all crystallographically equivalent orientations.

% specimen symmetry
ss = specimenSymmetry('mmm');

% all crystallographically equivalent orientations
ss * orientation.byEuler(0,0,pi/4,cs,ss) * cs

%% Plotting symmetries
%
% One can also visualize crystal symmetries by plotting the main axes and
% the corresponding equivalent directions

h = Miller({1,0,-1,0},{1,1,-2,0},{1,0,-1,1},{1,1,-2,1},{0,0,0,1},cs);

for i = 1:length(h)
  plot(h(i),'symmetrised','labeled','backgroundColor','w','doNotDraw','grid','upper')
  hold all
end
hold off

drawNow(gcm,'figSize','normal')
