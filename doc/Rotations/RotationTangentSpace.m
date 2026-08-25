%% The Tangent Space on the Rotation Group
%
%%
% A tangent vector describes an instantaneous change of a rotation: the
% direction in which the rotation changes and the rate of that change.
% It is attached to one rotation $R$, called its base point. The collection
% of all tangent vectors attached to $R$ is the *tangent space* at $R$.
%
% This page assumes the active rotations introduced in
% <RotationDefinition.html Defining Rotations> and the multiplication order
% explained in <RotationOperations.html Calculating with Rotations>.
% <RotationSpinTensor.html Spin Tensors> develops the continuum-mechanics
% interpretation of an instantaneous rotation.
%
% Tangent vectors provide local, three-component coordinates for the curved
% rotation group SO(3). MTEX uses them for derivatives, gradients, and
% vector fields on SO(3), and for finite updates through the exponential
% map.

plottingConvention.default('y↑→x');

%% Left and Right Representations
%
% A tangent vector at $R$ is a $3 \times 3$ matrix, but it can be described
% by only three numbers. Those numbers form a skew-symmetric matrix $S$.
% The skew-symmetric matrix can multiply $R$ from the left or from the
% right:
%
% $$ T = S_{\rm left} R = R S_{\rm right}. $$
%
% These are two coordinate representations of the same tangent vector, not
% two different tangent spaces. In MTEX the left coordinates are expressed
% in the specimen frame and the right coordinates in the crystal frame.

R = rotation.byAxisAngle(vector3d.X,20*degree);
SLeft = spinTensor(vector3d(0,0,1));
SRight = spinTensor(vector3d(0,sin(20*degree),cos(20*degree)));

tangentLeft = matrix(SLeft) * matrix(R);
tangentRight = matrix(R) * matrix(SRight);

max(abs(tangentLeft-tangentRight),[],'all')

%%
% The residual is at round-off level, so both products describe the same
% tangent matrix. The coordinates in |SLeft| and |SRight| differ because
% their bases differ.

%% Tangent Vectors in MTEX
%
% MTEX stores the coordinates, the base point, and the left or right
% representation in an
% <SO3TangentVector.SO3TangentVector.html |SO3TangentVector|>. The base
% point is an orientation, so it is also the single source of any crystal
% and specimen symmetries carried by the tangent vector.

components = 0.2*vector3d(1,2,3);
vLeft = SO3TangentVector(components,R)

%%
% The display identifies |vLeft| as a |leftVector| and prints its three
% specimen-frame coordinates. The default representation is left.
%
% A tangent vector is drawn as an arrow attached to its base point.

plot(R,'axisAngle','MarkerColor','red')
axis off
hold on
quiver3(vLeft,'LineWidth',3,'maxHeadSize',4)
hold off

%%
% The red marker is the base rotation $R$. The blue arrow is a local
% direction at that point, not a second rotation in the surrounding space.
% Moving the same three coordinates to another base point would therefore
% define a different tangent vector.

%% Changing Representation
%
% Giving the same coordinates to the right-vector constructor does not
% convert |vLeft|. It defines a different tangent vector whose coordinates
% happen to be the same numbers.

vSameCoordinates = SO3TangentVector(components,R,...
  SO3TangentSpace.rightVector)

%%
% The |rightVector| label in the display is the essential difference.
% To express |vLeft| itself in right coordinates, use
% <SO3TangentVector.right.html |right|>.

vRight = right(vLeft)

%%
% The transformed coordinates differ from those of |vLeft|, while the base
% point and the geometric tangent vector stay fixed. The inverse conversion
% returns to the original coordinates.

vLeftAgain = left(vRight);
norm(vLeftAgain-vLeft)

%% Computing with Tangent Vectors
%
% MTEX converts compatible tangent vectors to a common representation
% before performing arithmetic. Thus adding |vLeft| to its right-coordinate
% representation gives twice the original vector.

vLeft + vRight

%%
% The following operations are available for tangent vectors |v1| and |v2|
% at the same base point:
%
% * sums, differences, scaling, and division
% * inner products with <SO3TangentVector.dot.html |dot(v1,v2)|>
% * cross products with <SO3TangentVector.cross.html |cross(v1,v2)|>
% * lengths with <vector3d.norm.html |norm(v1)|>
% * normalization with <vector3d.normalize.html |normalize(v1)|>
% * averages with <SO3TangentVector.mean.html |mean(v1)|>
%
% The last three operations use the vector operations inherited by
% |SO3TangentVector|. Arithmetic is defined only for tangent vectors at the
% same base point and with compatible symmetries.

%% Exponential and Logarithm Maps
%
% The exponential map follows a tangent direction for the finite angular
% step stored in the vector norm. It returns the endpoint on SO(3).

R2 = exp(vLeft);

%%
% The logarithm map reverses this construction. Given the endpoint first
% and the base point second, <quaternion.log.html |log|> returns the tangent
% vector at the base point that leads to the endpoint.

vBack = log(R2,R);
norm(vBack-vLeft)

%%
% The displayed residual confirms the round trip to numerical precision.
% Rotation logarithms use a principal branch. At a relative angle of
% $180^\circ$ the rotation axis, and therefore the logarithm, is not unique.
%
% Together, |log| and |exp| let an algorithm compute a local change in a
% flat tangent space and apply that change back on the curved rotation
% group. This is the pattern behind interpolation, averaging, and
% optimization of rotations.

%% The Maths Behind the Two Representations
%
% The tangent space at $R$ is
%
% $$ T_R SO(3)
%    = \{S R \mid S=-S^T\}
%    = \{R S \mid S=-S^T\}. $$
%
% The set of skew-symmetric matrices is the Lie algebra
% $\mathfrak{so}(3)$. Therefore the two equal descriptions are also written
% $\mathfrak{so}(3)R$ and $R\mathfrak{so}(3)$. Equating the tangent matrices
% gives the coordinate change
%
% $$ S_{\rm right}=R^{-1}S_{\rm left}R. $$
%
% The methods |right| and |left| apply this change of basis. They do not
% move the base point or change the geometric tangent vector.

%% References
%
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops the
% geometry of rotation space and small orientation changes for texture
% analysis.
% * P.-A. Absil, R. Mahony, and R. Sepulchre,
% <https://doi.org/10.1515/9781400830244 Optimization Algorithms on Matrix
% Manifolds>, Princeton University Press, 2008, introduces tangent-space
% methods and exponential updates for optimization on matrix manifolds.
% * R. Hartley, J. Trumpf, Y. Dai, and H. Li,
% <https://doi.org/10.1007/s11263-012-0601-0 Rotation Averaging>,
% International Journal of Computer Vision 103 (2013) 267--305, compares
% rotation-space metrics and averaging methods.

%% Next
%
% <RotationSpinTensor.html Spin Tensors> develops the skew-symmetric matrix
% description as a rate of rotation in a deforming material. With crystal
% and specimen symmetries attached, tangent vectors become
% <SO3FunVectorField.html vector fields on SO(3)>.

%#ok<*NOPTS>
