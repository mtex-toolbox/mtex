%% Defining Tensorial Properties
%
%% TODO
% Please extend this chapter.
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

