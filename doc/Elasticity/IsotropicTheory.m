%% Isotropic Theory
%
%%
% An anisotropic material needs a fourth order stiffness tensor with up to
% 21 independent numbers. An isotropic one needs two, and every elastic
% modulus in the engineering literature - shear, bulk, Young's, the Poisson
% ratio, the Lame constants - is a pair of those two written differently.
%
% This page starts from a single crystal, makes an isotropic material out of
% it, and then moves between the descriptions.

%% A single crystal
%
% Albite, which is triclinic and about as anisotropic as a common mineral
% gets.

% density (g/cm3)
 rho= 2.6230;
%
% crystal symmetry & frame
cs = crystalSymmetry('-1', [8.290 12.966 7.151], [91.18 116.31 90.14]*degree,...
  'x||a*','y||b', 'mineral','An0 Albite 2016');

% the stiffness tensor C in (GPa)
C = stiffnessTensor(...
  [[  68.30   32.20   30.40    4.90   -2.30  -0.90];...
  [   32.20  184.30    5.00   -4.40   -7.70  -6.40];...
  [   30.40    5.00  180.00   -9.20    7.50  -9.40];...
  [    4.90   -4.40   -9.20   25.00   -2.40  -7.20];...
  [   -2.30   -7.70    7.50   -2.40   26.90   0.60];...
  [   -0.90   -6.40   -9.40   -7.20    0.60  33.60]],...
  cs,'density',rho)

%% An isotropic aggregate of it
%
% A material made of these crystals in random orientations is isotropic. Its
% stiffness is not determined by that alone - it depends on how the grains
% are arranged - but it is bounded, and averaging over a uniform ODF gives
% the bounds.

[C_iso_Voigt,C_iso_Reuss,C_iso_Hill] = mean(C,uniformODF(C.CS))

%% The elastic moduli
%
% From the Voigt tensor, which is the upper bound:

G = C_iso_Voigt.shearModulus
K = C_iso_Voigt.bulkModulus
E = C_iso_Voigt.YoungsModulus(xvector)
nu = C_iso_Voigt.PoissonRatio

%%
% Note that <stiffnessTensor.YoungsModulus.html |YoungsModulus|> asks for a
% direction. For an isotropic tensor the answer is the same in every
% direction, which is a useful check that the average really is isotropic.

%% Back from the moduli to the tensor
%
% Any two of the moduli determine the material, so the tensor can be rebuilt
% from them. From the bulk and shear moduli:

% the matrix entries
C11 = K+(4/3)*G ; C12=C11-2*G; C44=(C11-C12)/2;

% this gives exactly the effective Voigt stiffness tensor as computed above
stiffnessTensor(...
  [[  C11     C12    C12    0.0     0.0    0.0];...
  [   C12     C11    C12    0.0     0.0    0.0];...
  [   C12     C12    C11    0.0     0.0    0.0];...
  [   0.0     0.0    0.0    C44     0.0    0.0];...
  [   0.0     0.0    0.0    0.0     C44    0.0];...
  [   0.0     0.0    0.0    0.0     0.0    C44]],cs)

%%
% and from Young's modulus and the Poisson ratio, going through the
% compliance:

S11 = (1/E); S12 = (-nu/E); S44 = 2*(S11-S12);

inv(complianceTensor(...
 [[  S11     S12    S12    0.0     0.0    0.0];...
 [   S12     S11    S12    0.0     0.0    0.0];...
 [   S12     S12    S11    0.0     0.0    0.0];...
 [   0.0     0.0    0.0    S44     0.0    0.0];...
 [   0.0     0.0    0.0    0.0     S44    0.0];...
 [   0.0     0.0    0.0    0.0     0.0    S44]],cs))

%%
% Both reproduce the averaged tensor above, entry for entry.

%% Converting between the moduli
%
% The same fact stated as formulas - each of these pairs computes one
% modulus from two others, and both members of a pair agree:

% formulae for the Poisson ratio
(E/G-2)/2
(3*K-E)/(6*K)

% formulae for the Young's modulus
2*G*(1+nu)
3*K*(1-2*nu)

%% Lame constants
%
% The pair a theoretician usually prefers, because Hooke's law is shortest
% in it:

lambda = nu/(1-2*nu) /(1+nu) * E;
mu = G;

%%
% The stiffness tensor built from them:

