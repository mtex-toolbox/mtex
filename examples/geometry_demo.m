%% Demo of the Crystal Geometry Tools
%
%% the class vector3d

% create
v1 = vector3d(1,1,1);
v2 = [xvector,yvector,zvector];

% operate with vectors
v3 = 2*v1 + 3*v2;
v1 == v2;

% transform to spherical coordinates
[theta,rho] = vec2sph(v3);
v3 = sph2vec(theta,rho);

% plot
plot(v3)



%% quaternion

% create 
q = quaternion(1,0,0,0);
q = euler2quat(pi/2,0,0,'BUNGE');
q = axis2quat(zvector,pi/2);

% operate with quaternions
q*q;
q*v3;
plot(q*v3)

% transform
[phi1,Phi,phi2] = Euler(q,'BUNGE');
angle(q);


%% groups of quaternions - symmetries
%--------------------------------------------------------------------------

% create
SS = symmetry;
CS = symmetry('-3m',[1,1,3])
CS = symmetry('cubic')

% operate
CS * zvector;
symmetrise(zvector,CS)

%% the class S2grid
%-------------------------------------------------------------------------

% create
S2G = S2Grid(v3);
S2G = S2Grid('regular','RESOLUTION',5*pi/180,'north')
S2G = S2Grid('equispaced','points',1000,'antipodal');

% operations
rotate(S2G,q);
delete(S2G,getTheta(S2G)==pi/2);
subGrid(S2G,getTheta(S2G)<=80*degree);

% plot
plot(S2G)

% operations: 
% *subgrid
% *transformation to spherical coordinates

%% groups of quaternions - grids on SO(3)
%--------------------------------------------------------------------------

% create 
SO3G = SO3Grid(q);
SO3G = SO3Grid(5*pi/180,CS,SS);
SO3G = SO3Grid(500,CS,SS)


% operate
set(gcf,'position',[ 67   242   777   384]);
plot(SO3G * xvector)
%%
plot(SO3G * symmetrise(xvector,CS))

%%
% plot
close all;
plot(SO3G,'RODRIGUES')




