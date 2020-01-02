%% Schmid Factor Analysis
% This script describes how to analyze Schmid factors.
%
% Let us assume a Nickel crystal

CS = crystalSymmetry('cubic',[3.523,3.523,3.523],'mineral','Nickel')

%%
% Since Nickel is fcc a dominant slip system is given by the slip plane
% normal

n = Miller(1,1,1,CS,'hkl')

%%
% and the slip direction (which needs to be orthogonal)

d = Miller(0,-1,1,CS,'uvw')

%%
% For tension in direction 123
r = normalize(vector3d(1,2,3))

%%
% the Schmid factor for the slip system [0-11](111) is defined by
%
tau = dot(d,r,'noSymmetry') * dot(n,r,'noSymmetry')

%%
% The same computation can be performed by defining the slip system as an
% MTEX variable

sS = slipSystem(d,n)

%%
% and using the command <slipSystem.SchmidFactor.html SchmidFactor>

sS.SchmidFactor(r)

%%
% Ommiting the tension direction r the command
% <slipSystem.SchmidFactor.html SchmidFactor> returns the Schmid factor as
% a <S2FunHarmonic.S2FunHarmonic.html spherical function>

SF = sS.SchmidFactor

% plot the Schmid factor in dependency of the tension direction
plot(SF)

% find the tension directions with the maximum Schmid factor
[SFMax,pos] = max(SF)

% and annotate them
annotate(pos)

%% Stress Tensor
% Instead by the tension direction the stress might be specified by a
% stress tensor

sigma = stressTensor.uniaxial(vector3d.Z)

%%
% Then the Schmid factor for the slip system |sS| and the stress tensor
% |sigma| is computed by

sS.SchmidFactor(sigma)

%% Active Slip System
% In general a crystal contains not only one slip system but at least all
% symmetrically equivalent ones. Those can be computed with

sSAll = sS.symmetrise('antipodal')

%%
% The option |antipodal| indicates that Burgers vectors in oposite
% direction should not be distinguished.
% Now

tau = sSAll.SchmidFactor(r)

%%
% returns a list of Schmid factors and we can find the slip system with the
% largest Schmid factor using

[tauMax,id] = max(abs(tau))

sSAll(id)

%%
% The above computation can be easily extended to a list of tension
% directions

% define a grid of tension directions
r = plotS2Grid('resolution',0.5*degree,'upper');

% compute the Schmid factors for all slip systems and all tension
% directions
tau = sSAll.SchmidFactor(r);

% tau is a matrix with columns representing the Schmid factors for the
% different slip systems. Lets take the maximum rhowise
[tauMax,id] = max(abs(tau),[],2);

% vizualize the maximum Schmid factor
contourf(r,tauMax)
mtexColorbar

%%
% We may also plot the index of the active slip system
pcolor(r,id)

mtexColorMap black2white

%%
% and observe that within the fundamental sectors the active slip system
% remains the same. We can even visualize the the plane normal and the slip
% direction

% if we ommit the option antipodal we can distinguish
% between the oposite burger vectors
sSAll = sS.symmetrise

% take as directions the centers of the fundamental regions
r = symmetrise(CS.fundamentalSector.center,CS);

% compute the Schmid factor
tau = sSAll.SchmidFactor(r);

% here we do not need to take the absolut value since we consider both
% burger vectors +/- b
[~,id] = max(tau,[],2);

% plot active slip plane in red
hold on
quiver(r,sSAll(id).n,'LineWidth',2,'Color','r');

% plot active slip direction in green
hold on
quiver(r,sSAll(id).b.normalize,'LineWidth',2,'Color','g');
hold off

%%
% If we perform this computation in terms of spherical functions we obtain

% ommiting |r| gives us a list of 12 spherical functions
tau = sSAll.SchmidFactor

% now we take the max of the absolute value over all these functions
contourf(max(abs(tau),[],1),'upper')
mtexColorbar


%% The Schmid factor for EBSD data
% So far we have always assumed that the stress tensor is already given
% relatively to the crystal coordinate system. Next, we want to examine the
% case where the stress is given in specimen coordinates and we know the
% orientation of the crystal. Lets import some EBSD data and computet the
% grains

mtexdata csl

% take some subset
ebsd = ebsd(ebsd.inpolygon([0,0,200,50]))

grains = calcGrains(ebsd);
grains = smooth(grains,5);

plot(ebsd,ebsd.orientations,'micronbar','off')
hold on
plot(grains.boundary,'linewidth',2)
hold off

%%
% We want to consider the following slip systems

sS = slipSystem.fcc(ebsd.CS)
sS = sS.symmetrise;

%%
% Since, those slip systems are in crystal coordinates but the stress
% tensor is in specimen coordinates we either have to rotate the slip
% systems into specimen coordinates or the stress tensor into crystal
% coordinates. In the following sections we will demonstrate both ways.
% Lets start with the first one

% rotate slip systems into specimen coordinates
sSLocal = grains.meanOrientation * sS

%%
% These slip systems are now arranged in matrix form
% where the rows corrspond to the crystal reference frames of the different
% grains and the rows are the symmetrically equivalent slip systems.
% Computing the Schmid faktor we end up with a matrix of the same size

% compute Schmid factor
sigma = stressTensor.uniaxial(vector3d.X)
SF = sSLocal.SchmidFactor(sigma);

% take the maxium allong the rows
[SFMax,active] = max(SF,[],2);

% plot the maximum Schmid factor
plot(grains,SFMax,'micronbar','off','linewidth',2)
mtexColorbar location southoutside

%%
% Next we want to visualize the active slip systems.

% take the active slip system and rotate it in specimen coordinates
sSactive = grains.meanOrientation .* sS(active);

hold on
% visualize the trace of the slip plane
quiver(grains,sSactive.trace,'color','b')

% and the slip direction
quiver(grains,sSactive.b,'color','r')
hold off

%%
% We observe that the Burgers vector is in most case aligned with the
% trace. In those cases where trace and Burgers vector are not aligned the
% slip plane is not perpendicular to the surface and the Burgers vector
% sticks out of the surface.

%%
% Next we want to demonstrate the alternative route

% rotate the stress tensor into crystal coordinates
sigmaLocal = inv(grains.meanOrientation) * sigma

%%
% This becomes a list of stress tensors with respect to crystal coordinates
% - one for each grain. Now we have both the slip systems as well as the
% stress tensor in crystal coordiantes and can compute the Schmid factor

% the resulting matrix is the same as above
SF = sS.SchmidFactor(sigmaLocal);

% and hence we may proceed analogously
% take the maxium allong the rows
[SFMax,active] = max(SF,[],2);

% plot the maximum Schmid factor
plot(grains,SFMax)
mtexColorbar

% take the active slip system and rotate it in specimen coordinates
sSactive = grains.meanOrientation .* sS(active);

hold on
% visualize the trace of the slip plane
quiver(grains,sSactive.trace,'color','b')

% and the slip direction
quiver(grains,sSactive.b,'color','r')

hold off

%% Strain based analysis on the same data set

eps = strainTensor(diag([1,0,-1]))

epsCrystal = inv(grains.meanOrientation) * eps

[M, b, W] = calcTaylor(epsCrystal, sS);

plot(grains,M,'micronbar','off')
mtexColorbar southoutside

%%

[ bMax , bMaxId ] = max( b , [ ] , 2 ) ;
sSGrains = grains.meanOrientation .* sS(bMaxId) ;
hold on
quiver ( grains , sSGrains.b)
quiver ( grains , sSGrains.trace)
hold off





