%% Crystal and Specimen Symmetries (The Class @symmetry)
% This section describes the class *symmetry* and gives an overview how to
% deal with crystal symmetries in MTEX.
%
%% Open in Editor
%
%% Contents
%
%% Class Description
%
% Crystal symmetries are sets of rotations and mirroring operations that
% leave the lattice of a crystal invariant. They form so-called groups
% since the concatenation of two symmetry operations is again a symmetry
% operation. Crystal symmetries are classified in various ways - either
% according to the corresponding space group or the corresponding point
% group, or the corresponding Laue group. In total, there are only 11
% different Laue groups present in crystallography. All these 11 Laue
% groups are supported by MTEX. More precisely, in MTEX a Laue group is
% represented by a variable of the class *symmetry*.
%
%% SUB: Defining a Crystal Symmetry 
%
% MTEX supports the *Schoenflies* notation on Laue groups as well as the
% *international* notation. In the case of noncubic crystal symmetry the
% length of the crystal axis has to be specified as a second argument to
% the constructor [[symmetry.symmetry.html,symmtry]] and in the case of
% triclinic crystal symmetry the angles between the axes has to be passed
% as the third argument. Hence, valid definitions are:
%
%%
% *Laue Group - international notation*
%

cs = crystalSymmetry('m-3m')

%% 
% *Laue Group - Schoenflies notation*

cs = crystalSymmetry('O')

%%
% *Point Group or its Space Group*
%
% If not the name of a Laue group was specified but the name of a point
% group or a space group MTEX automatically determines the corresponding
% Laue group and assigns it to the variable.

cs = crystalSymmetry('Td')

%%
% *CIF Files*
%
% Finally, MTEX allows defining a crystal symmetry by importing a
% crystallographic information file (*.cif).

cs = loadCIF('quartz')


%% SUB: The Crystal Coordinate System
%
% In the case of cubic crystal symmetry the crystal coordinate system
% is already well defined. However, especially in the case of low order
% crystal symmetry, the crystal coordinate system has to be specified by the
% length of the axis and the angle between the axis. 

cs = crystalSymmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree]);

%% 
% *A and B Configurations*
%
% In the case of trigonal and hexagonal crystal symmetries different
% conventions are used. One distinguishes between the A and the B
% configuration depending whether the a-axis is aligned parallel to the 
% x-axis or parallel to the y-axis. In order to specify the concrete
% configuration to be used one can pass either the option *X||a* or the
% option *Y||a*.

cs = crystalSymmetry('-3m',[1.7,1.7,1.4],'X||a');
plot(cs)

%%

cs = crystalSymmetry('-3m',[1.7,1.7,1.4],'Y||a');
plot(cs)

