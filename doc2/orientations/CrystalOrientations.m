%% Crystal Orientations
% Explains how to define crystal orientations, how to switch between
% different convention and how to compute crystallographic equivalent
% orientations.
%
%% Open in Editor
%
%% Contents
%
%% Definition
%
% Crystal orientations are rotations that describe the alignment of the
% crystal lattice with respect to a fixed specimen reference frame. Thus
% they consist of two incredients. A <rotation_index.html rotation>

% lets take a random one
rot = rotation.rand

%%
% and a description of the crystal lattice, which are represented in MTEX
% by variables of type <crystalSymmetry_index.html crystalSymmetry>

cs = crystalSymmetry('cubic')


%%
% Combining both incredients allows us to define an orientation

ori = orientation(rot,cs)

%%
% As a consequence a variable of type orientation is at the same time of
% type <rotation_index.html rotation> and hence allows for all
% <rotation_index.html operations> that are available for rotations.

%% Coordinate Transformations
%
% In MTEX orientations are defined as the coordinate transformation that
% transforms coordinates of a (direction, tensor, slip system) with respect
% to a crystal fixed coordinate system into coordinates with respect to the
% specimen coordinate system. 
%
% As an example we consider the crystal direction

h = Miller(1,0,0,cs,'uvw')

%%
% Then in specimen coordinates the direction |h| has the coordinates

r = ori * h

%%
% Conversely, we can go back from specimen coordinates to crystal
% coordinates by multiplying with the inverse orientation

inv(ori) * r

%%
% Note, that in literature orientations are often defined to transform
% specimen coordinates into crystal coordinates, i.e., to coincide with the
% inverse orientations in MTEX. The consequences of this differences are
% exhaustivly discussed in the topic <MTEXvsBungeConvemtion.html
% orientation convemtions>.
%
% In the same manner orientations can be used to transform tensors given
% with respect to the crystal reference system

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');
C = stiffnessTensor.load(fname,cs)

%%
% into tensors given with respect to the specimen coordinate system

% some random orientation
ori = orientation.rand(cs)

% transform into specimen coordinates
ori * C

%%
% Objects that can be translated by orientations from crystal into specimen
% cooordinates and vice verca include
%
% * <Miller_index.html crystal directions>
% * <tensor_index.html tensors>
% * <slipSystem_index.html slip systems>
% * <twinningSystem_index.html twinning systems>
% * <dislocationSystem_index.html dislocation systems>
% * <crystalShape_index.html crystal shapes>
%
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
%% Defining crystal orientations
%
% Since, orientations are essentialy rotations with respect to a crystal
% reference frame all parameterisations of rotations may be applied to
% define orientations. Those include
%
%% SUB: by Euler angles
%
% Here an orientation is determined by three consecutive rotations in the
% sample reference frame. The first is about the z-axis, the second about
% the x-axis, and the third again about the z-axis. The corresponding three
% angles are called  Euler angles and commonly denoted by phi1, Phi, phi2.

ori = orientation.byEuler(30*degree,50*degree,10*degree,cs)

%%
% MTEX supports a varity of other Euler angle conventions which use
% different axes of rotation as discuses in the topic
% <EulerAngleConventions.html Euler angle conventions>.
%
%% SUB: by rotational axis and rotational angle
%
% Another possibility to specify an orientation is to give its rotational
% axis and its rotational angle.

ori = orientation.byAxisAngle(xvector,30*degree,cs)

%% SUB: by Miller indices
%
% There is also a Miller indice convention for defining crystal orientations.

ori = orientation.byMiller([1 0 0],[0 1 1],cs)


%% SUB: defining an orientation by a 3 times 3 matrix

ori = orientation.byMatrix(eye(3),cs)

%% SUB: predefined orientations
% 
% MTEX includes a list of standard standard orientations. For example the
% identical or cube orientation can be defined by the syntax

ori = orientation.id(cs)

