%% S2FunHarmonic
%
% S2FunHarmonic is the heart of S2Fun, therefore much effort is put into its functionality.
%
%% Contents
%

%%
% In the first part we will cover how to deal with univariate functions of the form
%
% $$f\colon \bf S^2\to \bf R.$$

%% Defining an univariate S2FunHarmonic
%%
% *Definition via function values*
%
% At first we need some vertices
nodes = equispacedS2Grid('resolution',3*degree,'antipodal');
nodes = nodes(:);
%%
% next we need to define function values for the vertices
y = S2Fun.smiley(nodes);
% plot the discrete data
plot(nodes,y)

%%
% Finally the actual command to get |sF1| of type |S2FunHarmonic|
sF1 = interp(nodes, y, 'harmonicApproximation')
% plot the spherical function
plot(sF1)

%%
% * The |bandwidth| property shows the maximal polynomial degree of the
% function.Internally for a given bandwidth there are stored
% $(\mathrm{bandwidth}+1)^2$ Fourier-coefficients.
% * The |antipodal| flag shows that $f(v) = f(-v)$ holds for all $v\in\bf
% S^2$.
%
% For the same result we could also run
% |S2FunHarmonic.approximation(nodes, y)| and give some additional options
% (<S2FunHarmonic.approximation.html see here>).

%%
% *Definition via function handle*
%
% If we have a function handle for the function we could create a
% |S2FunHarmonic| via quadrature. At first lets define a function handle
% which takes <vector3d.vector3d.html |vector3d|> as an argument and returns
% double:

f = @(v) 0.1*(v.theta+sin(8*v.x).*sin(8*v.y));
% plot the function at discrete points
plot(nodes,f(nodes))


%% 
% Now we can call the quadrature command to get |sF2| of type |S2FunHarmonic|
sF2 = S2FunHarmonic.quadrature(f, 'bandwidth', 150)

plot(sF2)

%%
% * If we would leave the |'bandwidth'| option empty the default bandwidth would be considered, which is 128.
% * The quadrature is faster than the approximation, because it does not have to solve a system of equations. But the knowledge of the function handle is also a strong requirement.
% * For more options <S2FunHarmonic.quadrature.html see here>.

%%
% *Definition via Fourier-coefficients*
%
% If we already know the Fourier-coefficients, we can simply hand them as a column vector to the constructor of |S2FunHarmonic|
fhat = rand(25, 1);
sF3 = S2FunHarmonic(fhat)


