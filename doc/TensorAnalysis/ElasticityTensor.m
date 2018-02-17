%% The Elasticity Tensor
% how to calculate and plot the elasticity properties
%
%%
% MTEX offers a very simple way to compute elasticity properties of
% materials. This includes Young's modulus, linear compressibility,
% Christoffel tensor, and elastic wave velocities.
%
%% Open in Editor
%
%% Contents
%
%% Import an Elasticity Tensor
% Let us start by importing the elastic stiffness tensor of an Olivine
% crystal in reference orientation from a file.

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','Olivin');

C = stiffnessTensor.load(fname,cs)

%% Young's Modulus
% Young's modulus is also known as the tensile modulus and measures the
% stiffness of elastic materials. It is computed for a specific direction x
% by the command <tensor.YoungsModulus.html YoungsModulus>.

% compute Young's modulus as a directional dependend function
E = C.YoungsModulus

% plot it
setMTEXpref('defaultColorMap',blue2redColorMap);
plot(C.YoungsModulus,'complete','upper')

% Young's modulus for a specific direction 
E.eval(vector3d.X)

%


%% Linear Compressibility
% The linear compressibility is the deformation of an arbitrarily shaped
% specimen caused by an increase in hydrostatic pressure and can be described
% by a second rank tensor.
% It is computed for a specific direction x by the
% command <tensor.linearCompressibility.html linearCompressibility>.

beta = linearCompressibility(C)

% plot it
plot(beta,'complete','upper')

% 
beta.eval(vector3d.X)


%% Christoffel Tensor
% The Christoffel Tensor is symmetric because of the symmetry of the
% elastic constants. The eigenvalues of the 3x3 Christoffel tensor are
% three positive values of the wave moduli which corresponds to \rho Vp^2 ,
% \rho Vs1^2 and \rho Vs2^2 of the plane waves propagating in the direction n.
% The three eigenvectors of this tensor are then the polarization
% directions of the three waves. Because the Christoffel tensor is
% symmetric, the polarization vectors are perpendicular to each other.

% It is computed for a specific direction x by the
% command <tensor.ChristoffelTensor.html ChristoffelTensor>.

T = ChristoffelTensor(C,vector3d.X)

%% Elastic Wave Velocity
% The Christoffel tensor is the basis for computing the direction dependent
% wave velocities of the p, s1, and s2 wave, as well as of the polarization
% directions. Therefore, we need also the density of the material, e.g.,

rho = 2.3

%%
% which we can write directly into the ellastic stiffness tensor
C = addOption(C,'density',rho)

%%
% Then the velocities are computed by the command <tensor.velocity.html
% velocity>

[vp,vs1,vs2,pp,ps1,ps2] = velocity(C)


%%
% In order to visualize these quantities, there are several possibilities.
% Let us first plot the direction dependent wave speed of the p-wave


plot(vp,'complete','upper')

%%
% Next, we plot on the top of this plot the p-wave polarization direction.

hold on
plot(pp)
hold off

%%
% Finally, we visualize the speed difference between the s1 and s2 waves
% together with the  fast shear-wave polarization.

plot(vs1-vs2,'complete','upper')

hold on
plot(ps1)
hold off


%%
% set back default colormap

setMTEXpref('defaultColorMap',WhiteJetColorMap)
