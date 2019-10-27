%% Crystal Orientation as Coordinate Transformation
%
%% 
% In MTEX a crystal orientation is defined as the rotation that transforms
% <CrystalDirections.html crystal coordinates>, i.e., a description of a
% vector or a tensor with respect to the <CrystalReferenceSystem.html
% crystal reference frame>, into specimen coordinates, i.e., a desciption
% of the same object with respect to a specimen fixed reference frame.
%
% In MTEX any orientation consists of two incredients. A
% <rotation.rotation.html rotation>

% lets take a random one
rot = rotation.rand

%%
% and a description of the crystal lattice, which are represented in MTEX
% by variables of type <crystalSymmetry.crystalSymmetry.html crystalSymmetry>

% lets take cubic crystal symmetry
cs = crystalSymmetry('cubic')

%%
% Combining both incredients allows us to define an orientation

ori = orientation(rot,cs)

%%
% As a consequence a variable of type orientation is at the same time of
% type <rotation.rotation.html rotation> and hence allows for all
% <RotationOperations.html operations> that are available for rotations.
%
%% Crystal coordinates to specimen coordinates
%
% Let us consider to following direction with respect to the crystal
% reference system

h = Miller(1,0,0,cs,'uvw')

%%
% Then in a grain with orientation |ori| this direction |h| has with
% respect to the specimen reference system the coordinates

r = ori * h

%%
% Similarly, orientations transform tensors given with respect to the
% crystal reference frame, e.g., the following single crystal stiffness
% tensor

C = stiffnessTensor(...
  [[2 1 1 0 0 0];...
  [1 2 1 0 0 0];...
  [1 1 2 0 0 0];...
  [0 0 0 1 0 0];...
  [0 0 0 0 1 0];...
  [0 0 0 0 0 1]],cs)
    
%%
% into a stiffness tensor with respect to the specimen reference frame

ori * C

%%
% Objects that can be translated by orientations from crystal into specimen
% cooordinates and vice verca include
%
% * <Miller.Miller.html crystal directions>
% * <tensor.tensor.html tensors>
% * <slipSystem.slipSystem.html slip systems>
% * <twinningSystem.twinningSystem.html twinning systems>
% * <dislocationSystem.dislocationSystem.html dislocation systems>
% * <crystalShape.crystalShape.html crystal shapes>
%
%% Specimen coordinates into crystal coordinates
%
% Conversely, we can go back from specimen coordinates to crystal
% coordinates by multiplying with the inverse orientation

inv(ori) * r

%%
% Note, that in literature orientations are often defined to transform
% specimen coordinates into crystal coordinates, i.e., to coincide with the
% inverse orientations in MTEX. The consequences of this differences are
% exhaustivly discussed in the topic <MTEXvsBungeConvention.html
% orientation convemtions>.


%% Specimen Rotation
%
% Rotations of the specimen ,i.e., changing the specimen reference frame,
% do also change the orientation. Assume the specimen is rotated about the
% X-axis about 60 degree. We may define this rotation by

rot = rotation.byAxisAngle(vector3d.X,60*degree);

%%
% Then an orientation |ori| is updated to the rotated reference frame by 

ori_new = rot * ori

%%
% It should also be noted, that orientations are sensitiv with respect to
% the alignment of the Euclidean reference frame $\vec X$, $\vec Y$, $\vec
% Z$ with respect to the crystal axes $\vec a$, $\vec b$ and $\vec c$. This
% issue is discussed in more detail in the topic
% <CrystalReferenceSystem.html The crystal reference system>.
%