%%
% In the samy way the following orientations can be defined: cube, brass,
% brass2, copper, copper2, cubeND22, cubeND45, cubeRD, goss, inverse goss,
% PLage, PLage2, QLage, QLage2, QLage3, QLage4, SR, SR2, SR3, SR4.
%
% Note that a list of orientations can be defined using the same syntax as
% for the matlab commands ones, zeros, ..

ori = orientation.id(100,1,cs)

%% SUB: random orientations
% You may generate random orientations with 

ori = orientation.rand(1000,cs)


%% SUB: grids of orientations
% 
% In many usecases one is interested in grid of orientations that somehow
% uniformely cover the orientation space. As there are many different grid
% there is a seperate topic <SO3GridDemo.html orientation grids>. The
% simplest way of generating equispaced orientations with given resolution
% is by the command

ori = equispacedSO3Grid(cs,'resolution',2.5*degree)

%% Specimen Symmetry
%
% If the texture forming process has been symmetric the resulting is often
% as well. The resulting symmetry is then aligned with the specimen
% reference system. In MTEX specimen symmetry axes may only be defined
% parallel to the specimen axes x, y, and z. The syntax is very similar to
% the definition of crystal symmetries.

% define cubic crystal symmetry
cs = crystalSymmetry('432')

% and orthorhombic specimen symmetry
ss = specimenSymmetry('222')

%%
% Orientations that respect crystal as well as specimen symmetries are
% defined by passign the specimen symmetry as an additional argument after
% the crystal symmetry.

ori = orientation.brass(cs,ss)

%% Symmetrical Equivalent Orientations
%
% Crystal orientations always appear as a class of symmetrically equivalent
% orientations which are physicaly not distinguishable. For a given
% orientation |ori| the complete list of all symmetrically equivalent
% orientations is computed by the command <orientation.symmetrise.html
% symmetrise>

symmetrise(ori)

%%
% Alternatively the list can be computed by multiplying with the specimen
% and the crystal symmetry from the left and from the right.

ss * ori * cs

%%
% For specific orientations as for the brass orientations symmetrisation
% leads to multiple identical orientation. This can be prevented by passing
% the option |unique| to the command <orientation.symmetrise.html
% symmetrise>

symmetrise(ori,'unique')

%%
%
% Note that all operation on orientations are preformed taking all
% symmetrically equivalent orientations into account. As an example
% consider the angle between a random orientation and all orientations
% symmetricall equivalent to the goss orientation

ori = orientation.rand(cs);
angle(ori,symmetrise(orientation.goss(cs))) ./ degree

%%
% The value is the same for all orientations and equal to the smallest
% angle to one of the symmetrally equivalent orientations. This can be
% verified by computing the rotational angle ignoring symmetry.

angle(ori,symmetrise(orientation.goss(cs)),'noSymmetry') ./ degree

%%
% Functions that respect crystal symmetry but allow to switch it off using
% the flag |noSymmetry| include <orientation_dot.html dot>,
% <orientation_unique.html unique>, <cluster.html cluster>
%
%% Conversion into Euler angles, matrix, quaternion or Rodrigues vector
%
% There are methods to transform quaternion in almost any other
% of rotations as they are:

% as Euler angles
ori.phi1, ori.Phi, ori.phi2

% as quaternion
quaternion(ori)

% as matrix
ori.matrix

% as Rodrigues vector
ori.Rodrigues

%% Plotting Orientations
%
% Orientations can be visualized in many different ways. The most popular
% way are <OrientationPoleFigure.html pole figures>

ori = orientation.rand(5,cs);
plotPDF(ori,Miller({1,0,0},{1,1,1},{1,1,0},cs))

%%
% Other options are <OrientationInversePoleFigure.html inverse pole
% figures>, <EulerAngleSections.html sections through the Euler space> and
% <OrientationPlot3d three dimensional orientation plots>.

% in Euler angle space
plot(ori,'filled')


%%
% in axis angle space
plot(ori,'axisAngle','filled')


