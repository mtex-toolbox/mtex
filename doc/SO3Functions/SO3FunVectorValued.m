%% Vector-Valued Orientation Functions
%
% A scalar orientation function assigns one number to each orientation.
% A vector-valued orientation function assigns an array of numbers instead:
%
% $$ f\colon \mathrm{SO}(3) \to \mathbb{R}^n. $$
%
% This is useful when several orientation-dependent quantities share the
% same nodes, symmetries and approximation method. MTEX stores the
% components together so that they can be interpolated and manipulated as
% one array of functions.

%% How evaluations are arranged
%
% The nodes are always interpreted as a column vector. The node index is
% the first dimension of an evaluated array. The dimensions of the
% vector-valued @SO3Fun begin with the second dimension.
%
% Consider four nodes $R_1,\ldots,R_4$ and six scalar functions arranged as
% a $3\mathbin{\times}2$ array. Evaluation returns a
% $4\mathbin{\times}3\mathbin{\times}2$ numeric array $F$:
%
% $$ F(:,:,1)=\begin{pmatrix}
% f_1(R_1)&f_2(R_1)&f_3(R_1)\\
% f_1(R_2)&f_2(R_2)&f_3(R_2)\\
% f_1(R_3)&f_2(R_3)&f_3(R_3)\\
% f_1(R_4)&f_2(R_4)&f_3(R_4)
% \end{pmatrix}, \qquad
% F(:,:,2)=\begin{pmatrix}
% f_4(R_1)&f_5(R_1)&f_6(R_1)\\
% f_4(R_2)&f_5(R_2)&f_6(R_2)\\
% f_4(R_3)&f_5(R_3)&f_6(R_3)\\
% f_4(R_4)&f_5(R_4)&f_6(R_4)
% \end{pmatrix}. $$
%
% The same convention applies to harmonic coefficients. The first
% dimension of the internal coefficient array stores all Fourier
% coefficients of one scalar function. If $\widehat{\mathbf f}_j$ is the
% coefficient column for $f_j$, the two slices are
%
% $$ \widehat F(:,:,1)=
% \begin{pmatrix}\widehat{\mathbf f}_1&\widehat{\mathbf f}_2&
% \widehat{\mathbf f}_3\end{pmatrix}, \qquad
% \widehat F(:,:,2)=
% \begin{pmatrix}\widehat{\mathbf f}_4&\widehat{\mathbf f}_5&
% \widehat{\mathbf f}_6\end{pmatrix}. $$
%
% This leading coefficient dimension is an implementation detail. Indexing
% and |size| report only the $3\mathbin{\times}2$ function array seen by the
% user.

%% Interpolate several components from samples
%
% First construct a column of approximately $10^5$ orientations. The
% crystal and specimen symmetries determine the fundamental region sampled
% by the grid.

nodes = equispacedSO3Grid(crystalSymmetry,specimenSymmetry,'points',1e5);
nodes = nodes(:);

%%
% The first value column samples the Dubna model function. The second is a
% different scalar quantity evaluated at the same nodes. Assigning the
% Dubna crystal symmetry to the nodes makes their symmetry agree with the
% sampled model.

plottingConvention.default('y↑→x');
y = [SO3Fun.dubna(nodes), (nodes.a .* nodes.b).^(1/4)];
nodes.CS = SO3Fun.dubna.CS;

%%
% <SO3FunHarmonic.interpolate.html |SO3FunHarmonic.interpolate|> fits both
% columns in one call. The result is a $2\mathbin{\times}1$ array of
% harmonic functions. Here the bandwidth is 48 and LSQR is limited to 10
% iterations.

SO3F1 = SO3FunHarmonic.interpolate(nodes,y,'maxit',10,'bandwidth',48)

%%
% The deliberately short iteration limit can produce an LSQR warning that
% the optimum has not yet been reached. Increase |maxit| when convergence,
% rather than a compact teaching run, is required.
%
%%
% Evaluating four orientations demonstrates the layout directly: four rows
% are nodes and two columns are components.

size(eval(SO3F1,nodes(1:4)))

%%
% The generic <rotation.interp.html |interp|> route can instead build an
% <SO3FunRBF.SO3FunRBF.html |SO3FunRBF|> from one value column.

SO3F2 = interp(nodes,y(:,1))

%%
% This |interp| syntax is available only for a univariate, or scalar-valued,
% function. Use the explicit harmonic interpolation above when several
% sampled components should remain together.

%% Construct a function from a function handle
%
% Quadrature provides a second route when values can be evaluated at any
% orientation. The handle below returns four columns for every input
% orientation.

f = @(rot) [exp(rot.a+rot.b+rot.c) + ...
  50*(rot.b-cos(pi/3)).^3.*(rot.b-cos(pi/3)>0), ...
  rot.a, rot.b, rot.c];

