%% Ellastic Properties of Olivine
%
% This example demonstrates how to compute the basic Engineering constants:
% Young's modulus, Shear modulus and Poisson ratio from a compliance or
% stiffness tensor and vice versa.
%
%% Setup crystal symmetry, stiffness and compliance tensor
%
% Ellastic constants of San Carlos Olivine at 17GPa have been reported in
% the puplication
%
%  Abramson E.H., Brown J.M., Slutsky L.J., and Zaug J.(1997)
%  The elastic constants of San Carlos olivine to 17 GPa.
%  Journal of Geophysical Research 102: 12253-12263.
%
% Lets transfer them into MTEX.

% set up crystal structure of Olivine
cs_tensor = crystalSymmetry('mmm',[4.7646,10.2296,5.9942],...
  'x||a','z||c','mineral','Olivine');

% density of Olivine in g/cm^3
rho=3.355;

% the coefficients C_ij of the ellastic stiffness tensor in Voigt matrix
% notation
M = [[320.5  68.15  71.6     0     0     0];...
    [ 68.15  196.5  76.8     0     0     0];...
    [  71.6   76.8 233.5     0     0     0];...
    [   0      0      0     64     0     0];...
    [   0      0      0      0    77     0];...
    [   0      0      0      0     0  78.7]];

% set the 4 rank elastic stiffness tensor C_ijkl
C = stiffnessTensor(M,cs_tensor,'density',rho)

%%
% The compliance tensor S is the inverse of the stiffness tensor C

S = inv(C)


%% Engineering constants: Young's modulus, Shear modulus and Poisson ratio
%
% Both, the stiffness as well as the compliance tensor encode all ellastic
% engineering constants of the material. The most import are
% <complianceTensor.YoungsModulus.html Young's modulus>,
% <complianceTensor.shearModulus.html Shear modulus> and
% <complianceTensor.PoissonRatio.html Poisson ratio>. Lets compute them for
% the principle axes x, y and z.


%%  

% Young's moduli E_i = 1/S_iiii
E_1 = S.YoungsModulus(vector3d.X)
E_2 = S.YoungsModulus(vector3d.Y)
E_3 = S.YoungsModulus(vector3d.Z)


%%

% Shear moduli G_ij = 1/4 S_ijij (i not equal j)
G_12 = S.shearModulus(vector3d.X,vector3d.Y)
G_13 = S.shearModulus(vector3d.X,vector3d.Z)
G_23 = S.shearModulus(vector3d.Y,vector3d.Z)

%%

% Poission's ratios nu_ij = -S_ijjj/ S_iiii (i not equal j)
nu_12 = S.PoissonRatio(vector3d.X,vector3d.Y)
nu_13 = S.PoissonRatio(vector3d.X,vector3d.Z)
nu_23 = S.PoissonRatio(vector3d.Y,vector3d.Z)
nu_21 = S.PoissonRatio(vector3d.Y,vector3d.X)
nu_31 = S.PoissonRatio(vector3d.Z,vector3d.X)
nu_32 = S.PoissonRatio(vector3d.Z,vector3d.Y)


%% Reconstruct the compliance tensor from the engineering constants
%
% Conversely, we can recover the compliance tensor given the engineering
% constants computed above. More precisely we have

M = [...
  [     1/E_1   -nu_21/E_2   -nu_31/E_3     0     0         0]; ...
  [ -nu_21/E_2       1/E_2   -nu_32/E_3     0     0         0]; ...
  [ -nu_31/E_3  -nu_32/E_3      1/E_3       0     0         0]; ...
  [     0           0         0          1/G_23   0         0]; ...
  [     0           0         0             0  1/G_13       0]; ...
  [     0           0         0             0     0     1/G_12]];

% this could give the same compliance tensor as defined at the beginning
complianceTensor(M,cs_tensor,'density',rho)
