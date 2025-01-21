%% Approximating Orientation Dependent Functions from Discrete Data
%
%%
% On this page we consider the problem of determining a smooth orientation
% dependent function $f(\mathtt{ori})$ given a list of orientations
% $\mathtt{ori}_n$ and a list of corresponding values $v_n$. These values
% may be the volume of crystals with this specific orientation, as in the
% case of an ODF, or they describe any other orientation dependent physical 
% property at this orientations.
%
% Such data may be stored in ASCII files which have lines of Euler
% angles, representing the orientations, and values. Such data files may be
% read using the command <orientation.load.html |load|>, where we have
% to specify the position of the columns of the Euler angles as well as of
% the additional properties.

fname = fullfile(mtexDataPath, 'orientation', 'dubna.csv');
[ori, S] = orientation.load(fname,'columnNames',{'phi1','Phi','phi2','values'});

%%
% As a result the command <orientation.load.html |load|> returns a list of 
% orientations |ori| and a struct |S|. The struct contains one field for 
% each additional column in our data file. In out toy example it is the 
% field |S.values|. Lets generate a discrete plot of the given orientations
% |ori| together with the values |S.values|.

plotSection(ori, S.values,'all');

%%
% Now, the task is to find a function which coincides with the given 
% function values in the nodes reasonably well.

%% Interpolation
%
%%
% Interpolation means, that we search a continuous function, that passes 
% exactly through some given data points. The function is then said to 
% interpolate the data. 
%
%%
% In MTEX interpolation is done by the 
% <SO3FunRBF.approximation |SO3FunRBF.approximation|> command
% of class <SO3FunRBF.SO3FunRBF |SO3FunRBF|> with the flag |'exact'|.

psi = SO3DeLaValleePoussinKernel('halfwidth',7.5*degree)
SO3F = SO3FunRBF.approximation(ori, S.values,'exact','kernel',psi);
plot(SO3F)

%% 
% The interpolation is done by |lsqr| with some tolerance |'tol'| and maximal 
% iteration number |'iter_max'| as termination conditions. Hence the error 
% is not in machine precision.

norm(SO3F.eval(ori) - S.values) / norm(S.values)

%%
% Also, interpolation might not guarantee non-negativity of the function.

min(SO3F)

%% Approximation of noisy data
%
% The exact interpolation from before is computational hard if we have
% a high number of nodes and function values given. But if we do not 
% restrict ourselves to much to the given function values, we
% have more freedom, which can be seen in the case of approximation.
%
% Here we can choose sparser interpolation matrices to reduce the 
% computational costs.
% Often in physical experiments the data are not exact or noisy. Hence exact 
% interpolation makes no sense, since it would result into overfitting.
% In exchange we want the approximated function to be reasonably smooth.
%
% Assume that our function values are noisy.

val = S.values + randn(size(S.values)) * 0.05 * std(S.values);

plotSection(ori,val,'all')

%%
% Now we differentiate between two approximation methods.
%
%%
% * Approximation by SO3FunRBF *
%
% The first is to approximate the data by a orientation dependent function
% of class |@SO3FunRBF|. Similarly as before we use the command 
% <SO3FunRBF.approximation |SO3FunRBF.approximation|> without the 
% option |'exact'|.

SO3F1 = SO3FunRBF.approximation(ori, val,'kernel',psi);
plot(SO3F1)

%%
% Where the error is

norm(eval(SO3F1, ori) - S.values) / norm(S.values)

%%
% Alternatively, the noisy data can be also approximated using a kernel
% density. Using the |odf| flag, we additionally make sure that the function
% does not have non-negative function values and is normalized to 1.
% We may study the effect of adjusting the kernel halfwidth to the
% error

hw = [20,15,12.5,10,7.5,5,2.5];
err = zeros(size(hw));
for k = 1:numel(hw)
    SO3Fhw = SO3FunRBF.approximation(ori,val,'halfwidth',hw(k)*degree,'odf');
    err(k) = norm(eval(SO3Fhw, ori) - S.values) / norm(S.values);
end

%%
% We may find the best fit with a halfwidth of 5°. If the system is
% underdetermined using a too small halfwidth, we may not be able to fit
% kernel weights without additional assumptions about the smoothness of the
% data.

[hw;err]

plot(hw,err,'o--')
set(gca,'xdir','reverse')
xlabel('halfwidth [deg]')
ylabel('relative error')



