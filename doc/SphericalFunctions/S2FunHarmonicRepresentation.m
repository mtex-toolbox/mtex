%% S2FunHarmonic
%
% The class <S2FunHarmonic.S2FunHarmonic |S2FunHarmonic|> is the heart of S2Fun, therefore, much effort is put into its functionality.
% So lets cover the mathematical basics.
%
%%
% The general problem is to approximate functions of the form
%
% $$f\colon \bf S^2\to \bf R.$$
%

%%
% For that we use linear combinations of spherical harmonics, which constitude a basis of all square-integrable functions on the sphere $L_2(\bf S^2)$.
% The spherical harmonic of degree $m$ and order $l$ is defined by
%
% $$ Y_{m,l}(\theta, \rho) = \sqrt{\frac{2m+1}{4\pi}}P_{m,|l|}(\cos\rho)\mathrm e^{\mathrm i l\theta} $$
%
% for $P_{m,|l|}$ being the associated Legendre-Polynomial, $m\in\bf N_0$, and $|l|\le m$.
%
% The first ten spherical harmonics look as follows
%

surf(S2FunHarmonic(eye(10)))

%%
% If you think you remember these from the Windows 2000 flowerbox screensaver, you are wrong.
% But they play a fundamental role in the computation of atomic orbital electron configurations and may have appeared in a chemistry book you've seen.
%
% Now we seek for so-called Fourier-coefficients $\bf{\hat f} = (\hat f_{0,0},\dots,\hat f_{M,M})^T$ such that
%
% $$ g(x) = \sum_{m=0}^M\sum_{l = -m}^m \hat f_{m,l} Y_{m,l}(x) $$
%
% approximates our function.
% A basic strategy to achieve this is through least squares, where we minimize the functional
% $$ \sum_{n=1}^N|f(x_n)-g(x_n)|^2 $$
%
% for the data nodes $x_n$, $n=1,\dots,N$, $f(x_n)$ the target function values and $g(x_n)$ our approximation evaluated in the given data nodes.
%
% This can be done by the |lsqr| function of Matlab, which efficiently seeks for roots of the derivative of the given functional (also known as normal equation).
% In the process we compute the matrix-vector product with the Fourier-matrix multible times, where the Fourier-matrix is given by
%
% $$ F = [Y_{m,l}(x_n)]_{n = 1,\dots,N;m = 0,\dots,M,l = -m,\dots,m}. $$
%
% This matrix-vector product can be computed efficiently with the use of the nonequispaced spherical Fourier transform <https://www-user.tu-chemnitz.de/~potts/nfft/nfsft.php NFSFT>.
%
% We end up with the Fourier-coefficients of our approximation $g$, which describe our approximation.
%
%%
% There are other variants to obtain these Fourier-coefficients, but we only wanted to give a feel for what they are for.
