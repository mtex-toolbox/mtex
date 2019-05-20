%% Determining the Stiffness Tensor
% Checked: 28/12/2018
% Reference Elastic constants
% E.K. Graham, J.A. Schwab, S.M. Sopkin, and H.Takei (1988)
% The Pressure and Temperature Dependence of the Elastic Properties
% of Single-Crystal Fayalite Fe2SiO4
% Phys. Chem. Minerals (1988) 16: 186-198.
%
% Define density (g/cm3)
rho= 4.377;
% elastic Cij stiffness tensor (GPa) as matrix M
M =... 
    [[265.85  92.4   80.6     0     0      0];...
    [  92.4  160.25  88.4     0     0      0];...
    [  80.6   88.4  222.42    0     0      0];...
    [    0      0      0    31.55   0      0];...
    [    0      0      0      0   46.74    0];...
    [    0      0      0      0     0  57.15]];
% Define Cartesian Tensor crystal symmetry & frame
cs_Tensor = crystalSymmetry('mmm',[4.826 10.499 6.103],...
  'x||a','z||c', 'mineral','1988 Fayalite Fe2SiO4');

% M as stiffness tensor C with MTEX tensor command
C = stiffnessTensor(M,cs_Tensor,'density',rho);


%%
% Ming Lei, Hassel Ledbetter, and Yuanfu Xie (2004)
% Elastic constants of a material with orthorhombic
% symmetry: An alternative measurement approach
% Journal of Applied Physics 76, 2738 (1994); doi: 10.1063/1.357577

% Extract Voigt matrix for C and S
CV = C.Voigt;
S=inv(C);
SV=S.Voigt;

%% off-diagonal terms needed for the solution

xx = [CV(1,2); CV(1,3); CV(2,3); SV(1,2); SV(1,3); SV(2,3)];


%% The functional to be minimized

% Column vector F1..6
F = @(x) (CV(1,1) * SV(1,1) - 1 + x(1) .* x(4) + x(2).*x(5)).^2 ...
  + (x(1) .* x(4) + CV(2,2) * SV(2,2) + x(3)*x(6)-1).^2 ...
  + (x(2)*x(5) + x(3)*x(6) + CV(3,3)*SV(3,3)-1).^2 ...
  + (CV(1,1)*x(4) + SV(2,2)*x(1) + x(2)*x(6)).^2 ...
  + (CV(1,1)*x(5) + x(1)*x(6) + SV(3,3)*x(2)).^2 ...
  + (x(1)*x(5) + CV(2,2)*x(6) +SV(3,3)*x(3)).^2;


%% run fminsearch to find off-diagonal terms of the stiffness and compliance tensor

% initial guess - need to be quite close
yy = [100 100 100 -0.01 -0.01 -0.01];

% minimization process
xx1 = fminsearch(F,yy)
%xx2 = fminunc(F,yy)

% for comparison true off-diagonal terms  
xx


