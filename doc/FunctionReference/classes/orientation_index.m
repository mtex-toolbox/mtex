%% Crystal Orientations (The Class @orientation)
% This sections describes the class *orientation* and gives an overview how
% to work with crystal orientation in MTEX.
%
%% Open in Editor
%
%% Class Description
%
% In texture analysis crystal orientations are used to describe the
% alignment of the crystals within the specimen. A crystal orientation is
% defined as the rotation that maps the specimen coordinate system onto the
% crystal coordinate system. Since the crystal coordinate system and the
% specimen coordinate system are well defined only up to crystal symmetry
% and specimen symmetry, an orientation is in general represented by a class
% of crystallographically equivalent rotations. In MTEX the class *orientation* 
% is an inheritance of the class <rotation_index.html rotation>. 
% In particular, every function that is defined for a rotation is also 
% available for an orientation.
%
%% SUB: Defining a Crystal Orientation
%
% In order to define a crystal orientation one has to define crystal and
% specimen symmetry first.

cs = crystalSymmetry('cubic');
ss = specimenSymmetry('orthorhombic');

%%
%
% Now a crystal orientation to a certain <rotation_index.html rotation>

rot = rotation('Euler',30*degree,50*degree,10*degree);

%%
% is defined by

o = orientation(rot,cs,ss)

%%
% In order to streamline the definition the arguments to define the
% rotation can be directly pass to define a orientation:

o = orientation('Euler',30*degree,50*degree,10*degree,cs,ss)

%%
% Accordingly parameterisations of rotations are also available for
% orientations
%
% * Bunge Euler Angle Convention
% * Matthies Euler Angle Convention
% * Axis angle parametrisation
% * Fibre of orientations
% * Four vectors defining a rotation
% * 3 times 3 matrix
% * quaternion
%
% Have a look at <rotation_index.html rotation help page> for more details.
% Besides these parameterisations for rotations there are also some
% parameterisations which are unique for orientations
%
% *Miller indices*
%
% There is also a Miller indices convention for defining crystal orientations.

o = orientation('Miller',[1 0 0],[0 1 1],cs,ss)


%%
% *Predifined Orientations*
%
% In the MTEX there is a list of predefined orientations:
%
% * [[orientation.cube.html,cube]]
% * [[orientation.goss.html,goss]]
% * [[orientation.brass.html,brass]]

o = orientation.goss(cs,ss)

%% SUB: Rotating Crystal Directions onto Specimen Directions
%
% Let

h = Miller(1,0,0,cs)

%%
% be a certain crystal direction and

o = orientation('Euler',90*degree,90*degree,0*degree,cs,ss)

%%
% a crystal orientation. Then the alignment of this crystal direction with
% respect to the specimen coordinate system can be computed via

r = o * h

%%
% Conversely the crystal direction that is mapped onto a certain specimen
% direction can be computed via the <orientation.mldivide.html backslash operator>

o \ r

%% SUB: Concatenating Rotations
%
% Let

o = orientation('Euler',90*degree,0,0,cs,ss);
rot = rotation('Euler',0,60*degree,0);

%%
% be a crystal orientation and a rotation of the specimen coordinate
% system. Then the orientation of the crystal with respect to the rotated
% specimen coordinate system calculates by

o1 = rot * o



%%
% Then the class of rotations crystallographically equivalent to o can be
% computed in two ways. Either by using the command <orientation.symmetrise.html
% symmetrise>

symmetrise(o)

%%
% or by using multiplication

ss * o * cs

%% SUB: Calculating Misorientations
%
% Let cs and ss be crystal and specimen symmetry and o1 and o2 two crystal
% orientations. Then one can ask for the misorientation between both
% orientations. This misorientation can be calculated by the function
% <orientation.angle.html angle>.

angle(rot * o1,o1) / degree

%%
% This misorientation angle is, in general, smaller than the misorientation
% without crystal symmetry which can be computed via

angle(rotation(o),rotation(o1)) /degree

%% SUB: Calculating with Orientations and Rotations
%
% Besides the standard linear algebra operations there are also the
% following functions available in MTEX. Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion.angle.html angle(o)> and
% <quaternion.axis.html axis(o)>

angle(o1)/degree

axis(o1)
%%
% The inverse orientation to o you get from the command
% <quaternion.inv.html inv(q)>

inv(o1)

%% SUB: Conversion into Euler Angles and Rodrigues Parametrisation
%
% There are methods to transform quaternion in almost any other
% parameterization of rotations as they are:
%
% * [[quaternion.Euler.html,Euler(o)]]   in Euler angle
% * [[quaternion.Rodrigues.html,Rodrigues(o)]] % in Rodrigues parameter
%

[phi1,Phi,phi2] = Euler(o)


%% SUB: Plotting Orientations
%
% The <orientation.plot.html plot> function allows you to visualize an
% orientation in axis angle space in relation to its fundamental region.

oR = fundamentalRegion(o1.CS,o1.SS)
plot(oR)
hold on
% plot the orientation as it is
plot(o1,'markercolor','b','markerSize',10)

% plot the orientation within the fundamental zone
plot(o1.project2FundamentalRegion,'markercolor','r','markerSize',10)
hold off
