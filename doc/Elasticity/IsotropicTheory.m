%% Isotropic Theory
%
%%
% An isotropic material has the same elastic response in every direction.
% Its stiffness therefore needs only two independent numbers.
% A general anisotropic stiffness tensor needs as many as 21.
%
% The engineering moduli are different ways to choose those two numbers.
% They include the shear and bulk moduli, Young's modulus, Poisson's ratio,
% and the Lame constants.
%
% This page starts from one anisotropic crystal and makes an isotropic
% aggregate from randomly oriented copies. It then shows how to read,
% compare, and convert the resulting moduli.

%% Start with an anisotropic crystal
%
% Albite is triclinic and is about as anisotropic as a common mineral gets.
% Its density is in g/cm3, and its stiffness entries are in GPa.

rho = 2.6230;

% crystal symmetry and crystal frame
cs = crystalSymmetry('-1',[8.290 12.966 7.151],...
  [91.18 116.31 90.14]*degree,'x||a*','y||b',...
  'mineral','An0 Albite 2016');

% stiffness tensor
C = stiffnessTensor(...
  [[  68.30   32.20   30.40    4.90   -2.30  -0.90];...
  [   32.20  184.30    5.00   -4.40   -7.70  -6.40];...
  [   30.40    5.00  180.00   -9.20    7.50  -9.40];...
  [    4.90   -4.40   -9.20   25.00   -2.40  -7.20];...
  [   -2.30   -7.70    7.50   -2.40   26.90    0.60];...
  [   -0.90   -6.40   -9.40   -7.20    0.60   33.60]],...
  cs,'density',rho);

%% Average a random aggregate
%
% A material made of these crystals in random orientations is isotropic.
% The <ODFAnalysis.html orientation distribution function (ODF)> records
% the volume fraction at each orientation.
% A uniform ODF represents the random orientation distribution used here.
%
% Random orientations do not determine one exact aggregate stiffness.
% The result also depends on how the grains are arranged.
% The Voigt model assumes uniform strain and gives an upper bound.
% The Reuss model assumes uniform stress and gives a lower bound.
% The Hill estimate is the arithmetic mean of those two tensors.

[C_iso_Voigt,C_iso_Reuss,C_iso_Hill] = ...
  mean(C,uniformODF(C.CS))

%% See what the average changed
%
% Young's modulus measures axial stiffness in a chosen loading direction.
% Compare its directional variation before and after averaging.

newMtexFigure('layout',[1,2]);
nextAxis
plot(C.YoungsModulus,'complete','upper')
title('single albite crystal')

nextAxis
plot(C_iso_Hill.YoungsModulus,'complete','upper')
title('random aggregate, Hill estimate')

% a common colour range, otherwise the constant map is stretched over noise
setColorRange('equal')
mtexColorbar('title','Young''s modulus in GPa')

%%
% The single-crystal map changes strongly with direction.
% The aggregate map is constant because the random orientations remove the
% directional preference.

%% Read the elastic moduli
%
% Read four familiar moduli from the Voigt tensor.
% This tensor is the upper bound for the random aggregate.

G = C_iso_Voigt.shearModulus
K = C_iso_Voigt.bulkModulus
E = C_iso_Voigt.YoungsModulus(xvector)
nu = C_iso_Voigt.PoissonRatio

%%
% The shear modulus $G$ measures resistance to shape change at fixed volume.
% The bulk modulus $K$ measures resistance to a uniform volume change.
% Young's modulus $E$ relates axial stress to axial strain.
% Poisson's ratio $\nu$ is minus transverse strain divided by axial strain.
%
% <stiffnessTensor.YoungsModulus.html |YoungsModulus|> asks for a direction.
% An isotropic tensor gives the same answer in every direction.
% That equality is a useful check that the average really is isotropic.

E_direction_check = C_iso_Voigt.YoungsModulus([xvector,zvector])

%% Tighter bounds from a microstructure assumption
%
% The Voigt and Reuss bounds cannot be improved without more information
% about the material. The microstructures that attain them are extreme:
% they are layers of aligned crystals.
%
% A quasihomogeneous material has the same elastic properties in any region
% much larger than a grain. This extra assumption admits narrower bounds.
% The bounds are due to Hashin and Shtrikman (1962).
% The computation below follows Brown (2015).
%
% The calculation searches over isotropic comparison materials.
% Each candidate is specified by a bulk modulus and a shear modulus.

KMin = 1; KMax = 150; % minimum and maximum bulk moduli
GMin = 1; GMax = 150; % minimum and maximum shear moduli
Ko = linspace(KMin,KMax,300);
Go = linspace(GMin,GMax,300);
[G0Mesh,K0Mesh] = meshgrid(Go,Ko);

%%
% For every candidate, <stiffnessTensor.HashinShtrikmanModulus.html
% |HashinShtrikmanModulus|> computes effective bulk and shear moduli.
% It also tests the residual stiffness tensor.
% A positive definite residual identifies a lower-bound candidate.
% A negative definite residual identifies an upper-bound candidate.

[khs,ghs,def] = HashinShtrikmanModulus(C,K0Mesh,G0Mesh);

% largest value in the positive definite region: lower bound
khsLower = max(khs(def==1));
ghsLower = max(ghs(def==1));

% smallest value in the negative definite region: upper bound
khsUpper = min(khs(def==-1));
ghsUpper = min(ghs(def==-1));

%% Locate the Hashin-Shtrikman bounds
%
% Plot the computed effective modulus for every comparison material.
% The white circles mark the lower and upper optima.

figure('Position',[100 100 1000 500])