%%
% <SO3FunHarmonic.quadrature.html |SO3FunHarmonic.quadrature|> evaluates the
% handle on a quadrature grid. It creates a $4\mathbin{\times}1$ harmonic
% function with bandwidth 50 and the same crystal symmetry as |SO3F1|.

SO3F3 = SO3FunHarmonic.quadrature(f,'bandwidth',50,SO3F1.CS)

%% Construct a function from Fourier coefficients
%
% Known Fourier coefficients can be passed directly to the
% <SO3FunHarmonic.SO3FunHarmonic.html |SO3FunHarmonic|> constructor. Each
% column of the coefficient matrix becomes one component.

SO3F4 = SO3FunHarmonic(eye(10))

%%
% This stores the first ten <WignerFunctions.html Wigner-D functions> as a
% $10\mathbin{\times}1$ function array. The coefficient dimension is hidden
% from the reported array size.

%% Index and reshape components
%
% Function arrays follow ordinary MATLAB array conventions. They can be
% concatenated, indexed and reshaped. Concatenating the two- and
% four-component arrays below produces six components, and indexing selects
% components two through four.

SO3F5 = [SO3F1; SO3F3];
SO3F5(2:4)

%%
% Transpose and conjugation act on the function array and its Fourier
% coefficients. The nonconjugating transpose |.'| changes only the array
% shape, whereas |'| also conjugates complex coefficients.

conj(SO3F1);
SO3F1.';
SO3F1';

%%
% Standard array queries report the component array dimensions.

length(SO3F1)
size(SO3F3)
SO3F4 = reshape(SO3F4,2,[])

%% Integrals and component-wise reductions
%
% With no dimension argument, |sum| integrates every component over
% $\mathrm{SO}(3)$ and |mean| returns its orientation-space mean. The
% result is a numeric array with the same component shape.

sum(SO3F1)
mean(SO3F4)

%%
% Passing a dimension changes the meaning to an ordinary pointwise
% reduction over the function array. The results below remain
% @SO3FunHarmonic objects.

sum(SO3F1,1)
mean(SO3F4,2)

%% Minima and maxima
%
% With a single argument, |min| and |max| find a global extremum of every
% component separately. They return numeric arrays and require real-valued
% functions. Marking |SO3F4| as real enforces the coefficient symmetry
% required by this search.

SO3F4.isReal = 1;
min(SO3F4)

%%
% Passing a dimension as |min(SO3F,[],dim)| instead computes a pointwise
% minimum along that component dimension. The result is again a
% vector-valued @SO3FunHarmonic. Since |SO3F4| is $2\mathbin{\times}5$, the
% following reduction leaves a $1\mathbin{\times}5$ function.

min(SO3F4,[],1)

%% Pointwise products
%
% The element-wise product |.*| is evaluated pointwise in orientation
% space. It is not the usual matrix product between the two function
% arrays. Both operands must have compatible symmetries, so the symmetry of
% |SO3F1| is set explicitly before multiplication.

SO3F1.CS = specimenSymmetry;
SO3F1 .* SO3F4

%% Inspect all components
%
% <SO3Fun.plotSpektra.html |plotSpektra|> draws the harmonic power spectrum
% of every component. The four curves show that components of one function
% array may have different distributions over harmonic degree.

plotSpektra(SO3F3,'linewidth',2)

%%
% An orientation-space section plot displays only the first component of a
% vector-valued function. Since |SO3F3| is not marked as real, this command
% also warns that it displays the real part. Select and prepare a component
% explicitly when another component or its imaginary part is required.

plot(SO3F3)

%%
% The three-dimensional plot has the same first-component restriction. The
% shape therefore describes the real part of the first scalar function,
% not the magnitude of the four-component array.

plot3d(SO3F3)

%%
% A fibre is a one-dimensional family of orientations. In contrast to the
% section and three-dimensional plots, |plotFibre| draws every component
% along the selected beta fibre. Here it draws the real parts, so the four
% curves can be compared at the same orientations.

plotFibre(SO3F3,fibre.beta,'linewidth',2)

close all

%% References
%
% * P. J. Kostelec and D. N. Rockmore,
% <https://doi.org/10.1007/s00041-008-9013-5 FFTs on the rotation group>,
% _Journal of Fourier Analysis and Applications_ 14 (2008), 145--179,
% develops the Fourier representation on $\mathrm{SO}(3)$ used for each
% component of an @SO3FunHarmonic.

%% Next
%
% Continue with <SO3FunVectorField.html Rotational Vector Fields> to attach
% three components to specimen or crystal coordinates and account for how
% those vectors transform with orientation.

%#ok<*NOPTS,*VUNUS>
