%% Tensor Arithmetic
%
%%
% Tensors are lists like everything else in MTEX, so the arithmetic works on
% a thousand of them as readily as on one and no loop is needed. What is
% specific to tensors is how they multiply: a physical law is a contraction
% of indices, and this page is mostly about how to write one.

plottingConvention.default('y↑→x');

%% Basic algebra
%
% Addition, scalar multiplication and the elementwise operations behave as
% they do for arrays.

T1 = tensor.rand('rank',2);
T2 = tensor.rand('rank',2);

% addition and multiplication
T = T1 + 2 * T2;

% point-wise product
T = T1 .* T2;

%% Tensor products
%
% A rank 4 stiffness tensor, the one physical law worth having in mind while
% reading the rest of this page:

C = stiffnessTensor.load(fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa'))

%%
% Hooke's law says it turns a strain into a stress. Take a strain that
% stretches along x and compresses along z:

eps = strainTensor(diag([1 0 -1]))

%%
% The law itself is a sum over two indices,
%
% $$\sigma_{ij} =\sum_{k,l} C_{ijkl} \epsilon_{kl}$$
%
% and <EinsteinSum.html |EinsteinSum|> writes exactly that. Each tensor is
% followed by its list of index labels: a *negative* label appearing twice
% is summed over, a *positive* label survives and gives the order of the
% dimensions of the result.

sigma = EinsteinSum(C,[1 2 -1 -2],eps,[-1 -2])

%%
% The two positive labels leave a rank 2 tensor, the stress. Its diagonal
% carries the normal stresses of the strain we applied, in GPa.
%
% The same notation covers the products of elementary algebra. The outer
% product of two vectors,
%
% $$ (a \otimes b)_{ij} = a_i b_j $$
%
% has no summation and two free indices:

a = tensor([1;2;3],'rank',1);
b = tensor([0;2;1],'rank',1);

%%

EinsteinSum(a,1,b,2)

%%
% while the inner product
%
% $$ a \cdot b = \sum_i a_i b_i $$
%
% is one summation and no free index, so the result is a scalar:

EinsteinSum(a,-1,b,-1)

%%
% A less obvious example: the linear compressibility in a direction |v|, the
% relative shortening along |v| under unit hydrostatic pressure. It is a
% contraction of the *compliance* tensor,
%
% $$ c = \sum_{i,j,k} S_{ijkk} v_i v_j $$
%
% where $S = C^{-1}$, obtained with <tensor.inv.html |inv|>, which inverts
% rank 2 and rank 4 tensors.

v = xvector;
S = inv(C)
c = EinsteinSum(S,[-1 -2 -3 -3],v,-1,v,-2)

%%
% 0.0018 per GPa along the a axis of this olivine, which is the value
% <stiffnessTensor.linearCompressibility.html |linearCompressibility|>
% returns for the same direction. Note that the contraction has to be over
% the compliance and not the stiffness: the same expression with |C| returns
% 460, a number in GPa that is not a compressibility of anything.

%% Shorthands
%
% Frequently used contractions have names. The stress from a strain is a
% double dot product, and either of these does what the |EinsteinSum| above
% did:

C * eps
C : eps

%%
% Between two rank 2 tensors the double dot product is their inner product,
% which is also the trace of a matrix product - three ways of writing one
% number:

T1 : T2
trace(T1 * T2')
trace(T1' * T2)

%% Determinant
%
% For a rank 2 tensor, <tensor.det.html |det|>:

det(T1)

%% Rotating a tensor
%
% A tensor describes a property in a particular frame, so a change of frame
% transforms it - once per index, which is what makes rotating a rank 4
% tensor more than a matrix conjugation. <tensor.rotate.html |rotate|> does
% it for any rank.

r = rotation.byEuler(45*degree,0*degree,0*degree);

%%

Trot = rotate(T1,r);
plot(Trot)

%%
% An example from Nye, Physical Properties of Crystals, p.120-121, for a
% third rank tensor: the piezoelectric modulus of a crystal with a single
% three fold axis, rotated by 45 degrees about z.

P = [ 0 0 0 .17 0   0;
      0 0 0 0   .17 0;
      0 0 0 0   0   5.17]*10^-11;

T = tensor(P,'rank',3,'propertyname','piezoelectric modulus')

r = rotation.byAxisAngle(zvector,-45*degree);
T = rotate(T,r)

%%
% Components that were zero before the rotation are no longer zero. Nothing
% about the crystal changed - a zero component only means that this
% particular pair of directions is unrelated, and after a rotation the
% directions are different ones.

%#ok<*NASGU>
%#ok<*ASGLU>
%#ok<*NOPTS>
