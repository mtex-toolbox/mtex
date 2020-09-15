%% Defining Tensorial Properties
%
% Physical laws describe the relationship between physical properties. The
% most simplest laws are linear ones and are of the form
%
% $$ y = \mathbf A x $$
%
% where $x$ and $y$ are the physical properties and $\mathbf A$ is a
% material constant. In a typical example $y$ could be the force applied to
% a spring, $x$ the displacement and $A$ describes the stiffnes of the
% spring which is essentially Hooks law.
%
% As soon as we consider more general forces and displacements they can not
% be described anymore by scalar numbers $x$ and $y$ but vectors or
% matrices are required. In its most general form the displacment is
% describes by a <strainTensor.html strain matrix> $\sigma_{ij}$ and the
% force is described by a stiffness matrix $\varepsilon_{kl}$. In this setting
% the linear relationship between the two matrices is described by the
% <complianceTensor.complianceTensor.html compliance tensor> $\mathbf
% C_{ijkl}$ which can be seen as a 4 dimensional generalization of a matrix.
%
% More, general a tensor of rank $r$ is a "matrix" of dimension $r$. If
% $r=0$ we speek of scalars, if $r=1$ these are vectors and for $r=2$ they
% are classical $3 \times 3$ matrices. 
%
% In the following we explain how tensors of arbitrary rank can be defined
% in MTEX. Independent of the rank any tensor is represented in MTEX by a
% variable of type @tensor.
%
%
%% Scalars (tensors of zero rank)
%
% In physics, properties like temperature or density are not connected 
% to any specific direction of the body they are measured. These 
% non-directional physical quantities are called scalars, and they are
% defined by a single number. In MTEX, a scalar is defined by:

M = 5;
t = tensor(M,'rank',0)

%% Vectors (tensors of first rank)
% 
% In contrast to scalars, other physical quantities can only be defined in
% reference to a specific direction. If we need to specify completely the
% mechanical force acting into a point for example, we need to specify 
% the magnitude and its direction. As an alternative, we can choose three
% mutually perpendicular axes (A1,A2 and A3) and give the vector components
% along them. In MTEX, this is done by:

t = tensor([1;2;3],'rank',1)

%%
% where 1, 2 and 3 are the components related to the axes A1, A2 and A3.
% As rank 1 tensors are essentialy vectors we can freely convert tensors to
% @vector3d and vice verca. 

% define a tensor from a vector
t = tensor(vector3d.X)

% convert a tensor into a vector
vector3d(t)

%% Matrices (tensors of second rank)
%
% We have now to expand the idea of a vector to three-dimensional space.
% Let's take the example of stress (force per unit of area). Imagine a cube
% of material subjected to load as shown below. As can be seen, one can
% measure ther stresses in this cube in various directions, and in various
% planes. These measurements will for a second rank sensor, where each
% component is associated with a pair of axes, taken in an specific order.
% The generalized second rank stress tensor can be written as
%
% $$
% \sigma_{ij} = 
% \begin{bmatrix}
% \sigma_{11} & \sigma_{12} & \sigma_{13}  \\
% \sigma_{21} & \sigma_{22} & \sigma_{23}  \\
% \sigma_{31} & \sigma_{32} & \sigma_{33}  \\
% \end{bmatrix}
% $$
%
% In MTEX, a second-rank tensor where only the main diagonal components are
% of interest is defined as

t = tensor(diag([1,2,3]), 'rank',2)

%%
% If all the components are of interest, the definition is as follow

M = [1     0.75  0.5;...
     0.75  1     0.25;...
     0.5   0.25  1];

t = tensor(M,'rank',2)

%% Tensors (tensors of third rank)
%
% Smart materials are materials that have one or more properties that
% change significantly under external stimuli. A typical example is the
% voltage resulting to applied stress that certain materials have, named
% piezoeletric effect. This property is described as a third rank tensor
% that relates induced electric displacement vector to the second-order
% stress tensor. This is expressed in the form $P_i=d_{ijk} \sigma_{jk}$.
% In MTEX, a third rank tensor can be described as

M =[[-1.9222  1.9222    0   -0.1423     0         0    ];...
    [   0        0      0       0     0.1423    3.8444];...
    [   0        0      0       0       0         0    ]];

t = tensor(M,'rank',3)
    
