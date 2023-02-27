%% SO3VectorField
%
% <SO3VectorField.SO3VectorField SO3VectorField> handles three-dimensional functions on the rotation group. For
% instance the gradient of an univariate <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|> can return a
% <SO3VectorFieldHarmonic.SO3VectorFieldHarmonic SO3VectorFieldHarmonic>.
%
%% Defining a SO3VectorFieldHandle
%
%%
% Analogous to |@SO3FunHandle| we are able to define |SO3VectorFields|
% by an
% <https://de.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
% anonymous function>.
%

f = @(rot) vector3d(rot.phi1, rot.phi2, 0*rot.phi1);

SO3VF = SO3VectorFieldHandle(f)


%%
% Note that the evaluations are of class |@vector3d|
%

rot = rotation.rand(2);
SO3VF.eval(rot)

%% Defining a SO3VectorFieldHarmonic
%
%%
% *Definition via SO3VectorField*
%
% We can expand any |@SO3VectorField| in an |@SO3VectorFieldHarmonic| 
% directly by the command |SO3VectorFieldHarmonic|
%

SO3VectorFieldHarmonic(SO3VF)

%%
% *Definition via function values*
%
% At first we need some example rotations
nodes = equispacedSO3Grid(specimenSymmetry('1'),'points',1e3);
nodes = nodes(:);
%%
% Next, we define function values for the rotations
y = vector3d.byPolar(sin(3*nodes.angle), nodes.phi2+pi/2);
%%
% Now the actual command to get |SO3VF1| of type |SO3VectorFieldHarmonic|
SO3VF1 = SO3VectorFieldHarmonic.approximation(nodes, y)

%%
% *Definition via function handle*
%
% If we have a function handle for the function we could create a
% |S2VectorFieldHarmonic| via quadrature. At first lets define a function
% handle which takes <rotation.rotation.html |rotation|> as an argument and
% returns a <vector3d.vector3d.html |vector3d|>:


%% 
% Now we can call the quadrature command to get |SO3VF2| of type
% |SO3VectorFieldHarmonic|
SO3VF2 = SO3VectorFieldHarmonic.quadrature(@(v) f(v))

%%
% *Definition via <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|>*
%
% If we directly call the constructor with a multivariate
% <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|> with three entries it 
% will create a |SO3VectorFieldHarmonic| with |SO3F(1)|, |SO3F(2)|, and 
% |SO3F(3)| the $x$, $y$, and $z$ component.

SO3F = SO3FunHarmonic(rand(1e3, 3))
SO3VF3 = SO3VectorFieldHarmonic(SO3F)

%% Operations
%
%%
%
% *Basic arithmetic operations*
%
% Again the basic mathematical operations are supported:
%%
% addition/subtraction of a vector field and a vector or addition/subtraction of two vector fields
SO3VF1 + SO3VF2; SO3VF1+vector3d(1, 0, 0);
SO3VF1-SO3VF2; SO3VF2-vector3d(sqrt(2)/2, sqrt(2)/2, 0);

%%
% multiplication/division by a scalar or a |SO3Fun|
2.*SO3VF1; SO3VF1./4;
SO3F = SO3FunHarmonic.example;
SO3F.SRight = specimenSymmetry;
SO3F .* SO3VF1;

%%
% dot product with a vector or another vector field
dot(SO3VF1, SO3VF2); dot(SO3VF1, vector3d(0, 0, 1));

%%
% cross product with a vector or another vector field
cross(SO3VF1, SO3VF2); cross(SO3VF1, vector3d(0, 0, 1));

%%
% mean vector of the vector field
mean(SO3VF1);

%%
% rotation of the vector field
r = rotation.byEuler( [pi/4 0 0]);
rotate(SO3VF1, r);

%%
% pointwise norm of the vectors
norm(SO3VF1);


%% Visualization
%
% One can use the default |plot|-command
plot(SO3VF1);

%%
% * same as quiver(sVF1)

%%
% or the 3D plot of the rotation group with the vectors on itself
clf;
quiver3(SO3VF2);
