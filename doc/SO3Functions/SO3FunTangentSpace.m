%% The Tangent Space on the Rotation Group
%
%%
% The tangent space of the rotation group at some rotation $R$ has 2 
% different representations. There is a left and a right representation.
%
% The left tangent space is defined by
%
% $$ T_R SO(3) = \{ S \cdot R | S=-S^T  \} = \mathfrak{so}(3) \cdot R, $$
%
% where $\mathfrak{so}(3)$ describes the set of all skew symmetric matrices,
% i.e. @spinTensor's.
%

R = rotation.byAxisAngle(xvector,20*degree)
S1 = spinTensor(vector3d(0,0,1))
% left tangent vector
matrix(S1) * matrix(R)

%%
% Analogously the right tangent space is defined by
%
% $$ T_R SO(3) = \{ R \cdot S | S=-S^T  \} = R \cdot \mathfrak{so}(3). $$

% right tangent vector
S2 = spinTensor(vector3d(0,sin(20*degree),cos(20*degree)))
matrix(R)*matrix(S2)

%%
% Note that the left and right tangent spaces describes the same in 
% different notations.
%
% In MTEX a tangent vectors is defined by its @spinTensor and an attribute 
% which describes whether it is right or left.
% Moreover the @spinTensor is saved as @vector3d, in the following way:
%

vL = SO3TangentVector(vector3d(1,2,3))
S = spinTensor(vL)

%%
% Note that the default tangent space representation is left.
% We can construct an right tangent vector by

vR = SO3TangentVector(vector3d(1,2,3),SO3TangentSpace.rightVector)

%%
% Here |vL| and |vR| have the same coordinates in different spaces (bases). 
% Hence they describe different tangent vectors.
%
% We can also transform left tangent vectors to right tangent vectors and 
% vice versa. Therefore the rotation in which the tangent space is located
% is necessary.

vR = right(vL,R)
vL = left(vR,R)

%%
% We can do the same manually by

vR = inv(R)*vL
vL = R*vR


%% Vector Fields
%
%%
% Vector fields on the rotation group are functions that maps any rotation
% to an tangent vector. An important example is the gradient of an
% |@SO3Fun|.
%
% Hence any vector field has again a left and a right representation.
%

F = SO3Fun.dubna;
F.SS = specimenSymmetry;
%F = SO3FunHarmonic(F);
rot = rotation.rand(3);

% left gradient in rot 
F.grad(rot)

% right gradient in rot
inv(rot) .* F.grad(rot)
F.grad(rot,'right')

%%
% The gradient can also be computed as function, i.e. as @SO3VectorField,
% which internal is an 3 dimensional @SO3Fun.
%

GL = F.grad
GR = F.grad('right')

GL.eval(rot)
GR.eval(rot)

%%
% Again we are able to change the tangent space

left(GR)
right(GL)

%%
% Note that the symmetries do not work in the same way as for @SO3Fun's.
% Dependent from the chosen tangent space representation (left/right) one 
% of the symmetries has other properties.
% 
% In case of right tangent space the evaluation in symmetric orientations
% only make sense w.r.t. the left symmetry.
% In case of left tangent space vice versa.

ori = orientation.rand(GL.CS,GL.SS)
GR.eval(ori.symmetrise)
GL.eval(ori.symmetrise)

%#ok<*NASGU>