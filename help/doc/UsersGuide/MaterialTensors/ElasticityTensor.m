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

C = loadTensor(fname,cs,'propertyname','elastic stiffness','unit','Pa','interface','generic')

%% Young's Modulus
% Young's modulus is also known as the tensile modulus and measures the stiffness of elastic materials
% It is computed for a specific direction x by the command <tensor.YoungsModulus.html YoungsModulus>.

x = xvector;
E = YoungsModulus(C,x)

%%
% It can be plotted by passing the option *YoungsModulus* to the
% <tensor.plot.html plot> command.

setMTEXpref('defaultColorMap',blue2redColorMap);
plot(C,'PlotType','YoungsModulus','complete','upper')

%% Linear Compressibility
% The linear compressibility is the deformation of an arbitrarily shaped
% specimen caused by increase in hydrostatic pressure and can be described
% by a second rank tensor.
% It is computed for a specific direction x by the
% command <tensor.linearCompressibility.html linearCompressibility>.

beta = linearCompressibility(C,x)

%%
% It can be plotted by passing the option *linearCompressibility* to the
% <tensor.plot.html plot> command.

plot(C,'PlotType','linearCompressibility','complete','upper')

%% Christoffel Tensor
% The Christoffel Tensor is symmetric because of the symmetry of the
% elastic constants. The eigenvalues of the 3x3 Christoffel tensor are
% three positive values of the wave moduli which corresponds to \rho Vp^2 ,
% \rho Vs1^2 and \rho Vs2^2 of the plane waves propagating in the direction n.
% The three eigenvectors of this tensor are then the polatiration
% directions of the three waves. Because the Christoffel tensor is
% symmetric, the polarization vectors are poerpendicular ro each other.

% It is computed for a specific direction x by the
% command <tensor.ChristoffelTensor.html ChristoffelTensor>.

T = ChristoffelTensor(C,x)

%% Elastic Wave Velocity
% The Christoffel tensor is the basis for computing the direction dependent
% wave velocities of the p, s1, and s2 wave, as well as of the polarisation
% directions. Therefore, we need also the density of the material, e.g.,

rho = 2.3

%%
% which we can write directly into the ellastic stiffness tensor
C = addOption(C,'density',rho)

%%
% Then the velocities are computed by the command <tensor.velocity.html
% velocity>

[vp,vs1,vs2,pp,ps1,ps2] = velocity(C,xvector)

%%
% In order to visualize these quantities there are several posibilities.
% Let us first plot the direction dependend wave speed of the p-wave

plot(C,'PlotType','velocity','vp','complete','upper')

%%
% Next we plot on the top of this plot the p-wave polarisation direction.

hold on
plot(C,'PlotType','velocity','pp','complete','upper')
hold off

%%
% Finally we visualize the speed difference between the s1 and s2 waves
% together with the  fast shear-wave polarization.

plot(C,'PlotType','velocity','vs1-vs2','complete','upper')

hold on
plot(C,'PlotType','velocity','ps1','complete','upper')
hold off


%%
% set back default colormap

setMTEXpref('defaultColorMap',WhiteJetColorMap)