%% Tensors (tensors of fourth rank)
%
% Fourth rank tensors are tensors that describe the relation between 2
% second rank tensors. A typical example is the tensor describing the
% elastic properties of materials, which translate the linear relationship
% between the second rank stress and infinitesimal strain tensors. The
% Hooke's Law describing the shape changes in a material subject to stress
% can be written as $\sigma_{ij}=c_{ijkl} \epsilon_{kl}$, where $c_{ijkl}$
% is a fourth rank tensor.
%
% The four indices (ijkl) of the elastic tensor have values between 1 and
% 3, so that there are $3^4=81$ coefficients. As the stress and strain
% tensors are symmetric, both stress and strain second rank tensors only
% have 6 independent values rather than 9. In addition, crystal symmetry
% reduces even more the number of independent components on the elastic
% tensor, from 21 in the case of triclinic phases, to 3 in the case of
% cubic materials. In MTEX, a fourth rank tensor can be defined as:

M = [[320   50  50   0     0     0];...
    [  50  320  50   0     0     0];...
    [  50   50 320   0     0     0];...
    [   0    0   0  64     0     0];...
    [   0    0   0   0    64     0];...
    [   0    0   0   0     0    64]];

C = tensor(M,'rank',4)  

%%
% Note the repetition in values in this matrix is related to crystal
% symmetry, in this case, a cubic example, where only $C_{11}$, $C_{12}$
% and $C_{44}$ are independent components.
%
%% Specific tensors
%
% MTEX includes specific classes for the following tensors.
%
% || *name* || *rank* || *symbol* || *name* || *rank* || *symbol* ||
% || @complianceTensor || 4 || $S_{ijkl}$ || @stiffnessTensor || 4 || $C_{ijkl}$ ||
% || @strainTensor || 2 || $\sigma_{ij}$  || @stressTensor || 2 || $\varepsilon_{ij}$ ||
% || @strainRateTensor || 2 || $E$ || @velocityGradientTensor || 2 || $L$ ||
% || @curvatureTensor || 2 || $\kappa_{ij}$ || @deformationGradientTensor || 2 || $F$ ||
% || @refractiveIndexTensor || 2 || $\chi$ || @ChristoffelTensor || 2 || $M_ij$ || 
% || @dislocationDensityTensor || 2 || $\alpha$  || @SchmidTensor || 2 || $M_{ij}$ ||
% || <tensor.leviCivita.html |leviCivita|> || 3 || $\varepsilon_{ijk}$ || @spinTensor || 2 || $\Omega$ ||
%
% Those specific tensors are defined by the syntax

M = [0 0 0;...
  0 0 0; ...
  0 0 1];

e = strainTensor(M)

%%
% In many cases shortcuts exist like

e = stressTensor.uniaxial(vector3d.Z)

%%
% The advantage of using these specific tensor classes is that some tensor
% operations like <stressTensor/calcShearStress.html |calcShearStress(e)|>
% are defined only for specific tensor classes.
%
%% Predefined tensors
%
% For certain applications, one may want to have a tensor where all the
% components are 1. In MTEX this is computed as

t = tensor.ones('rank',2)

%%
% *Identity tensor*
%
% The Identity tensor is a second order tensor that has ones n the main 
% diagonal and zeros otherwise. The identity matrix has some special
% properties, including (i) When multiplied by itself, the result is itself
% and (ii) rows and columns are linearly independent. In MTEX, this matrix
% can be computed as

t = tensor.eye('rank',2)

%%
% *Random tensors*
%
% One can also define a tensor in which the components are pseudorandom, by
% using the function |<tensor.rand.html tensor.rand>|

t = tensor.rand('rank',2)

%%
% *The Levi Civita tensor*
%
% The Levi-Civita symbol $\epsilon_{ijk}$ is a third rank tensor and is
% defined by 0, if $i=j$, $j=k$ or $k=1$, by 1, if $(i,j,k)=(1,2,3)$,
% $(2,3,1)$ or $(3,1,2)$ and by $-1$, if $(i,j,k)=(3,2,1)$, $(1,3,2)$ or
% $(2,1,3)$. The Levi-Civita symbol allows the cross product of two vectors
% in 3D Euclidean space and the determinant of a square matrix to be
% expressed in Einstein's index notation. With MTEX the Levi Civita tensor
% is expressed as

t = tensor.leviCivita
