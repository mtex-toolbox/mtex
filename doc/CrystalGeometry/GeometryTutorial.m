%% Specimen Directions - The MTEX Class vector3d

%% Open in Editor
%

%%
% *Definition*

v = vector3d (1 ,0 ,0)                      % Cart . coordinates
v = vector3d('polar', 20*degree, 10*degree) % polar coordinates
v = xvector                                 % predefined vector

%%
% *Calculations*

v = [xvector, yvector]; w = v(1);
v = 2*xvector - yvector;

%%
% *Basic Functions*
angle(v, w)
norm(v)
dot(v ,w)
cross(v, w)
[theta, rho] = polar(v)

%%
% *plotting*

close all
plot([v,w])

%% Rotations

%%
% *Definition*
rot = rotation.byEuler(10*degree,20*degree,30*degree);
rot = rotation.byAxisAngle(xvector,30*degree);
rot = rotation.map(xvector,yvector,vector3d(0,1,1),zvector);
rot = rotation(quaternion(0.5,0.5,0.5,0.5));
rot = reflection(zvector)

%%
% *Calculations*

v = rot * xvector
rot \ v
rot2 = rot * rot


%%
% *Basic Functions*
angle(rot)
axis(rot)
angle(rot, rot2)
inv(rot)
[alpha, beta ,gamma] = Euler(rot)

%% Crystal and Specimen Symmetries

%%
% *Definition*
S = crystalSymmetry('triclinic',[1.1 1.3 2.3],[80 110 120]*degree);
CS = crystalSymmetry('-3m',[2,2,1],'X||a','mineral','iron');
SS = specimenSymmetry ('mmm');

% load from a cif file
CS = loadCIF('quartz')



%%
% *Basic Functions*

symmetrise(xvector,SS)
symmetrise(rotation.byEuler(0,0,0),CS,SS)
rotation(CS)
[alpha_max,bet_max,gamma_max] = fundamentalRegionEuler(CS,SS)

%%
% *plotting*

plot(CS)

%%
%
close all

%% Crystal directions - the class *Miller*

%%
% *Definition*

h = Miller(v,CS);
h1 = Miller(1,0,0,CS);
h2 = [Miller(1,1,-2,3,CS),Miller(0,1,-1,0,CS)]


%%
% *Basic Functions*

eq(h1,h2)
angle(h1,h2,'antipodal')
symmetrise(h)
plot([h1,h2],'all','labeled','backGroundColor','w')

%% Orientations

%%
% *Definition*

ori = orientation(rot,CS,SS)
ori = orientation.byEuler(alpha,beta,gamma,CS,SS)
ori = orientation.brass(crystalSymmetry('cubic'))
ori = orientation.byMiller([1 0 0],[1 1 1],CS,SS)

%%
% *Calculations*

r = ori * h
h = ori \ r
ori2 = rot * ori

%%
% *Basic Functions*

eq(ori,ori2)
angle(ori,ori2)
symmetrise(ori)
angle(ori)
[alpha,beta,gamma]  = Euler(ori)

%%
% *Plotting*

plotPDF([ori,ori2],Miller(1,0,0,CS))



%% Exercises
%
% 1) Consider trigonal crystal symmetry.
%
% a) Find all crystallographic directions symmetrically equivalent to h =
% (1, 0, -1, 0) (Miller indices)!

CS = crystalSymmetry('-3m')
h = Miller(1,0,-1,0,CS);
symmetrise(h)


%%
% b) Find crystallographic directions such that the number of their
% crystallographic equivalent directions on the upper hemisphere (without
% equator) is 1, 3, or 6 when including antipodal symmetry?

h1 = Miller(0,0,0,1,CS);
h2 = Miller(1,1,-2,1,CS);
h3 = Miller(1,0,-1,1,CS);

plot([h1 h2 h3],'all','antipodal')

%%
% c) Consider the orientation given by the Euler angles 30, 90, 90
% degree. Give the Euler angles of all symmetrically equivalent
% orientations!

ori = orientation.byEuler(30*degree,90*degree,90*degree,CS);
symmetrise(ori)

%%
% d) Which positions in the (0,0,0,1) - pole figure correspond to above
% defined orientation. Which crystal direction is rotated by this
% orientation to the specimen direction (0,0,1)?

ori * symmetrise(Miller(0,0,0,1,CS))

ori \ zvector


%%
% e) Construct an orientation that rotates the crystallographic directions
% $(0,0,0,1)$ and $(2,\bar 1,\bar 1,0)$ onto the specimen directions
% $(1,0,0)$ and $(0,1,0)$, respectively. Check your result and describe the
% rotation by axis and angle.

h1 = Miller(0,0,0,1,CS);
h2 = Miller(2,-1,-1,0,CS);
r1 = xvector;
r2 = yvector;

ori = orientation.map(h1,r1,h2,r2,CS)

ori * [h1,h2]
