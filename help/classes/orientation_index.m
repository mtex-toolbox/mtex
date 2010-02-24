%% Crystal Orientations
%
%% Open in Editor
%
%% Contents
%
%% Description
%
% In texture analysis crystal orientations are used to describe the
% alignment of the crystals within the specimen. A crystal orientation is
% defined as the rotation that maps the specimen coordinate system onto the
% crystal coordinate system. Since, the crystal coordinate system and the
% specimen coordinate system are well defined only up to crystal symmetry
% and specimen symmetry, a orientation is in general represented by a class
% of crystallographically equivalent rotations. In MTEX the class *orientation* is an inheritant
% of the class <rotation_index.html rotation>. In particular, every
% function that is defined for a rotation is also available for
% a orientation.
%
%% Defining a Crystal Orientation
%
% In order to define a crystal orientation one has to define crystal and
% specimen symmetry first.

cs = symmetry('cubic');
ss = symmetry('orthorhombic');

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
% Beside these parameterisations for rotations there are also some
% parameterisations which are unique for orientations
%
% *Miller indice*
%
% There is also a Miller indice convention for defining crystal orientations.

o = orientation('Miller',[1 0 0],[0 1 1],cs,ss)


%%
% *Predifined Orientations*
% 
% In the MTEX there is a list of predefined orientations:
%
% * [[cubeOrientation.html,cubeOrientation]]
% * [[gossOrientation.html,gossOrientation]]
% * [[brassOrientation.html,brassOrientation]]

o = orientation('goss',cs,ss)

%% Rotating Crystal Directions onto Specimen Directions
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
% direction can be computed via the <orientation_mldivide.html backslash operator>

o \ r

%% Concatenating Rotations
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
% computed in two way. Either by using the command <orientation_symmetrise.html
% symmetrise> 

symmetrise(o)

%%
% or by using multiplication

ss * o * cs

%% Caclulating Missorientations
%
% Let cs and ss be crystal and specimen symmetry and o1 and o2 two crystal
% orientations. Then one can ask for the missorientation between both
% orientations. This missorientation can be calculated by the function
% <orientation_angle.html angle>.

angle(o,o1) / degree

%%
% This missorientation angle is in general smaller then the missorientation
% without crystal symmetry which can be computed via

angle(rotation(o),rotation(o1)) /degree

%% Calculating with Orientations and Rotations
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX. Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion_angle.html angle(o)> and
% <quaternion_axis.html axis(o)> 

angle(o1)/degree

axis(o1)
%%
% The inverse orientation to o you get from the command
% <quaternion_inverse.html inverse(q)>

inverse(o1)

%% Conversion into Euler Angles and Rodrigues Parametrisation
%
% There are methods to transform quaternion in almost any other
% parameterization of rotations as they are:
%
% * [[quaternion_Euler.html,Euler(o)]]   in Euler angle
% * [[quaternion_Rodrigues.html,Rodrigues(o)]] % in Rodrigues parameter
%

[phi1,Phi,phi2] = Euler(o)


%% Plotting Orientations
% 
% The [[orientation_plot.html,plot]] function allows you to visualize an 
% quaternion by plotting how the standard basis x,y,z transforms under the
% rotation.

cla reset;set(gcf,'position',[43   362   400   300])
plot(o1)
