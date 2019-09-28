%% Definition 
%
%


%% Rank zero tensors

M = 5;
t = tensor(M,'rank',0)

%% Rank one tensors

M = [1,2,3]
t = tensor(M,'rank',1)

%%

M = tensor(vector3d.X)

%% Rank two tensors

M = diag([1,2,3])

t = tensor(M,'rank',2)

%%

t = tensor(rotation.rand)

%% Rank three tensors
%

M = [ 0     0     0 -0.67     0   4.6 ;...
      2.3  -2.3     0     0  0.67     0;...
      0     0     0     0     0     0]

 t = tensor(M,'rank',3)   
    
%% Rank four tensors


%% Specific tensors

tensor.ones('rank',2)

%%

tensor.eye('rank',2)

%% 
%
tensor(diag([1,2,3]),'rank',2)

%%

tensor.leviCivita


%% Matter tensors


%% Importing a Tensor from a File
% Especially for higher order tensors, it is more convenient to import the
% tensor entries from a file. As an example, we load the following
% elastic stiffness tensor

fname = fullfile(mtexDataPath,'tensor','Olivine1997PC.GPa');

cs = crystalSymmetry('mmm',[4.7646 10.2296 5.9942],'mineral','olivine');

C = stiffnessTensor.load(fname,cs)



