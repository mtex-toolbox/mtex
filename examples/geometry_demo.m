%% Specimen Directions - The MTEX Class vector3d

% *Deﬁnition*

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

close;figure('position',[43   362   300   300])
plot([v,w],'FontSize',20)

%% Rotations

% *Deﬁnition*
rot = rotation('Euler',10*degree,20*degree,30*degree);
rot = rotation('axis',xvector,'angle',30*degree);
rot = rotation('map',Miller(1,0,0),yvector,Miller(0,1,1),zvector);
rot = rotation('quaternion',0.5,0.5,0.5,0.5)

%%
% *Calculations*

v = rot * xvector
rot \ v
rot2 = rot * rot

%%
% *plotting*

plot([rot rot2])

%%
% *Basic Functions*
angle(rot)
axis(rot)
angle(rot, rot2) 
inverse(rot)
[alpha, beta ,gamma] = Euler(rot)

%% Crystal and Specimen Symmetries

% *Definition*
S = symmetry('triclinic',[1.1 1.3 2.3],[80 110 120]*degree);
CS = symmetry('-3m',[2,2,1],'a||x','mineral','iron');
SS = symmetry ('mmm');

% load from a cif file
symmetry('quartz.cif')

%%
% *Basic Functions*

symmetrise(xvector,SS)
symmetrise(rotation('Euler',0,0,0),CS,SS)
rotation(CS)
[alpha_max,bet_max,gamma_max] = getFundamentalRegion(CS,SS)

%%
% *plotting*
set(gcf,'position',[50,50,400,400]);
plot(CS,'FontSize',15,'antipodal')

%% Crystal directions - the class *Miller*

% *Definition*

h = Miller(v,CS);
h1 = Miller(1,0,0,CS);
h2 = [Miller(1,1,-2,3,CS),Miller(0,1,-1,0,CS)]


%%
% *Calculations*

ori * h2

%%
% *Basic Functions*

eq(h1,h2)
angle(h1,h2,'antipodal')
symmetrise(h)
plot([h1,h2],'all','labeled')

%% Orientations

% *Definition*

ori = orientation(rot,CS,SS)
ori = orientation('Euler',alpha,beta,gamma,CS,SS)
ori = orientation('Miller',[1 0 0],[1 1 1],CS,SS)
ori = orientation('brass',symmetry('cubic'),symmetry('triclinic'))

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

plot([ori,ori2])



%% Exercises
% 
%  1) Consider trigonal crystal symmetry.
%   a) Find all crystallographic directions symmetrically equivalent to $h
%   = (1, 0, \bar 1, 0)$ (Miller indices)! 

CS = symmetry('-3m')
h = Miller(1,0,-1,0,CS);
symmetrise(h)


%%
%   b) Find crystallographic directions such that the number of their
%   crystallographic equivalent directions on the upper hemisphere (without
%   equator) is 1, 3, or 6 when including antipodal symmetry?

h1 = Miller(0,0,0,1,CS);
h2 = Miller(1,1,-2,1,CS);
h3 = Miller(1,0,-1,1,CS);

plot([h1 h2 h3],'all','antipodal')

%% 
%   d) Consider the orientation given by the Euler angles 30, 90, 90
%   degree. Give the Euler angles of all symmetrically equivalent
%   orientations!

ori = orientation('Euler',30*degree,90*degree,90*degree,CS)
symmetrise(ori);

%% 
%   d)  Which positions in the (0,0,0,1) - pole figure correspond to
%   above defined orientation. Which crystal direction is rotated by this
%   orientation to the specimen direction (0,0,1)?

ori * symmetrise(Miller(0,0,0,1,CS))

ori \ zvector


%%
%   e) Construct an orientation that rotates the crystallographic
%   directions $(0,0,0,1)$ and $(2,\bar 1,\bar 1,0)$ onto the specimen
%   directions $(1,0,0)$ and $(0,1,0)$, respectively. Check your result!

h1 = Miller(0,0,0,1,CS);
h2 = Miller(2,-1,-1,0,CS);
r1 = xvector;
r2 = yvector;

ori = orientation('map',h1,r1,h2,r2,CS)

ori * [h1,h2]


%% Extra Topic - Grids
%
% *Two Dimensioal Grids*

%%
% create
S2G = S2Grid(v3);
S2G = S2Grid('regular','RESOLUTION',5*pi/180,'north')
S2G = S2Grid('equispaced','points',1000,'antipodal');

%%
% operations
rotate(S2G,q);
delete(S2G,getTheta(S2G)==pi/2);
subGrid(S2G,getTheta(S2G)<=80*degree);

%%
% plot
plot(S2G)

%%
% operations: 
% *subgrid
% *transformation to spherical coordinates
%
%%
% * orientation grids*

%%
% create 
SO3G = SO3Grid(q);
SO3G = SO3Grid(5*pi/180,CS,SS);
SO3G = SO3Grid(500,CS,SS)

%%
% operate
set(gcf,'position',[ 67   242   777   384]);
plot(SO3G * xvector)

%%
%
plot(SO3G * symmetrise(xvector,CS))

%%
% plot
close all;
plot(SO3G,'RODRIGUES')

