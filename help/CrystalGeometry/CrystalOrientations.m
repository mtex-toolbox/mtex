%% Crystal Orientations
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
% *The Bunge Euler Angle Convention*
% Here an arbitrary rotation is determined by three consecutive rotations,
% the first about the z-axis, the second about the y-axis, and the third
% again about the z-axis. Hence, one needs three angles two define an
% orientation by Euler angles. The command the defines a orientation by
% three Euler angles is <euler2quat.html euler2quat>

q = euler2quat(30*degree,50*degree,10*degree,'Bunge');

%%
% *The Matthies Euler Angle Convention*
% In contrast to the Bunge conventionen here the three rotations are taken
% about the z-axis, the x-axis, and the z-axis.

q = euler2quat(30*degree,50*degree,10*degree,'Bunge');

%%
% *The axis angle parametrisation*
% Another posibility to specify an rotation is the give its rotational axis
% and its rotational angle. This can be done using the command
% <axis2quat.html axis2quat>.

q = axis2quat(xvector,30*degree);

%%
% *Miller indice*
% The is also a Miller indice convention for defining crystal orientations.
% The corresponding MTEX command is <Miller2quat.html Miller2quat>

q = Miller2quat([1 0 0],[0 1 1],symmetry('cubic'));

%%
% *Four vectors defining a rotation*
% Given four vectors a,b,u,v there is a unique rotations q such that q a =
% u and q b = v. This rotations can be computed using the command 
% <vec42quat.html vec42quat>

q = vec42quat(xvector,yvector,yvector,zvector);

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

h = Miller(1,0,0);

%%
% be a certain crystal direction and 

q = euler2quat(90*degree,90*degree,0);

%%
% a crystal orientation. Then the alignment of this crystal direction with
% respect to the specimen coordinate system can be computed via

r = q * h

%% Concatenating Rotations
%
% Let 

q1 = euler2quat(90*degree,0,0);
q2 = euler2quat(0,90*degree,0);

%%
% two rotations than the rotation given by applying first rotation one and
% then rotation two can be computed via

q = q2 * q1

%% Crystal Symmetries and Crystal Orientation
%
% In general a each crystal orientation is represented by a class of 
% crystallographically equivalent rotations. Let us specify certain
% specimen and crystal symmetries

cs = symmetry('-3m');
ss = symmetry('triclinic');

%%
% Then the class of rotations crystallographically equivalent to q can be
% computed in two way. Either by using the command <symmetry_symmetriceQuat.html
% symmetriceQuat> 

symmetriceQuat(cs,ss,q)

%%
% or by using multiplication

ss * q * cs

%% Caclulating Missorientations
%
% Let cs and ss be crystal and specimen symmetry and q1 and q2 two crystal
% orientations. Then one can ask for the missorientation between both
% orientations. This missorientation can be calculated by the function
% <symmetry_dist.html dist>.

dist(cs,ss,q1,q2) / degree

%%
% This missorientation angle is in general smaller then the missorientation
% without crystal symmetry which can be computed via

dist(q1,q2) /degree

%% Calculating with Orientations and Rotations
%
% Beside the standard linear algebra operations there are also the
% following functions available in MTEX. Then rotational angle and the axis
% of rotation can be computed via then commands
% <quaternion_rotangle.html rotangle(q)> and
% <quaternion_rotaxis.html rotaxis(q)> 

rotangle(q)/degree

rotaxis(q)
%%
% The inverse rotation to q you get from the command
% <quaternion_inverse.html inverse(q)>

inverse(q);

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
plot(Miller2quat([-1 -1 -1],[1 -2 1]))


