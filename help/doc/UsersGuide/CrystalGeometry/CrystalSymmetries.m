%% Crystal Symmetries
% Explains how to define crystal symmetries. 
%
%% Open in Editor
%
%% Contents
%
%%
% Crystal symmetries are a sets of rotations and mirroring operations that
% leave the lattice of a crystal invariant. They form so called groups
% since the concatenation of to symmetry operations is again a symmetry
% operation. Crystal symmetries are classified in various ways - either
% according to the corresponding space group, or the corresponding point
% group, or the corresponding Laue group. In total there are only 11
% different Laue groups present in crystallography. All these 11 Laue
% groups are supported by MTEX. More precisely, in MTEX a Laue group is
% represented by a variable of the class <symmetry_index.html *symmetry*>.
%

%% Defining a Crystal Symmetry by the Name of its Laue Group
%

cs = symmetry('m-3m')

%%
% defines a cubic crystal symmetry using the international notation. Of
% course MTEX understands also the Schoenflies notation

cs = symmetry('O');

%% Defining a Crystal Symmetry by the Name of its Point Group or its Space Group
%
% If not the name of a Laue group was specified but the name of a point
% group or a space group MTEX auomatically determines the corresponding
% Laue group and assigns it to the variable.

cs = symmetry('Td');

%% Defining a Crystal Symmetry by a CIF File
%
% Finally, MTEX allows to define a crystal symmetry by importing a
% crystallographic information file (*.cif).

cs = symmetry('quartz.cif')


%% The Crystal Coordinate System
%
% In the case of cubic crystal symmetry the crystal coordinate system
% is already well defined. However, especially in the case of low order
% crystal symmetry the crystal coordinate system has to be specified by the
% length of the axes and the angle between the axes. 

cs = symmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree]);

%% A and B Configurations
%
% In the case of trigonal and hexagonal crystal symmetries different
% conventions are used. One distinguishes between the A and the B
% configuration depending whether the a axis is aligned parallel to the x
% axis or parallel to the y axis. In order to specify the concrete
% configuration to be used one can pass either the option *X||a* or the
% option *Y||a*.

cs = symmetry('-3m',[1.7,1.7,1.4],'X||a');
plot(cs)

%%

cs = symmetry('-3m',[1.7,1.7,1.4],'Y||a');
plot(cs)
hold on
plot(cs,'hkl')
hold off

%% Calculations
%
% applying the specimen symmetry from the left and the crystal symmetry from the 
% right onto a [[orientation_index.html,orientation]] results in a vector
% containing all crystallographically equivalent orientations.

ss = symmetry('mmm');   % specimen symmetry
ss * orientation('euler',0,0,pi/4,cs,ss) * cs  % all crystallographically equivalent orientations

%% Plotting symmetries
%
% One can also visualize crystal symmetries by plotting the main axes and the
% corresponding equivalent directions

h = [Miller(1,0,-1,0,cs),Miller(1,1,-2,0,cs),...
  Miller(1,0,-1,1,cs),Miller(1,1,-2,1,cs),...
  Miller(0,0,0,1,cs)];

hold all
for i = 1:length(h)
  plot(h(i),'symmetrised','labeled')
end
hold off
