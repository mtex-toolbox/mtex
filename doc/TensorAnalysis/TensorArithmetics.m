%% Tensor Arithmetics
% how to calculate with tensors in MTEX
%%
% MTEX offers some basic functionality to calculate with tensors as they
% occur in material sciense. It allows defining tensors of arbitrary rank,
% e.g., stress, strain, elasticity or piezoelectric tensors, to visualize
% them and to perform various transformations.
%
%% Open in Editor
%
%% Contents
%
%% Defining a Tensor
%
% A tensor is defined by its entries and a crystal symmetry. Let us
% consider a simple example. First, we define some crystal symmetry

cs = crystalSymmetry('1');

%%
% Next, we define a two rank tensor by its matrix

M = [[10 3 0];[3 1 0];[0 0 1]];
T = tensor(M,cs)

%%
% In case the two rank tensor is diagonal the syntax simplifies to

T = tensor(diag([10 3 1]),cs)

%% Importing a Tensor from a File
% Especially for higher order tensors, it is more convenient to import the
% tensor entries from a file. As an example, we load the following
% elastic stiffness tensor

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','olivine');

C = stiffnessTensor.load(fname,cs)


%% Visualization
% The default plot for each tensor is its directional magnitude, i.e. for each direction
% x it is plotted Q(x) = T_ijkl x_i x_j x_k x_l

setMTEXpref('defaultColorMap',blue2redColorMap);
plot(C,'complete','upper')

%%
% There are more specialized visualization possibilities for specific
% tensors, e.g., for the elasticity tensor. See section
% <ElasticityTensor.html Elasticity Tensor>.

%% Rotating a Tensor
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

%% Tensor Products
% In MTEX tensor products are specifies according to Einsteins summation
% convention, i.e. a tensor product of the form T_ij = E_ijkl S_kl has to
% be interpreted as a sum over the indices k and l. In MTEX this sum can be
% computed using the command <tensor.EinsteinSum.html EinsteinSum>

S = EinsteinSum(C,[-1 -2 1 2],T,[-1 -2])

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
% set back the default color map.

setMTEXpref('defaultColorMap',WhiteJetColorMap)
