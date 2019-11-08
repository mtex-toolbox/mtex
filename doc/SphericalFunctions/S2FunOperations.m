%% Operations on Spherical Functions
%
%%
% The idea of variables of type @S2Fun is to calculate with spherical
% functions similarly as Matlab does with vectors and matrices. In order to
% illustrate this we consider the following two spherical functions

sF1 = S2Fun.smiley;
sF2 = S2FunHarmonic.unimodal('halfwidth',10*degree)

plot(sF1,'upper')
nextAxis
plot(sF2,'upper')

%% Basic arithmetic operations
% Now the sum of these two spherical functions is again a spherical
% function

1 + 15 * sF1 + sF2

plot(15 * sF1 + sF2,'upper')

%%
% Accordingly, one can use all basic operations like |-|, |*|, |^|, |/|,
% <S2Fun.min.html |min|>, <S2Fun.max.html |max|>, <S2Fun.abs.html |abs|>,
% <S2FunHarmonic.sqrt.html |sqrt|> to calculate with variables of type
% @S2Fun.

% the maximum between two functions
plot(max(15*sF1,sF2),'upper');

nextAxis
% the minimum between two functions
plot(min(15*sF1,sF2),'upper');

%% Local Extrema
% 
% The obove mentioned functions <S2Fun.min.html |min|> and <S2Fun.max.html
% |max|> have very different use cases
%
% * if two spherical functions are passed as arguments a spherical
% functions defined as the pointwise min/max between these two functions is
% computed
% * if a spherical function and single number are passed as arguments a
% spherical functions defined as the pointwise min/max between these the
% function and the value is computed
% * if only a single spherical function is provided the global maximum /
% minimum of the function is returned
% * if additionally the option 'numLocal' is provided the certain number of
% local minima / maxima is computed


plot(15 * sF1 + sF2,'upper')

% compute and mark the global maximum
[maxvalue, maxnodes] = max(15 * sF1 + sF2);
annotate(maxnodes)

% compute and mark the local minimum
[minvalue, minnodes] = min(15 * sF1 + sF2,'numLocal',2);
annotate(minnodes)


%% Integration
% The surface integral of a spherical function can be computed by either
% <S2Fun.mean.html |mean|> or <S2Fun.sum.html |sum|>. The difference
% between both commands is that <S2Fun.sum.html |sum|> normalizes the
% integral of the identical function on the sphere to $4 \pi$ the command
% <S2Fun.mean.html |mean|> normalizes it to one. Compare

mean(sF1)

sum(sF1) / ( 4 * pi )

%%
% A practical application of integration is the computation of the
% $L^2$-norm which is defined for a spherical function $f$ as
%
% $$ \lVert f \rVert_2 = \left(\int_{\mathrm{sphere}} f(x)^2 dx\right)^{1/2} $$
%
% accordingly we can compute it by

sqrt(sum(sF1.^2))

%%
% or more efficiently by the command <S2FunHarmonic.norm.html |norm|>

norm(sF1)

%% Differentiation
%
% The differential of a spherical function in a specific point is a
% gradient, i.e., a <vector3d.vector3d.html three-dimensional vector> which
% can be computed by the command <S2Fun.grad.html |grad|>

grad(sF1,xvector)

%%
% The gradients of a spherical function in all points form a spherical
% vector field and are returned by the function <S2Fun.grad.html |grad|> as a
% variable of type @S2VectorFieldHarmonic.

% compute the gradient as a vector field
G = grad(sF1)

% plot the gradient on top of the function
plot(sF1,'upper')
hold on
plot(G)
hold off

%%
% We observe long arrows at the positions of big changes in intensity and
% almost invisible arrows in regions of constant intensity.
%
%% Rotating spherical functions
% Rotating a spherical function works with the command <S2Fun.rotate.html
% |rotate|>

% define a rotation
rot = rotation.byAxisAngle(yvector,-30*degree)

% plot the rotated spherical function
plot(rotate(15 * sF1 + sF2,rot),'upper')


%%
% A special case of rotation is symmetrysing it with respect to some
% symmetry. The following example symmetrises our smiley with respect to
% a two fold axis in $z$-direction 

% define the symmetry
cs = crystalSymmetry('112');

% compute the symmetrised function
sFs = symmetrise(sF1, cs)

% plot it
plota2east
plot(sFs,'upper','complete')

%%
% The resulting function is of type @S2FunHarmonicSym and knows about its
% symmetry.
