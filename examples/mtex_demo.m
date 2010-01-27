%% MTEX Presentation 
%
% The entire MTEX presentation given at 08.03.2007
% describing all classes used by MTEX, how to import pole figures, how to  
% manipulate pole figures, how to estimate an ODF and finally describing
% the plotting faccilities of MTEX
%

%% The Class vector3d

%  Definitions:
v = vector3d (1,1,1);
v = sph2vec(45*degree,90*degree);
v = xvector;

% Calculations:
v1 = [xvector+yvector,zvector];
w = v(1);
v2 = 2* xvector + yvector;

% Basic Functions:
cross(v1,v2); dot(v1,v2);
norm(v); sum(v);
vec2sph(v);
close;figure('position',[43   362   300   300])
plot(v1,'FontSize',20)
%savefigure('pic/vector3d.pdf')


%% The class quaternion

% Definition
q = quaternion(1,0,0,0);
q = axis2quat(zvector,90*degree);
q1 = euler2quat(30*degree,20*degree,10*degree);
q2 = Miller2quat([-1 -1 -1],[1 -2 1]);
q = idquaternion;

% Calculations:
q =[q1,q2]; 
q1 = q(1);
q = q1 * q2; 
w = q * v;


% Basic Functions:
rotangle(q2); rotaxis(q2);quat2euler(q2);
quat2rodrigues(q2); plot(q2,'FontSize',20)
%savefigure('pic/quaternion.pdf')

%% The class symmetry

% Definition
S = symmetry('triclinic',[1.1 1.3 2.3],[80 110 120]*degree);
CS = symmetry('-3m',[1,1,1]);
SS = symmetry ('O');

% Calculations:

SS * xvector;
CS * q * SS;

%Basic Functions:

Laue(SS); length(CS);
quaternion(CS); 
set(gcf,'position',[50,50,400,400]);plot(CS,'FontSize',15,'antipodal')
%savefigure('pic/symmetry.pdf')

%% The class Miller

% Definition:
h1 = Miller(1,0,0,CS);
h = [Miller(1,1,-2,3,CS),Miller(0,1,-1,0,CS)];
h2 = vec2Miller(xvector+yvector,CS);

%Calculations:
q * Miller(1,0,0,CS);  
CS * Miller(1,0,0,CS); 

%Basic Functions:

angle(h1,h2); 
vector3d(h); 
symeq(h1,h2);
plot(Miller(1,3,-4,4,CS),'all','FontSize',15,'antipodal')
%savefigure('pic/miller.pdf')

%% The Class S2Grid 

%Definition:

S2G = S2Grid('equispaced','points',1000,'antipodal');
S2G = S2Grid(v);
S2G = S2Grid('equispaced','RESOLUTION',5*degree,'antipodal');
S2G = S2Grid ('regular','points',[72,17],'MAXTHETA',80 * degree);

% Basic Functions:
S2G = add(S2G,xvector);
S2G = delete(S2G,zvector);
union(S2G,S2Grid(-zvector));
rotate(S2G,axis2quat(xvector,45*degree));
subGrid(S2G,zvector,10*degree);
refine(S2Grid('equispaced','resolution',1000,'antipodal'));
numel(S2G);
getResolution(S2G);
getRho(S2G);
getTheta(S2G);
%polar(S2G);
vector3d(S2G);
plot(S2G)

%% Import Pole Figures

% specify crystal and specimen symmetry
CS = symmetry('-3m',[1.4 1.4 1.5]);
SS = symmetry;

% specify file names
fname = {...
  [mtexDataPath '/dubna/Q(10-10)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(10-11)(01-11)_amp.cnv'],...
  [mtexDataPath '/dubna/Q(11-22)_amp.cnv']};

% specify crystal directions
h = {Miller(1,0,-1,0,CS),[Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],Miller(1,1,-2,2,CS)};

% specify structure coefficients
c = {1,[0.52 ,1.23],1};

% import data
pf = loadPoleFigure(fname,h,CS,SS,'superposition',c);

close;figure('position',[43   362   1005   353])
plot(pf)
%savefigure('pic/pforig.pdf')

%% Analyze Pole Figures

min(pf);
max(pf);
clf; hist(pf)

%% Modify Pole Figures

% combine pole figures
pf1 = pf(1);
pf2 = pf(2);
pf3 = 2*pf1 + 5*pf2;
pf3 = [pf1, pf2];
pf3 = pf([1,2]);

% Basic functions:
scale(pf,2);
union(pf1,pf2);

pf1 = delete(pf, ...
  getTheta(getr(pf))>=70*degree & ...
  getTheta(getr(pf))<=75*degree);
plot(pf1)
%savefigure('pic/pfdelted.pdf')

