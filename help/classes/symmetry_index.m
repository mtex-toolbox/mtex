%% Crystal Symmetries
%
%% Abstract
% This section describes the class *symmetry* and gives an overview how to
% deal with crystal symmetries in MTEX.
%
%% Open in Editor
%
%% Contents
%
%% Description
%
% Crystal symmetries are a sets of rotations and mirroring operations that
% leave the lattice of a crystal invariant. They form so called groups
% since the concatenation of two symmetry operations is again a symmetry
% operation. Crystal symmetries are classified in various ways - either
% according to the corresponding space group, or the corresponding point
% group, or the corresponding Laue group. In total there are only 11
% different Laue groups present in crystallography. All these 11 Laue
% groups are supported by MTEX. More precisely, in MTEX a Laue group is
% represented by a variable of the class *symmetry*.
%
%% Defining a Crystal Symmetry 
%
% MTEX supportes the *Schoenflies* notation on Laue groups as well as the
% *international* notation. In the case of non cubic crystal symmetry the
% length of the crystal axis has to be specified as a second argument to
% the constructor [[symmetry_symmetry.html,symmtry]] and in the case of
% triclinic crystal symmetry the angles between the axes has to be passed
% as third argument. Hence, valid definitions are:
%
%%
% *Laue Group - international notation*
%

cs = symmetry('m-3m')

%% 
% *Laue Group - Schoenflies notation*

cs = symmetry('O')

%%
% *Point Group or its Space Group*
%
% If not the name of a Laue group was specified but the name of a point
% group or a space group MTEX auomatically determines the corresponding
% Laue group and assignes it to the variable.

cs = symmetry('Td')

%%
% *CIF Files*
%
% Finally, MTEX allows to define a crystal symmetry by importing a
% crystallographic information file (*.cif).

cs = symmetry('quartz.cif')


%% The Crystal Coordinate System
%
% In the case of cubic crystal symmetry the crystal coordinate system
% is allready well defined. However, especialy in the case of low order
% crystal symmetry the crystal coordinate system has to be specified by the
% length of the axis and the angle between the axis. 

cs = symmetry('triclinic',[1,2.2,3.1],[80*degree,85*degree,95*degree]);

%% 
% *A and B Configurations*
%
% In the case of trigonal and hexagonal crystal symmetries different
% conventions are used. One distingueshes between the A and the B
% configuration depending whether the a axis is aligned parallel to the x
% axis or parralel to the y axis. In order to specify the concrete
% configuration to be used one can pass either the option *a||x* or the
% option *a||y*.

cs = symmetry('-3m',[1.7,1.7,1.4],'a||x');
plot(cs)

%%

cs = symmetry('-3m',[1.7,1.7,1.4],'a||y');
plot(cs)

