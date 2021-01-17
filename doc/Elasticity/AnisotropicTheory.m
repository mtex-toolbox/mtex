%% Anisotropic Elasticity
%
%%
% The linear theory of ellasticity in anisotropic materials is essentialy
% based on the fourth order stiffness tensor |C|. Such a tensor is
% represented in MTEX by a variable of type
% <stiffnessTensor.stiffnessTensor.html |stiffnessTensor|>. Such a variable
% can either by set up using a symmetric 6x6 matrix or by importing it from
% an external file. The following examples does so for the sitiffness
% tensor for Olivine

% file name
fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

% crytsal symmetry
cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

% define the tensor
C = stiffnessTensor.load(fname,cs)

%% Hooks Law
% The stiffness tensor tensor of a material is defined as the stress the
% material expreances for a given strain

eps = strainTensor(diag([1,1.1,0.9]),cs)

%%
% Now Hools law states that the resulting stress can be computed by

sigma = C : eps


%%
% The other way the compliance tensor |S = inv(C)| translates stress into
% strain

inv(C) : sigma

%%
% The ellastic energy of the strain |eps| can be computed equivalently by
% the following equations

% the elastic energy
U = sigma : eps
U = EinsteinSum(C,[-1 -2 -3 -4],eps,[-1 -2],eps,[-3 -4]);

U = (C : eps) : eps;

%% Young's Modulus
% Young's modulus is also known as the tensile modulus and measures the
% stiffness of elastic materials. It is computed for a specific direction
% |d| by the command <stiffnessTensor.YoungsModulus.html YoungsModulus>.

d = vector3d.X;
E = C.YoungsModulus(d)

%%
% If the direction |d| is ommited Youngs modulus is returned as a
% <S2FunHarmonic.S2FunHarmonic.html spherical function>.

% compute Young's modulus as a directional dependend function
E = C.YoungsModulus

% which can be evaluated at any direction
E.eval(d)

% or plot it
setMTEXpref('defaultColorMap',blue2redColorMap);
plot(C.YoungsModulus,'complete','upper')

%% Linear Compressibility
% The linear compressibility is the deformation of an arbitrarily shaped
% specimen caused by an increase in hydrostatic pressure and can be
% described by a second rank tensor. Similarly as the Youngs modulus it can
% be computed by the command <stiffnessTensor.linearCompressibility.html
% linearCompressibility> for specific directions |d| or as a spherical
% function

% compute as a spherical function
beta = linearCompressibility(C)

% plot it
plot(beta,'complete','upper')

% evaluate the function at a specific direction
beta.eval(d)

%% Poisson Ratio 
% The rate of compression / decompression in a direction |n| normal to the
% pulling direction |p| is called Poisson ration.

% the pulling direction
p = vector3d.Z;

% two orthogonal directions
n = [vector3d.X,vector3d.Y];

% the Poisson ratio
nu = C.PoissonRatio(p,n)


%%
% If we ommit in the call to <stiffnessTensor.PoissonRatio.html
% |PoissonRatio|> the last argument 

nu = C.PoissonRatio(p)

%%
% we again obtain a spherical function. However, this time it is only
% meaningfull to evaluate this function at directions perpendicular to the
% pulling direction |p|. Hence, a good way to visualize this function is to
% plot it as a <S2Fun.plotSection.html section> in the x/y plane

plotSection(nu,p,'color','interp','linewidth',5)
axis off
mtexColorbar

%% Shear Modulus
% The shear modulus is TODO

% shear plane
n = Miller(0,0,1,cs);

% shear direction
d = Miller(1,0,0,cs);

G = C.shearModulus(n,d)

%%
newMtexFigure('layout',[1,3])
% shear plane
n = Miller(1,0,0,cs);
plotSection(C.shearModulus(n),n,'color','interp','linewidth',5)
mtexTitle(char(n))
axis off

nextAxis
n = Miller(1,1,0,cs);
plotSection(C.shearModulus(n),n,'color','interp','linewidth',5)
mtexTitle(char(n))

nextAxis
n = Miller(1,1,1,cs)
plotSection(C.shearModulus(n),n,'color','interp','linewidth',5)
mtexTitle(char(n))
hold off

setColorRange('equal')
mtexColorbar
drawNow(gcm,'figSize','large')

%% Wave Velocities
% Since elastic compression and decompression is mechanics of waves
% traveling through a medium anisotropic compressibility causes also
% anisotropic waves speeds. The analysis of this anisotropy is explained in
% the section <WaveVelocities.html wave velocities>.