subplot(1,2,1)
imagesc(Go,Ko,khs)
set(gca,'YDir','normal')
title('effective bulk modulus')
xlabel('comparison shear modulus')
ylabel('comparison bulk modulus')
colorbar
axis equal tight
hold on
[i,j] = find(khs == khsLower);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
[i,j] = find(khs == khsUpper);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
hold off

subplot(1,2,2)
imagesc(Go,Ko,ghs)
set(gca,'YDir','normal')
title('effective shear modulus')
xlabel('comparison shear modulus')
ylabel('comparison bulk modulus')
colorbar
axis equal tight
hold on
[i,j] = find(ghs == ghsLower);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
[i,j] = find(ghs == ghsUpper);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
hold off

%%
% Only the positive and negative definite regions contain valid candidates.
% The circles sit at the extrema of those two regions, not at arbitrary
% extrema of the coloured maps.

%% Compare all three estimates
%
% Collect the Voigt, Reuss, Hill, and Hashin-Shtrikman results.

KReuss = C_iso_Reuss.bulkModulus;
KHill = C_iso_Hill.bulkModulus;
GVoigt = C_iso_Voigt.shearModulus;
GReuss = C_iso_Reuss.shearModulus;
GHill = C_iso_Hill.shearModulus;

disp(' ')
disp('bulk modulus')
cprintf([K,khsUpper,KHill,khsLower,KReuss],...
  '-Lc',{'Voigt' '+HS' 'Hill' '-HS' 'Reuss'})
disp(' ')
disp('shear modulus')
cprintf([GVoigt,ghsUpper,GHill,ghsLower,GReuss],...
  '-Lc',{'Voigt' '+HS' 'Hill' '-HS' 'Reuss'})
disp(' ')

%%
% Read the two rows from outside towards the centre.
% For the bulk modulus, the Voigt and Reuss bounds are 63.1 and 54.1 GPa.
% They are nine GPa apart.
% The Hashin-Shtrikman bounds are 60.3 and 57.1 GPa.
% They are only three GPa apart.
%
% For the shear modulus, the broad interval runs from 41.4 to 29.8 GPa.
% The Hashin-Shtrikman interval runs from 36.8 to 32.8 GPa.
% In both rows the Hill average sits inside the narrower pair.
% This is the reason the Hill estimate usually works.
%
% Bounds on every other modulus follow from these values.
% Two moduli determine an isotropic material.

%% The maths behind isotropic stiffness
%
% Any two elastic moduli determine the complete isotropic tensor.
% Start with the bulk and shear moduli from the Voigt estimate.

C11 = K + (4/3)*G;
C12 = C11 - 2*G;
C44 = (C11-C12)/2;

C_from_KG = stiffnessTensor(...
  [[  C11     C12    C12    0.0     0.0    0.0];...
  [   C12     C11    C12    0.0     0.0    0.0];...
  [   C12     C12    C11    0.0     0.0    0.0];...
  [   0.0     0.0    0.0    C44     0.0    0.0];...
  [   0.0     0.0    0.0    0.0     C44    0.0];...
  [   0.0     0.0    0.0    0.0     0.0    C44]],cs)

%%
% Young's modulus and Poisson's ratio give the same tensor through its
% inverse, the compliance tensor.

S11 = 1/E;
S12 = -nu/E;
S44 = 2*(S11-S12);

C_from_Enu = inv(complianceTensor(...
 [[  S11     S12    S12    0.0     0.0    0.0];...
 [   S12     S11    S12    0.0     0.0    0.0];...
 [   S12     S12    S11    0.0     0.0    0.0];...
 [   0.0     0.0    0.0    S44     0.0    0.0];...
 [   0.0     0.0    0.0    0.0     S44    0.0];...
 [   0.0     0.0    0.0    0.0     0.0    S44]],cs))

%%
% Both constructions reproduce the averaged tensor above entry for entry.
% The same equivalence gives direct conversion formulas between moduli.

% two formulas for Poisson's ratio
nu_from_EG = (E/G-2)/2
nu_from_KE = (3*K-E)/(6*K)

% two formulas for Young's modulus
E_from_Gnu = 2*G*(1+nu)
E_from_Knu = 3*K*(1-2*nu)

%% Lame constants and Hooke's law
%
% The Lame constants are the pair usually preferred in theoretical work.
% They make isotropic Hooke's law especially short.

lambda = nu/(1-2*nu)/(1+nu)*E;
mu = G;

% rebuild the stiffness tensor from the Lame constants
C_from_Lame = 2*mu*stiffnessTensor.eye(cs) + ...
  lambda*dyad(tensor.eye,tensor.eye)

%%
% Apply Hooke's law to a random strain, first by tensor contraction.

eps = strainTensor.rand(cs);
sigma_contraction = C_iso_Voigt : eps

%%
% The Lame form gives exactly the same stress.

sigma_Lame = stressTensor(2*mu*eps + lambda*trace(eps)*tensor.eye)

%#ok<*NASGU>

%% References
%
% * J. M. Brown, <https://doi.org/10.1016/j.cageo.2015.03.009
% Determination of Hashin-Shtrikman bounds on the isotropic effective
% elastic moduli of polycrystals of any symmetry>, _Computers & Geosciences_
% 80 (2015), 95-99, gives the numerical search used in this page.
% * Z. Hashin and S. Shtrikman,
% <https://doi.org/10.1016/0022-5096(63)90060-7 A variational approach to
% the theory of the elastic behaviour of multiphase materials>, _Journal of
% the Mechanics and Physics of Solids_ 11 (1963), 127-140, develops the
% variational bounds and the quasihomogeneous-material assumption.

%% Next
%
% <AnisotropicTheory.html Anisotropic Theory> removes the directional
% equality used here. It shows how crystal symmetry constrains a full
% stiffness tensor and how to read its directional elastic response.
