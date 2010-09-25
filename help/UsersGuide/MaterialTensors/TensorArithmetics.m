%% Tensor Arithmetics
% how to calculate with tensors in MTEX

%% Open in Editor
%
%% Abstract
% MTEX offers some basic functionality to calculate with tensors as they
% occur in material sciense. It allows to define tensors of arbitrary rank,
% e.g., stress, strain, elasticity or piezoelectric tensors, visuallize
% them and to perform various transformations.
%
%% Contents

%% Defining a Tensor
%
% A tensor is defined by its entries and a crystal symmetry. Let us
% consider a simple example. First we define some crystal symmetry

cs = symmetry('-1');

%%
% Next we define a two rank tensor by it matrix

M = [[10 3 0];[3 1 0];[0 0 1]];
T = tensor(M,cs)

%%
% In case a two rank tensor is diagonal one can write

T = tensor(diag([10 3 1]),cs)

%% Importing a Tensor from a File
% Especially for higher order tensors it is more convinient to import the
% tensor entries from a file. This can be done by the command

T = loadTensor('tensor.txt');

%% Visualization
% The default plot for each tensor is its quadric, i.e. for each direction
% x it is plotted Q(x) = T_ijkl x_i x_j x_k x_l

plot(T)

%%
% There are more specialized visuallition possibilities for specific
% tensors, e.g., for the elasticity tensor.

%% Rotating a Tensor
% Rotation a tensor is done by the command <tensor/rotate.html rotate>.
% Lets define a rotation

r = rotation('Euler',45*degree,0*degree,0*degree)

%%
% Then the rotated tensor is given by

Trot = rotate(T,r)
plot(Trot)

%% 





plot(Trot);

%%

odf = unimodalODF(rotation('Euler',45*degree,0,0),cs,symmetry);

TODF = calcTensor(odf,T)

plot(TODF)

%% load a Tensor

E = load('Olivine1997PC.mat');

T = tensor(E.T,'name','elasticity',cs);

plot(T)

%%

plot(rotate(T,rotation('Euler',0*degree,45*degree,0)),'PlotType','YoungsModulus')

%%

plot(rotate(T,rotation('Euler',0*degree,45*degree,0)),'PlotType','linearCompressibility')

%%

plot(T,'PlotType','vs1')

hold on

plot(T,'PlotType','ps1','resolution',10*degree,'ShowArrowHead','off','color','k')

hold off
