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
% crystal coordinate system. 
%
%% Defining a Crystal Orientation
%
% There are several ways to specify crystal orientations. A well known
% possibility are the so called *Euler angles*. Here two conventions are
% commonly used:
%
%%
%
% In general a each crystal orientation is represented by a class of 
% crystallographically equivalent rotations. Let us specify certain
% specimen and crystal symmetries

cs = symmetry('-3m');
ss = symmetry('triclinic');
% *Crystal and Specimen Symmetry

cs = symmetry('cubic');
ss = symmetry('orthorhombic');

%%
% *The Bunge Euler Angle Convention*
% Here an arbitrary rotation is determined by three consecutive rotations,
% the first about the z-axis, the second about the y-axis, and the third
% again about the z-axis. Hence, one needs three angles two define an
% orientation by Euler angles. The command the defines a orientation by
% three Euler angles is <euler2quat.html euler2quat>

o = orientation('Euler',30*degree,50*degree,10*degree,'Bunge',cs,ss)

%%
% *The Matthies Euler Angle Convention*
% In contrast to the Bunge conventionen here the three rotations are taken
% about the z-axis, the y-axis, and the z-axis.

o = orientation('Euler',30*degree,50*degree,10*degree,'ZYZ',cs,ss)

%%
% *The axis angle parametrisation*
% Another posibility to specify an rotation is the give its rotational axis
% and its rotational angle. This can be done using the command
% <axis2quat.html axis2quat>.

o = orientation('axis',xvector,'angle',30*degree,cs,ss)

%%
% *Miller indice*
% The is also a Miller indice convention for defining crystal orientations.
% The corresponding MTEX command is <Miller2quat.html Miller2quat>

o = orientation('Miller',[1 0 0],[0 1 1],cs,ss)

%%
% *Four vectors defining a rotation*
% Given four vectors a,b,u,v there is a unique rotations q such that q a =
% u and q b = v. This rotations can be computed using the command 
% <vec42quat.html vec42quat>

o = orientation(vec42quat(xvector,yvector,yvector,zvector),cs,ss)

%%
% A last method to define a rotation is [[hr2quat.html,hr2quat]].

%% Predifined Orientations
% 
% In the MTEX there is a list of predefined orientations:
%
% * [[cubeOrientation.html,cubeOrientation]]
% * [[gossOrientation.html,gossOrientation]]
% * [[brassOrientation.html,brassOrientation]]
%
%
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

%% Concatenating Rotations
%
% Let 

o = orientation('Euler',90*degree,0,0,cs,ss);
rot = euler2quat(0,90*degree,0);

%%
% be a crystal orientation and a rotation of the specimen coordinate system. Then
% the orientation of the crystal with respect to the rotated specimen
% coordinate system calculates by

o = rot * o



%%
% Then the class of rotations crystallographically equivalent to q can be
% computed in two way. Either by using the command <symmetry_symmetriceQuat.html
% symmetriceQuat> 

symmetrice(o)

%%
% or by using multiplication

%ss * o * cs

%% Caclulating Missorientations
%
% Let cs and ss be crystal and specimen symmetry and q1 and q2 two crystal
% orientations. Then one can ask for the missorientation between both
% orientations. This missorientation can be calculated by the function
% <symmetry_dist.html dist>.

angle(o1,o2) / degree

%%
% This missorientation angle is in general smaller then the missorientation
% without crystal symmetry which can be computed via

angle(quaternion(o1),quaternion(o2)) /degree

%% Calculating with Orientations and Rotations
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX. Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion_rotangle.html rotangle(q)> and
% <quaternion_rotaxis.html rotaxis(q)> 

angle(o1)/degree

rotaxis(o1)
%%
% The inverse orientation to o you get from the command
% <quaternion_inverse.html inverse(q)>

inverse(o1)

%% Conversion into Euler Angles and Rodrigues Parametrisation
%
% There are methods to transform quaternion in almost any other
% parameterization of rotations as they are:
%
% * [[quaternion_quat2euler.html,quat2euler(q)]]   in Euler angle
% * [[quaternion_quat2rodrigues.html,quat2rodrigues(q)]] % in Rodrigues parameter
%
%% Plotting Orientations
% 
% The [[quaternion_plot.html,plot]] function allows you to visualize an 
% quaternion by plotting how the standard basis x,y,z transforms under the
% rotation.

cla reset;set(gcf,'position',[43   362   400   300])
plot(o1)


