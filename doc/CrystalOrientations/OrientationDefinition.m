%% Defining Orientations
%
%%
% This sections covers the definition of orientations as MTEX variables.
% The theoretical definition can be found in the section
% <DefinitionAsCoordinateTransform.html Theory> and
% <MTEXvsBungeConvention.html MTEX vs Bunge Convention>.
%
% Technically, a variable of type <orientation.orientation.html
% orientation> is nothing else then a <rotation.rotation.html rotation>
% that is accompanied by a crystal symmetry. Hence, all methods for
% defining rotations (<RotationDefinition.html as explained here>) are also
% applicable for orientations with the only difference that the crystal
% symmetry has to be specified in form of a variable of type
% <crystalSymmetry.crystalSymmetry.html crystalSymmetry>.

% load copper cif file
cs = crystalSymmetry.load('Cu-Copper.cif')

%%
% Most importantly we may use Euler angles to define orientations

ori = orientation.byEuler(30*degree,50*degree,10*degree,cs)

%%
% or a 3x3 rotation matrix

M = eye(3)

ori = orientation.byMatrix(M)

%% Miller indices 
%
% Another common way to specify an orientation is by the crystal directions
% point towards the specimen directions Z and X. This can be done by the
% command <orientation.byMiller.html byMiller>. E.g. in order to define 
% the GOSS orientation (011)[100] we can write

orientation.byMiller([0 1 1],[1 0 0],cs)

%%
% Note that MTEX comes already with a long list of
% <OrientationStandard.html predefined orientations>.

%% Random Orientations
% To simulate random orientations we may apply the same syntax as for
% rotations and write

ori = orientation.rand(100,cs)


%% Specimen Symmetry
% If one needs to consider also specimen symmetry this can be defined as a
% variable of type <specimenSymmetry.specimenSymmetry.html
% specimenSymmetry> and passed as an additional argument to all commands
% discussed above, e.g.,

% define orthotropic specimen symmetry
ss = specimenSymmetry('orthorhombic')

% define a corresponding orientation
ori = orientation.byEuler(30*degree,50*degree,10*degree,cs,ss)

%%
% Symmetrisation will now result in a very long list of symmetrically
% equivalent orientations

ori.symmetrise