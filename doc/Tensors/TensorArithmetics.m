%% Tensor Arithmetics
%
% MTEX offers powerful functionalities to calculate with tensors and lists
% of tensors without the need of many nested loops. 
% 
%% Basic algebra
%
% First of all, all basic operations like |*|, |.*|, |+|, |-|, |.^| known
% from linear algebra work also on lists of tensors.

T1 = tensor.rand('rank',2);
T2 = tensor.rand('rank',2);

% addition and multiplication
T = T1 + 2 * T2;

% pointwise product
T = T1 .* T2;

%% Tensor Products
% 
% Tensor product are the canonical way how tensors interact with each
% other. As an example consider a rank 4 stiffness tensor

C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'))

%%
% Then by Hooks law the stiffness tensor acts on a strain tensor, e.g.,

eps = strainTensor(diag([1 0 -1]))

%%
% according to the formula
%
% $$\sigma_{ij} =\sum_{k,l} C_{ijkl} \epsilon_{kl}$$
%
% and turns it into the stress tensor $\sigma$. In MTEX such tensor
% products can be computed in its most general form by the command
% <EinsteinSum.html EinsteinSum>.

sigma = EinsteinSum(C,[1 2 -1 -2],eps,[-1 -2])

%%
% here the negative numbers indicate the indices which are summed up.
% Each pair of equal negative numbers corresponds to one sum. The
% positive numbers indicate the order of the dimensions of the resulting
% tensor. Accordingly we can compute the outer product 
%
% $$ (a \otimes b)_{ij} = a_i b_j $$
%
% beween two rank one tensors

a = tensor([1;2;3],'rank',1);
b = tensor([0;2;1],'rank',1);

%%
% by the command

EinsteinSum(a,1,b,2)

%%
% and the inner product 
%
% $$ a \cdot b = \sum_i a_i b_i $$
%
% by

EinsteinSum(a,-1,b,-1)

%%
% As a final example we consider the linear compressibility in a certain
% direction |v| which can be computed by the formula
%
% $$ c = \sum_{i,j,k} S_{ijkk} v_i v_j $$
%
% where $C = S^{-1}$ is the inverse of the comcompliance thensor, i.e. the
% stiffness tensor

v = xvector;
S = inv(C)
c = EinsteinSum(C,[-1 -2 -3 -3],v,-1,v,-2)

%%
% Here we used the <tensor.inv.html inv> to compute the inverse of any rank
% 2 or rank 4 tensor. There are shortcuts in MTEX for specific tensor
% products. E.g. the relation between stress and strain can be more
% compactly written as a <tensor.colon.html edouble dot product>

C * eps
C : eps

%% 
% The double dot product between two rank two tensors is essentially their
% inner product and can be equivalently computed from the
% |<tensor.trace.html trace>| of their matrix product

T1 : T2
trace(T1 * T2')
trace(T1' * T2)

%% Determinant
% For rank two tensors we can compute the determinant of the tensor by the
% command <tensor.det.html |det|>

det(T1)

%% Rotating a tensor
% Rotation a tensor is done by the command <tensor.rotate.html |rotate|>.
% Let's define a rotation

r = rotation.byEuler(45*degree,0*degree,0*degree);

%%
% Then the rotated tensor is given by

Trot = rotate(T1,r);
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
