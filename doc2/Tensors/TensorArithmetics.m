%% Tensor Arithmetics
%
% MTEX offers powerful functionalities to calculate with tensors and lists
% of tensors without the need of many nested loops. 
% 
%% Basic algebra
%

T1 = tensor.rand('rank',2)
T2 = tensor.rand('rank',2)


% addition and multiplication
T1 + 2*T2

% pointwise product
T1.*T2



%% Tensor Products
% In MTEX tensor products are specifies according to Einsteins summation
% convention, i.e. a tensor product of the form T_ij = E_ijkl S_kl has to
% be interpreted as a sum over the indices k and l. In MTEX this sum can be
% computed using the command <tensor.EinsteinSum.html EinsteinSum>

C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'))


eps = strainTensor(diag([1 0 -1]))

C * eps
C : eps


sigma = EinsteinSum(C,[-1 -2 1 2],eps,[-1 -2])


%%


T1 : T2

trace(T1 * T2')

trace(T1' * T2)

det(T1)


%%
% here the negative numbers indicate the indices which are summed up.
% Each pair of equal negative numbers corresponds to one sum. The
% positive numbers indicate the order of the dimensions of the resulting
% tensor.
%
% Let us consider the second example. The linear compressibility in a certain
% direction v of a specimen can be computed from it mean elasticity tensor
% E by the formula, c = S_ijkk v_i v_j where S is the compliance, i.e. the
% inverse of the elasticity tensor

v = xvector;
c = EinsteinSum(C,[-1 -2 -3 -3],v,-1,v,-2)


%%






%% Rotating a tensor
% Rotation a tensor is done by the command <tensor.rotate.html rotate>.
% Let's define a rotation

r = rotation.byEuler(45*degree,0*degree,0*degree)

%%
% Then the rotated tensor is given by

Trot = rotate(T,r)
plot(Trot)


%%
% Here is another example from Nye (Physical Properties of Crystals,
% p.120-121) for a third-rank tensor

P = [ 0 0 0 .17 0   0;
      0 0 0 0   .17 0;
      0 0 0 0   0   5.17]*10^-11;

T = tensor(P,'rank',3,'propertyname','piezoelectric modulus')

r = rotation.byAxisAngle(zvector,-45*degree);
T = rotate(T,r)

%% The Inverse Tensor
%
% The inverse of a 2 rank tensor or a 4 rank elasticity tensor is computed
% by the command <tensor.inv.html inv>

S = inv(C)