%%
% * Approximation by SO3FunHarmonic *
%
% The second way is to approximate the data by a |@SO3FunHarmonic|, i.e. 
% a series of <WignerFunctions.html Wigner-D functions> (Harmonic series). 
% If we choose the bandwidth to high and take more Wigner-D functions as 
% there are data points given, then we are in the overdetermined case and 
% obtain oversampling. But the choice of a lower bandwidth generally do not
% shrinks the error in the nodes zero. But it yields a smoother approximation. 
%
% In MTEX this can be achieved by the
% <SO3FunHarmonic.approximation |SO3FunHarmonic.approximation|> command of the class
% <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|>.

SO3F2 = SO3FunHarmonic.approximation(ori, val,'bandwidth',32)
plot(SO3F2)

%%
% One has to keep in mind that we can not expect the error in the data 
% nodes to be zero, as this would mean overfitting to the noisy input data.

norm(eval(SO3F2, ori) - S.values) / norm(S.values)

%%
% But this may not be of great importance like in the case of function
% approximation from noisy data, where we don't know the exact
% values anyways.
%
%%
% The strategy underlying the <SO3FunHarmonic.approximation |approximation|>-command
% to obtain such an approximation works via Wigner-D functions
% (<SO3FunHarmonicRepresentation.html SO3FunHarmonicSeries Basics of rotational harmonics>). 
% For that, we seek for so-called Fourier coefficients 
% ${\bf \hat f} = (\hat f^{0,0}_0,\dots,\hat f^{N,N}_N)^T$ such that
%
% $$ f(x) = \sum_{n=0}^N\sum_{k,l = -n}^n \hat f_n^{k,l} D_n^{k,l}(x) $$
%
% approximates our data reasonable well. A basic strategy to achieve this 
% is through least squares, where we minimize the functional 
%
% $$ \sum_{m=1}^M|f(x_m)-v_m|^2 $$
%
% for the given data points $(x_m,v_m)$, $m=1,\dots,M$. Here $x_m$ denotes
% the given orientations and $v_m$ the corresponding function values.
%
% This least squares problem can be solved by the |lsqr| method from MATLAB,
% which efficiently seeks for roots of the derivative of the given 
% functional (also known as normal equation). In the process we compute the 
% matrix-vector product with the Fourier-matrix multiple times, where the 
% Fourier-matrix is given by
%
% $$ F = [D_n^{k,l}(x_m)]_{m = 1,\dots,M;~n = 0,\dots,N,\,k,l = -n,\dots,n}. $$
%
% This matrix-vector product can be computed efficiently with the use of
% the nonequispaced SO(3) Fourier transform
% <https://www-user.tu-chemnitz.de/~potts/nfft/nfsoft.php NSOFT>
% or faster by the combination of a so-called Wigner-transform together with a 
% <https://www-user.tu-chemnitz.de/~potts/nfft/index.php NFFT>.
%
% However, we end up with the Fourier coefficients of our approximation $f$.
%
%%
% Lets assume we have a low number of data points given, but the desired 
% function is relatively sharp. Then we will try to compute a 
% |@SO3FunHarmonic| with high bandwidth and we are in the underdetermined 
% case, since we try to compute many Fourier coefficients from a lower 
% number of data points, which results into overfitting. We can overcome
% this by additionally demanding that the approximation $f$ should be smooth.
%
% Therefore we do so-called regularization, which means that we penalize 
% oscillations by adding the norm of $f$ to the energy functional, which is 
% minimized by the |lsqr| solver. Hence we now minimize the functional 
%
% $$ \sum_{m=1}^M|f(x_m)-v_m|^2 + \lambda \|f\|^2_{H^s}$$
%
% where $\lambda$ is the regularization parameter. The Sobolev norm 
% $\|.\|_{H^s}$ of an |@SO3FunHarmonic| $f$ with Fourier coefficients 
% $\hat{f}$ reads as
%
% $$\|f\|^2_{H^s} = \sum_{n=0}^N (2n+1)^{2s} \, \sum_{k,l=-n}^n|\hat{f}_n^{k,l}|^2.$$
%
% The Sobolev index $s$ describes how smooth our approximation $f$ should 
% be, because the larger $s$ is, the faster the Fourier coefficients 
% $\hat{f}_n^{k,l}$ converge towards 0 and the smoother is the
% approximation $f$.
%
%%
% We can use regularization by adding the option |'regularization'| to the
% command <SO3FunHarmonic.approximation |SO3FunHarmonic.approximation|> of the class
% <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|>.