%%
pf2 = rotate(pf1,axis2quat(xvector-yvector,25*degree));
plot(pf2,'antipodal')
%savefigure('pic/pfrotated.pdf')

%%
pf2 = setdata(pf2,1,getdata(pf1)<1);
plot(pf2,'antipodal')
%savefigure('pic/pfincreased.pdf')

%% The class kernel

% Definition:
%
% Available Kernel Functions:
%
% * Abel Poisson
% * de la Vallee Poussin
% * von Mises Fisher
% * fibre von Mises Fisher
% * Gauss -- Weierstrass
% * Dirichlet

psi = kernel('de la Vallee Poussin',80)
%%

psi = kernel('Abel Poisson','halfwidth',10*degree)
%%

% Plot on SO(3):
close;figure('position',[43   362   1205   200])
subplot(1,5,1);plot(psi,'K');


% Plot Radon transformed kernel
subplot(1,5,2);plot(psi,'RK');

% Plot Fourrier coefficients of the kernels:
subplot(1,5,3);plot(psi,'Fourier','bandwidth',32);

% Plot even part of the kernel:
subplot(1,5,4);plot(psi,'even');

% Plot odd part of the kernel:
subplot(1,5,5);plot(psi,'odd');



%% Unimodal ODFs

% specify crystal and specimen symmetry
SS = symmetry('mmm');
CS = symmetry('cubic');

% specify modal orientation
q = Miller2quat([1 2 2],[2 2 1],CS);

% specif kernel function
psi = kernel('von Mises Fisher','halfwidth',10*degree);

% define ODF
odf = unimodalODF(q,CS,SS,psi)

%%
close;figure('position',[43   362   705   353])
plotpdf(odf,[Miller(1,0,0,CS),Miller(1,2,2,CS)],'complete')
%savefigure('pic/unimodalODF.pdf')


%% Fibre ODFs

% specify crystal and specimen symmetry
CS = symmetry('hexagonal');
SS = symmetry('triclinic');

% specify crystal and specimen direction
h = Miller(1,0,0,CS);
r = xvector;

% specif kernel function
psi = kernel('Abel Poisson','halfwidth',9*degree);

% fibre ODFs
odf = fibreODF(h,r,CS,SS,psi)

%%
plotpdf(odf,[Miller(1,0,-1,0,CS),Miller(0,0,0,1,CS)],'antipodal');
%savefigure('pic/fibreODF.pdf')


%% Working with ODFs
%
% Predefined ODFs:
uniformODF(CS,SS) % a simple uniform ODF
%%
santafee          % the santafee sample ODF

%%
%
% Manipulate ODFs:

odf2 = 0.3*uniformODF(CS,SS) + 0.7*santafee % add and scale ODFs

%%
rotate(odf,q) % rotate an ODF

%%
%
% Compute texure characteristics of ODFs
Fourier(odf2,'order',2)              % compute Fourier coefficients
%%
volume(odf,idquaternion,10*degree)  % compute volume portion
%%
textureindex(odf)                   % compute texture index
%%
entropy(odf)                        % compute entropy
%%
[alpha,beta,gamma] = quat2euler(modalorientation(odf2)) % compute modalorientation
%%
clf;hist(odf) 


%% Recalculate ODFs

rec = calcODF(pf1,'background',10);

%% Error analysis

e = calcerror(pf1,rec,'RP')
%%
plotDiff(pf,rec)
%savefigure('pic/diffpf.pdf')


%% Pole Figure Plots

plotpdf(odf,[Miller(1,0,0,CS),Miller(0,0,1,CS)],'antipodal');
%savefigure('pic/fibreodf1.pdf')

%%
plotpdf(odf,[Miller(1,0,0,CS),Miller(0,0,1,CS)],'antipodal','absolute','edist')
%savefigure('pic/fibreodf2.pdf')

%%

plotpdf(odf,[Miller(1,0,0,CS),Miller(0,0,1,CS)],'antipodal','gray','contourf')
%savefigure('pic/fibreodf3.pdf')

%% Inverse Pole Figures Plots

plotipdf(odf,[xvector,vector3d(1,1,1),zvector])


%% ODF Plots

close;figure('position',[43   362   300   300]);
plot(rec,'RADIALLY','center',modalorientation(rec));
% savefigure('pic/radialplot.pdf')

%% 

close;figure('position',[46   171   752   486]);
plot(santafee,'sections',18,'gray','contourf','projection','plain','FontSize',10,'alpha','silent');

%% 

plot(rec,'sections',18,'FontSize',10,'resolution',5*degree,'silent')

%plotpdf(santafee,[Miller(1,0,0),Miller(1,2,2)],'complete')
