%% Plastic Deformation
% Schmid factor, active slip systems
%
%%
% In this section we describe how to analyze the plastic deformation of
% crystals using MTEX.
%
%% Open in Editor
%
%% Contents

%% Schmidt factor
% Let us assume a Nickel crystal

CS = crystalSymmetry('cubic',[3.523,3.523,3.523],'mineral','Nickel')

%%
% Then for a certain slip plane

m = Miller(1,1,1,CS)

%%
% a certain slip direction orthognal to it

n = Miller(0,-1,1,CS)

%%
% and a simple shear in direction
r = vector3d(0,0,1)

%%
% the Schmid factor is defined by
%
tau = dot(m,r) * dot(n,r)

%% The Schmid tensor
% In tensor notation the simple shear in direction r can be expressed by
% the stress tensor

sigma = EinsteinSum(tensor(r),1,tensor(r),2,'name','stress')

%%
% one the other hand to a certain slip system m,n corresponds a Schmid
% tensor

R = SchmidTensor(m,n)

%%
% such that the Schmid factor may be computed as
tau = double(EinsteinSum(R,[-1,-2],sigma,[-1,-2]))

%%
% the above computation can be easily extended to a list of tension
% directions

% define a grid of tension directions
r = plotS2Grid('resolution',0.5*degree,'upper')

% define the coressponding list of simple shear stress tensors 
sigma = EinsteinSum(tensor(r),1,tensor(r),2,'name','stress tensor')

% compute the Schmid factors for all tension directions
tau = double(EinsteinSum(R,[-1,-2],sigma,[-1,-2],'name','Schmid factor'));

% vizualize the Schmid factors
contourf(r,tau)
colorbar

%% Finding the active slip system
% With slip direction m and slip plane n also all crystallographic
% symmetric directions and planes which are orthogonal are valid slip
% systems. Let us determine those equivalent slip systems

% symmetrise m and n
[mSym,l] = symmetrise(m,'antipodal'); 
[nSym,l] = symmetrise(n,'antipodal');

% restrict m and n to pairs of orthogonal vectors
[row,col] = find(isnull(dot_outer(vector3d(mSym),vector3d(nSym))));
mSym = mSym(row)
nSym = nSym(col)

% vizualize crystallographic symmetric slip systems
plot(mSym,'antipodal')
hold all
plot(nSym)
hold off

%% 
% Next we compute the Schmid factors for  all these slip systems

% define a simple shear stress tensor in 001 direction
M = zeros(3);M(3,3) = 1;
sigma001 = tensor(M,'name','stress')

% and rotate it a bit
sigmaRot = rotate(sigma001,rotation('Euler',20*degree,20*degree,-30*degree))

% define a list of Schmid tensors - one for each slip sytem
RSym = SchmidTensor(mSym,nSym)

% compute a list Schmid factors - one for each slip system
tau = double(EinsteinSum(RSym,[-1,-2],sigmaRot,[-1,-2],'name','Schmid factor'))'

%%
% we observe that the Schmid factor is always between -0.5 and 0.5. The
% largest value indicates the active slip system. In the above case this
% would be the slip system 4

mSym(4)
nSym(4)

%% Finding the active slip system
% All the above steps for finding the active slip system, i.e., 
%
% * find all symmetrically equivalent slip systems
% * compute all the Schmid factors
% * find the maximum Schmid factor
% * find the corresponding slip system 
%
% can be preformed by the single command <tensor.calcShearStress.html calcShearStress> 

[tauMax,mActive,nActive,tau,ind] = calcShearStress(sigmaRot,m,n,'symmetrise')

%%
% This command allows also to compute the maximum Schmidt factor and the
% active slip system for a list of stress tensors in parallel. Consider
% again the list of simple stress tensors corresponding to any direction

sigma

%%
% Then we can compute the maximum Schmidt factor and the active slip system
% for all these stress tensors by the singe command

[tauMax,mActive,nActive,tau,ind] = calcShearStress(sigma,m,n,'symmetrise');

% pot the maximum Schmidt factor
contourf(r,abs(tauMax));
colorbar

%%

% plot the index of the active slip system
pcolor(r,ind);

mtexColorMap black2white

%%
% We can even visualize the active slip system

% take as directions the centers of the fundamental regions
r = symmetrise(CS.fundamentalSector.center,CS);
sigma = EinsteinSum(tensor(r),1,r,2)

% compute active slip system
[tauMax,mActive,nActive] = calcShearStress(sigma,m,n,'symmetrise');

hold on
% plot active slip plane in red
quiver(r,mActive,'ArrowSize',0.2,'LineWidth',2,'Color','r');

% plot active slip direction in green
quiver(r,nActive,'ArrowSize',0.2,'LineWidth',2,'Color','g');
hold off

%%
% So far we have always assumed that the stress tensor is already given
% relatively to the crystal coordinate system. Next we want to examine the
% case where the stress is given in specimen coordinates and we know the
% orientation of the crystal. Lets assume we have simple shear stress
% tensor in 001 direction 

M = zeros(3);M(3,3) = 1;
sigma001 = tensor(M,'name','stress')

%%
% Furthermore, we assume the orientations to be given by an EBSD map. Thus
% the next step is to extract the orientations from the EBSD data and
% transform the stress tensor from specimen to crystal coordinates

mtexdata forsterite

% extract the orientations
ori = ebsd('Forsterite').orientations;

% extract the orientations
CS_Forsterite = ori.CS;

% transform the stress tensor from specimen to crystal coordinates
sigmaCS = rotate(sigma001,inv(ori))

%%
% Next we compute maximum Schmidt factor and the active slip system for
% every orientation in the ebsd data set

% define the slip directions and slip plane normals
% (010)[100]
% slip direction [100]
b = Miller(1,0,0,CS_Forsterite,'uvw');
% slip plane normal (010)
n = Miller(0,1,0,CS_Forsterite,'hkl');

[tauMax,mActive,nActive,tau,ind] = calcShearStress(sigmaCS,n,b,'symmetrise');

close all
plot(ebsd('Forsterite'),tauMax')
colorbar
title('Schmidt factors for (010)[100]')

%%
% The above procedure may also be applied to grains which has the advantage
% to be much less computational demanding for large data sets.

% compute grains
grains = calcGrains(ebsd('indexed'))

% extract the orientations
ori = grains('Forsterite').meanOrientation;

% transform the stress tensor from specimen to crystal coordinates
sigmaCS = rotate(sigma001,inv(ori))

% compute maximum Schmid factor and active slip system
[tauMax,mActive,nActive,tau,ind] = calcShearStress(sigmaCS,n,b,'symmetrise');

plot(grains('Forsterite'),tauMax)
colorbar
title('Schmidt factors for (010)[100]')

%% 
% We may also colorize the active slip system. 

plot(grains('Forsterite'),ind)