lambda = 5e-7;
s = 2;
SO3F3 = SO3FunHarmonic.approximation(ori,val,'bandwidth',32,'regularization',lambda,'SobolevIndex',s)
plot(SO3F3)

%%
% Plotting this function, we can immediately see, that we have a much
% smoother function, i.e. the norm of |SO3F3| is smaller than the norm of
% |SO3F2|.

norm(SO3F2)
norm(SO3F3)

%% 
% This smoothing results in a larger error in the data points,
% which may not be much important since we had noisy function values given,
% where we don't know the exact values anyways. 

norm(eval(SO3F3, ori) - S.values) / norm(S.values)

%%
% Note that this Error is not the value of the above energy functional 
% which is minimized by lsqr.


%% Quadrature
%
% Assume we have given some experiment which yields an ODF or some general 
% |@SO3Fun|, i.e. we have some evaluation routine. 

mtexdata dubna
odf = calcODF(pf,'resolution',5*degree,'zero_Range')

%%
% Now we want to compute (expand) the corresponding |@SO3FunHarmonic|.
% If our odf is an |@SO3Fun| or |@function_handle| we can use the command
% <SO3FunHarmonic.approximation.html SO3FunHarmonic.approximation>

F = SO3FunHarmonic.approximation(odf)

%%
% Alternatively we can directly use the constructor, i.e. we use the command 
% <SO3FunHarmonic.html SO3FunHarmonic>.

F = SO3FunHarmonic(odf)

%%
% If there is an physical experiment which yields the function values for 
% given orientations, we can also do the quadrature manually.
%
% Therefore we have to evaluate on an specific grid and afterwards we compute the
% Fourier coefficients by the command <SO3FunHarmonic.quadrature.html SO3FunHarmonic.quadrature>
% from the data points. This is a special case of approximation for a very
% specific grid.

% Specify the bandwidth and symmetries of the desired harmonic odf
N = 50;
cs = odf.CS;
ss = specimenSymmetry;

% Compute the quadrature grid and weights
SO3G = quadratureSO3Grid(N,'ClenshawCurtis',cs,ss);
% Because of symmetries there are symmetric equivalent nodes on the quadrature grid.
% Hence we evaluate the routine on a smaller unique grid and reconstruct afterwards.
% For SO3Fun's this is done internally by evaluation.
tic
v = odf.eval(SO3G);
toc

% At the end we do quadrature
F1 = SO3FunHarmonic.quadrature(SO3G,v)

%%
% Internally MTEX saves time by evaluating on a unique part of the 
% |@quadratureSO3Grid|. Afterwards we do quadrature on the obtained data.
% We can work in the following way when we have to measure every data point 
% by an experiment.

% Compute the unique nodes of the quadratureSO3Grid
g = SO3G.uniqueGrid;
% Measure the values at any of this nodes by a experiment (Here it is simply a evaluation)
v = odf.eval(g);
% Reconstruct the full grid (of symmetric values)
v = v(SO3G.iuniqueGrid);
% Do quadrature
F = SO3FunHarmonic.quadrature(SO3G.fullGrid,v,'weights',SO3G.weights,'bandwidth',N,'ClenshawCurtis');

%%
% Lets take a look on the result

calcError(F,F1)

plot(F1)


%%
% Furthermore, if the evaluation step is very expansive it might be a good idea
% to use the smaller Gauss-Legendre quadrature grid. 
% The Gauss-Legendre quadrature lattice has half as many points as the default
% Clenshaw-Curtis quadrature lattice. But the quadrature method is more time consuming.
%

% Compute the Gauss-Legendre quadrature grid and weights
SO3G = quadratureSO3Grid(N,'GaussLegendre',cs,ss);
% Evaluate your routine on that quadrature grid
tic
v = odf.eval(SO3G);
toc
% and do quadrature
F2 = SO3FunHarmonic.quadrature(SO3G,v)

calcError(F,F2)

%%
% It is also possible to convert the harmonic function back to a kernel
% density representation

F3 = SO3FunRBF.approximation(F,'halfwidth',5*degree,'approxresolution',5*degree);

calcError(odf,F)
calcError(odf,F3)