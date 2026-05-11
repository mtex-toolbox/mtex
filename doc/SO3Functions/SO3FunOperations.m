%% Operations on Rotational Functions
%
%%
% The idea of variables of type @SO3Fun is to calculate with rotational
% functions similarly as MATLAB does with vectors and matrices. In order to
% illustrate this we consider the following two rotational functions
%
% An ODF determined from XRD data
SO3F1 = SO3Fun.dubna

plot(SO3F1,'sigma')

%%
% and an unimodal distributed ODF

R = orientation.byAxisAngle(vector3d.Y,pi/4,SO3F1.CS);
SO3F2 = SO3FunRBF(R,SO3DeLaValleePoussinKernel)

plot(SO3F2,'sigma')

%% Basic arithmetic operations
% Now the sum of these two rotational functions is again a rotational
% function, i.e., a function of type <SO3Fun.SO3Fun.html |SO3Fun|>

1 + 2 * SO3F1 + SO3F2

plot(2 * SO3F1 + SO3F2,'sigma')

%%
% Accordingly, one can use all basic operations like |-|, |*|, |^|, |/|,
% <SO3Fun.min.html |min|>, <SO3Fun.max.html |max|>, <SO3Fun.abs.html
% |abs|>, <SO3Fun.sqrt.html |sqrt|> to calculate with variables of type
% @SO3Fun.

% the maximum between two functions
plot(max(2*SO3F1,SO3F2),'sigma');


%%

% the minimum between two functions
plot(min(2*SO3F1,SO3F2),'sigma');

%%
% We also can work with the pointwise <SO3Fun.conj.html |conj|>, 
% <SO3Fun.exp.html |exp|> or <SO3Fun.log.html |log|> of an |SO3Fun|.
%
% For a given function $f\colon SO(3) \to \mathbb C$ we get a second
% function $g\colon SO(3) \to \mathbb C$ where $g( {\bf R}) = f( {\bf
% R}^{-1})$ by the method <SO3Fun.inv.html |inv|>, i.e.

g = inv(SO3F1)

SO3F1.eval(R)
g.eval(inv(R))

%% Local Extrema
% 
% The above mentioned functions <SO3Fun.min.html |min|> and
% <SO3Fun.max.html |max|> have very different use cases
%
% * if a single rotational function is provided the global maximum /
% minimum of the function is computed
% * if two rotational functions are provided, a rotational function defined
% as the pointwise min/max between these two functions is computed
% * if a rotational function and a single number are passed as arguments a
% rotational function defined as the pointwise min/max between the function
% and the value is computed
% * if additionally the option |'numLocal'| is provided the certain number
% of local minima / maxima is computed

plot(2 * SO3F1 + SO3F2,'phi2',(0:3)*30*degree)

% compute and mark the global maximum
[maxValue, maxNodes] = max(2 * SO3F1 + SO3F2,'numLocal',2)
annotate(maxNodes)

%% Integration
% The surface integral of a spherical function can be computed by either
% <SO3Fun.mean.html |mean|> or <SO3Fun.sum.html |sum|>. The difference
% between both commands is that <SO3Fun.sum.html |sum|> normalizes the
% integral of the identical function on the rotation group to $8 \pi^2$,
% the command <SO3Fun.mean.html |mean|> normalizes it to one. Compare

mean(SO3F1)

sum(SO3F1) / ( 8 * pi^2 )

%%
% A practical application of integration is the computation of the
% $L^2$-norm which is defined for a $SO(3)$ function $f$ by
%
% $$ \| f\|_2 = \left( \frac{1}{8\pi^2} \int_{SO(3)} \lvert f({\bf R}) \rvert^2 \,\mathrm d {\bf R} \right)^{1/2} $$
%
% accordingly we can compute it by

sqrt(mean(abs(SO3F1).^2))

%%
% or more efficiently by the command <SO3Fun.norm.html |norm|>

norm(SO3F1)

%% Differentiation
% The gradient of an $SO(3)$ function in a specific point is described
% by a <SO3TangentVector.SO3TangentVector.html SO3TangentVector>-object, 
% which can be computed by the command <SO3Fun.grad.html |grad|>

grad(SO3F1,R)

%%
% This |SO3TangentVector| describes an element of a tangent space on the 
% rotation group $SO(3)$ at some specific rotation.
%
% For detailed information on this tangent space representation, see
% <RotationTangentSpace.html Tangent Space Representation on SO(3)>
%
%%
% The gradients of a $SO(3)$ function in all points form a $SO(3)$
% vector field and are returned by the function <SO3Fun.grad.html |grad|> 
% as a variable of type @SO3VectorFieldHarmonic.

% compute the gradient as a vector field
G = grad(SO3F1)

% plot the gradient on top of the function
plot(SO3F1,'sigma')
hold on
plot(G,'color','black','linewidth',1,'resolution',5*degree)
hold off

%%
% We observe long arrows at the positions of big changes in intensity and
% almost invisible arrows in regions of constant intensity.
%
% Note that, roughly speaking, the gradient at a given rotation indicates 
% the direction of steepest ascent of |SO3F1|. 
% In the above plot, this gradient is represented by an arrow pointing 
% along that direction.
% By following this arrow via the exponential map, one obtains a new rotation.
%
%% Rotating orientation dependent functions
% Rotating an orientation dependent function works with the command
% <SO3Fun.rotate.html |rotate|>

% define a rotation
rot = rotation.byEuler(30*degree,0*degree,90*degree,'Bunge');

% rotate the ODF
SO3F = rotate(SO3FunHarmonic(2 * SO3F1 + SO3F2),rot)

% and plot it
plot(SO3F,'sigma')