2 * mu * stiffnessTensor.eye(cs) + lambda * dyad(tensor.eye,tensor.eye)

%%
% and Hooke's law, first as a tensor contraction:

eps = strainTensor.rand(cs);

sigma = C_iso_Voigt : eps

%%
% and then in Lame form, which is the same stress:

sigma = stressTensor(2 * mu * eps + lambda * trace(eps) * tensor.eye)

%% Hashin Shtrikman bounds
%
% The Voigt and Reuss bounds cannot be improved without knowing more about
% the material, but the microstructures that attain them are extreme -
% layers of aligned crystals. Assuming instead that the material is
% quasihomogeneous, that is, that any region much larger than a grain has
% the same elastic properties as any other, admits narrower bounds. They are
% due to Hashin and Shtrikman (1962); the derivation followed here is J.M.
% Brown (2015), _Determination of Hashin-Shtrikman bounds on the isotropic
% effective elastic moduli of polycrystals of any symmetry_, Computers &
% Geosciences, 80 (2015) 95-99.
%
% The bounds come out of an optimisation over a comparison material, so the
% first step is a grid of candidate bulk and shear moduli:

% define a 2 dimensional domain of bulk and shear moduli
KMin = 1; KMax = 150; % minimum and maximum bulk moduli
GMin = 1; GMax = 150; % minimum and maximum shear moduli
Ko = linspace(KMin,KMax,300);
Go = linspace(GMin,GMax,300);
[G0Mesh,K0Mesh] = meshgrid(Go,Ko);

%%
% For each of them, <stiffnessTensor.HashinShtrikmanModulus.html
% |HashinShtrikmanModulus|> computes the effective moduli and reports
% whether the residual stiffness tensor came out positive or negative
% definite - which is what decides whether that candidate gives a lower or
% an upper bound.

[khs, ghs, def] = HashinShtrikmanModulus(C,K0Mesh,G0Mesh);

subplot(1,2,1)
imagesc(Go,Ko,khs)
set(gca,'YDir','normal')
title('khs')
xlabel('shear modulus')
ylabel('bulk modulus')
colorbar
axis equal tight

subplot(1,2,2)
imagesc(Go,Ko,ghs)
set(gca,'YDir','normal')
xlabel('shear modulus')
ylabel('bulk modulus')
title('ghs')
colorbar
axis equal tight

%% The bounds themselves
%
% The lower bound is the largest effective modulus over the positive
% definite region, the upper bound the smallest over the negative definite
% one.

khsLower = max(khs(def==1));
khsUpper = min(khs(def==-1));

ghsLower = max(ghs(def==1));
ghsUpper = min(ghs(def==-1));

%%
% Marked in the maps:

subplot(1,2,1)
hold on
[i,j] = find(khs == khsLower);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
[i,j] = find(khs == khsUpper);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
hold off

subplot(1,2,2)
hold on
[i,j] = find(ghs == ghsLower);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
[i,j] = find(ghs == ghsUpper);
plot(Go(j),Ko(i),'o','MarkerEdgeColor','w','linewidth',2)
hold off

%% Comparing the bounds

KReuss = C_iso_Reuss.bulkModulus;
KHill = C_iso_Hill.bulkModulus;
GVoigt = C_iso_Voigt.shearModulus;
GReuss = C_iso_Reuss.shearModulus;
GHill = C_iso_Hill.shearModulus;

disp(' ')
disp('bulk modulus')
cprintf([K,khsUpper,KHill,khsLower,KReuss],...
  '-Lc',{'Voigt' '+HS' 'Hill' '-HS' 'Reus'})
disp(' ')
disp('shear modulus')
cprintf([GVoigt,ghsUpper,GHill,ghsLower,GReuss],...
  '-Lc',{'Voigt' '+HS' 'Hill' '-HS' 'Reus'})
disp(' ')

%%
% Read the two rows. For the bulk modulus the Voigt and Reuss bounds are 63.1
% and 54.1 GPa, nine apart; the Hashin Shtrikman bounds are 60.3 and 57.1,
% three apart. For the shear modulus the improvement is larger still, from
% 41.4 to 29.8 down to 36.8 to 32.8. In both the Hill average sits inside
% the narrower pair, which is the reason it usually works.
%
% Bounds on any other modulus follow from these, since two moduli determine
% an isotropic material.

%#ok<*NASGU>
