%% Univariate |S2FunHarmonic|
%
%% Defining a |S2FunHarmonic|
%
%%
% *Definition via function values*
%
% At first you need some vertices
nodes = equispacedS2Grid('resolution',3*degree,'antipodal');
nodes = nodes(:);
%%
% Next you define function values for the vertices
y = S2Fun.smiley(nodes);

% plot the discrete data
plot(nodes,y)

%%
% Now the actual command to get |sF1| of type |S2FunHarmonic|
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
% For the same result you could also run
% |S2FunHarmonic.approximation(nodes, y)| and give some additional options
% (<S2FunHarmonic.approximation.html see here>).

%%
% *Definition via function handle*
%
% If you have a function handle for the function you could create a
% |S2FunHarmonic| via quadrature. At first lets define a function handle
% which takes <vector3d_index.html |vector3d|> as an argument and returns
% double:

f = @(v) 0.1*(v.theta+sin(8*v.x).*sin(8*v.y));

% plot the function at discrete points
plot(nodes,f(nodes))


%% 
% Now you can call the quadrature command to get |sF2| of type |S2FunHarmonic|
sF2 = S2FunHarmonic.quadrature(f, 'bandwidth', 150)

plot(sF2)

%%
% * If you would leave the |'bandwidth'| option empty the default bandwidth would be considered, which is 128.
% * The quadrature is faster than the approximation, because it does not have to solve a system of equations. But the knowledge of the function handle is also a strong requirement.
% * For more options <S2FunHarmonic.quadrature.html see here>.

%%
% *Definition via Fourier-coefficients*
%
% If you already know the Fourier-coefficients, you can simply hand them as a column vector to the constructor of |S2FunHarmonic|
fhat = rand(25, 1);
sF3 = S2FunHarmonic(fhat)

%% Operations
% The idea of |S2Fun| is to calculate with functions like Matlab does with vectors and matrices.
%
% *Basic arithmetic operations*
%
%%
% addition/subtraction
sF1+sF2; sF1+2;
sF1-sF2; sF2-4;

%%
% multiplication/division
sF1.*sF2; 2.*sF1;
sF1./(sF2+1); 2./sF2; sF2./4;

%%
% power
sF1.^sF2; 2.^sF1; sF2.^4;

%%
% absolute value of a function
abs(sF1);


%%
% *min/max*
%
%%
% calculates the local min/max of a single function
[minvalue, minnodes] = min(sF1);
[maxvalue, maxnodes] = max(sF1);

%%
% * as default |min| or |max| returns the smallest or the biggest value (global optima) with all nodes for which the value is obtained
% * with the option |min(sF1, 'numLocal', n)| the |n| nodes with the belonging biggest or smallest values are returned
% * |min(sF1)| is the same as running <S2Funharmonic.steepestDescent.html |steepestDescent|>|(sF1)|
%%
% min/max of two functions in the pointwise sense
%
min(sF1, sF2);

%%
% * See all options of min/max <S2FunHarmonic.min.html here>

%%
% *Other operations*
%%
% calculate the $L^2$-norm, which is only the $l^2$-norm of the Fourier-coefficients
norm(sF1);

%%
% calculate the mean value of a function
mean(sF1);

%%
% calculate the surface integral of a function
sum(sF1);

%%
% rotate a function
r = rotation.byEuler( [pi/4 0 0]);
rotate(sF1, r);

%%
% symmetrise a given function
cs = crystalSymmetry('6/m');
sFs = symmetrise(sF1, cs);

%%
% * |sFs| is of type <S2FunHarmonicSym_index.html |S2FunHarmonicSym|>

%%
% *Gradient*
%%
% Calculate the gradient as a function |G| of type <S2VectorFieldHarmonic_index.html |S2VectorFieldHarmonic|>
%
G = grad(sF1);

%%
% The direct evaluation of the gradient is faster and returns <vector3d_index.html |vector3d|>
nodes = vector3d.rand(100);
grad(sF1, nodes);


%% Visualization
% There are different ways to visualize a |S2FunHarmonic|
%
% The default |plot|-command be default plots the function on the upper hemisphere
plot(sF1); 

%%
% * |plot(sF1)| is the same as |contourf(sF1)|

%%
% nonfilled contour plot plots only the contour lines
contour(sF1, 'LineWidth', 2);

%%
% color plot without the contour lines
pcolor(sF1);

%%
% 3D plot of a sphere colored accordingly to the function values.
plot3d(sF2);

%%
% 3D plot where the radius of the sphere is transformed according to the function values
surf(sF2);

%%
% Plot the intersection of the surf plot with a plane with normal vector |v|
plotSection(sF2, zvector);

%%
% plotting the Fourier coefficients
plotSpektra(sF1);
set(gca,'FontSize', 20);
