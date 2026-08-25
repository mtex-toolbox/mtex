%% The Tangent Space on the Rotation Group
%
%%
% A tangent vector on the rotation group is a direction in which a rotation
% can be varied - the answer to "which way could this rotation move, and how
% fast?". Such a direction depends on the rotation it starts from, so it is
% a local object, not a global one, and the set of all of them at a given
% rotation is the *tangent space* there.
%
% This is the language in which gradients, velocities and derivatives on
% SO(3) are written. It is what makes optimisation and interpolation of
% rotations possible at all, since rotation space is curved and the usual
% "add a small vector" does not apply to it directly.
%
%% Definition of Tangent Spaces and Tangent Vectors on the Rotation Group
%
% First we start with a (slightly technical) mathematical description of
% the tangent space by |@spinTensor's|, which are used to describe small
% rotational changes. For more information take a look
% <RotationSpinTensor.html here> in the documentation.
%
% The tangent space of the rotation group at some rotation $R$ has two
% different representations. There is a left and a right tangent space 
% representation.
%
% The left tangent space is defined by
%
% $$ T_R SO(3) = \{ S \cdot R | S=-S^T  \} = \mathfrak{so}(3) \cdot R, $$
%
% where $\mathfrak{so}(3)$ describes the set of all skew symmetric matrices,
% i.e. @spinTensor's.
%

R = rotation.byAxisAngle(vector3d.X,20*degree);
S1 = spinTensor(vector3d(0,0,1))

% left tangent vector at some Rotation R
TV = matrix(S1) * matrix(R)

%%
% The right tangent space is defined analogously:
%
% $$ T_R SO(3) = \{ R \cdot S | S=-S^T  \} = R \cdot \mathfrak{so}(3). $$
%
% Again, skew-symmetric matrices describe all possible infinitesimal
% rotations, but now applied on the right side of R.

S2 = spinTensor(vector3d(0,sin(20*degree),cos(20*degree)))
% right tangent vector at some rotation R
TV = matrix(R)*matrix(S2)

%%
% The left and the right tangent space contain the same tangent vectors,
% written in different bases. |S1| and |S2| above are the two descriptions
% of one and the same tangent vector, which is why the two matrices agree.

max(abs(matrix(S1)*matrix(R) - matrix(R)*matrix(S2)),[],'all')

%
%% Description of Rotational Tangent Vectors in MTEX
% 
% In MTEX, tangent vectors are represented as objects of the class
% |@SO3TangentVector|. Therefore the three distinguish entries of the
% |@spinTensor| $S$ are stored as |@vector3d|, in the following way:
%
S = spinTensor(0.2*vector3d(1,2,3))
v1 = SO3TangentVector(S,R)

%%
% Such a tangent vector is drawn as an arrow attached to its base point.

% plot the base point
plot(R,'axisAngle','MarkerColor','red')
axis off

% plot the tangent vector
hold on
h = quiver3(v1,'LineWidth',3,'maxHeadSize',4);
hold off

%%
% The red marker is the rotation $R$, the arrow the direction in which $R$
% is being varied. Attached at a different rotation the same three
% coordinates would mean a different variation - that is what "local" means
% here.
%
% A |@SO3TangentVector| carries three pieces of information:
% 
% * the rotation $R$ (which defines the tangent space)
% * the tangent space representation (left or right)
% * underling symmetries (relevant for orientations)
%
%%
% By default, the tangent space representation is left. A right tangent
% vector can be constructed as follows:

v2 = SO3TangentVector(vector3d(1,2,3),R,SO3TangentSpace.rightVector)

%%
% Here |v1| and |v2| have the same coordinates in different bases (tangent 
% space representations). Hence they describe different tangent vectors.
%
%%
% Left and right tangent vectors can be easily transformed into each other:

v1_right = right(v1)
v1_left = left(v1_right)

%%
% MTEX keeps track of which representation a vector is in, and converts
% before it computes, so mixing the two in one expression is safe. Adding a
% vector to itself in the other representation gives twice the vector, not
% something else.

v1 + v1_right

%% Operations of Rotational Tangent Vectors
% 
% The following operations are defined for rotational tangent vectors |TV|, |TV1|, |TV2|
%
% * basic arithmetic operations: sum, difference, scaling, quotient
% * inner product <SO3TangentVector.dot.html |dot(TV1,TV2)|>
% * cross product <SO3TangentVector.cross.html |cross(TV1,TV2)|>
% * norm <vector3d.norm.html |norm(TV)|>
% * normalize <vector3d.normalize.html |normalize(TV)|>
% * average <SO3TangentVector.mean.html |mean(TV)|>
%
%%
% *Exponential and Logarithm Map of Tangent Vectors*
%
% In the context of the rotation group SO(3), the exponential and 
% logarithm maps provide the link between tangent vectors and rotations.
%
%%
% The exponential map takes a tangent vector (an infinitesimal rotation)
% and returns the corresponding finite rotation in SO(3). It is performed
% onto the tangent vector |v1| with the command <SO3TangentVector.exp.html
% |exp|>.

rot = exp(v1)

%%
% The logarithm map does the reverse: given two rotations it returns the
% tangent vector at the first that points towards the second. It is
% <quaternion.log.html |log|>.

log(rot,R)

%%
% The vector we started from, to the last digit - |log| and |exp| are
% inverse to each other.
%
% Together they connect the curved geometry of SO(3) with the flat structure
% of its tangent spaces, which is what interpolation, averaging and
% optimisation on rotations are built on.

%% Next
%
% The skew symmetric matrices behind all of this, and their reading as a
% rate of rotation in a deforming material, are
% <RotationSpinTensor.html Spin Tensors>. The same construction with a
% crystal symmetry attached appears in
% <SO3FunVectorField.html vector fields on SO(3)>.

%#ok<*NOPTS>
