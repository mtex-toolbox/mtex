%% Harmonic Representation of Spherical Functions
%
%%
% Similarly as periodic functions may be represented as weighted sums of
% sines and cosines a spherical function $f$ can be written as series of
% the form
%
% $$ f({\bf v}) = \sum_{m=0}^M \sum_{l = -m}^m \hat f(m,l) Y_{m,l}({\bf v}) $$
%
% with respect to Fouriers coefficients $\hat f(m,l)$ and the so called
% spherical harmonics $Y_{m,l}({\bf v})$.
%
% In terms of polar coordinates 
% ${\bf v} = (\sin \theta \cos \rho, \sin \theta \sin \rho, \cos \theta)$ the
% spherical harmonic of degree $m$ and order $l$ is
% defined by
%
% $$ Y_{m,l}({\bf v}) = \sqrt{\frac{2m+1}{4\pi}}P_{m,|l|}(\cos\rho)\mathrm e^{\mathrm i l\theta} $$
%
% where $P_{m,|l|}$, $m \in {\bf N_0}$, and $ l = -m, \ldots m$ denote the
% associated Legendre-Polynomials.
%
%% 
% Within the class <S2FunHarmonic.S2FunHarmonic |S2FunHarmonic|> spherical
% functions are represented by their Fourier coefficients which are stored
% in the field |fun.fhat|. As an example lets define a harmonic function
% which Fourier coefficients $\hat f(0,0) = 1$, $\hat f(1,-1) = 0$, $\hat
% f(1,0) = 3$ and $\hat f(1,1) = 0$

fun = S2FunHarmonic([1;0;3;0])

plot(fun)

%%
% This function has the cut off degree $M=1$. As a rule
% of thumb: smooth functions require only a small cut off degree whereas
% functions with jumps or sharp edges requires a high cut off degree. If
% the cut off degree is choosen to small truncation error in the form of
% high order oscillations are observable.
%
% The computation of the Fourier coefficients can be done in several ways.
% Lets first assume that the function $f$ is known explicitely, e.g.,
% $f({\bf v})=({\bf v} \cdot {\bf x})^3$. In MTEX we can express this as

fun = @(v) dot(v,vector3d.X).^9;

%%
% Now we can compute the Harmonic representation this function and turn it
% into a variable of type <S2FunHarmonic.S2FunHarmonic |S2FunHarmonic|>
% using the command <S2FunHarmonic.quadrature.html
% |S2FunHarmonic.quadrature|>

S2F = S2FunHarmonic.quadrature(fun)

plot(S2F,'upper')

%%
% We observe that by default Fourier coefficients up the harmonic cut of
% degree $M=128$ are computed. This default value can changed using the
% option |'bandwidth'|. The decay of the Fourier coefficients can be
% visualized using the command <S2FunHarmonic.plotSpektra.html
% plotSpektra> which plot for each harmonic degree $m$ the sum of the
% squared moduli of the corresponding Fourier coefficients, i.e.
% $\sum_{k=-m}^m \lvert \hat f(m,k)\rvert^2$

plotSpektra(S2F)

%%
% In the present example we observe that almost all Fourier coefficients
% are zero except for very first one. Hence, it might be reasonable to
% restrict the cut of degree to the non zero Fourier coefficients

% restrict to non zero Fourier coefficients
S2F = S2F.truncate

% power plot
plotSpektra(S2F,'linewidth',2)

%% 
% In 
% The robust estimation of these
% Fourier coefficients from discrete data is doiscussed in the secion
% <S2FunApproximationInterpolation.html Spherical Approximation>

% In particular all
% operation on those functions are implmented as operations on the Fourier
% coefficients. 
%
% The crucial parameter when representing spherical functions by their
% harmonic series expansion is the harmonic cut off degree $M$. .
%
%%
% If you think you remember these from the Windows 2000 flowerbox
% screensaver, you are wrong. But they play a fundamental role in the
% computation of atomic orbital electron configurations and may have
% appeared in a chemistry book you've seen.
%
% Now we seek for so-called Fourier-coefficients ${\bf \hat f} = (\hat
% f_{0,0},\dots,\hat f_{M,M})^T$ such that
%
% $$ g(x) = \sum_{m=0}^M\sum_{l = -m}^m \hat f_{m,l} Y_{m,l}(x) $$
%
% approximates our function. A basic strategy to achieve this is through
% least squares, where we minimize the functional $$
% \sum_{n=1}^N|f(x_n)-g(x_n)|^2 $$
%
% for the data nodes $x_n$, $n=1,\dots,N$, $f(x_n)$ the target function
% values and $g(x_n)$ our approximation evaluated in the given data nodes.
%
% This can be done by the |lsqr| function of Matlab, which efficiently
% seeks for roots of the derivative of the given functional (also known as
% normal equation). In the process we compute the matrix-vector product
% with the Fourier-matrix multible times, where the Fourier-matrix is given
% by
%
% $$ F = [Y_{m,l}(x_n)]_{n = 1,\dots,N;m = 0,\dots,M,l = -m,\dots,m}. $$
%
% This matrix-vector product can be computed efficiently with the use of
% the nonequispaced spherical Fourier transform
% <https://www-user.tu-chemnitz.de/~potts/nfft/nfsft.php NFSFT>.
%
% We end up with the Fourier-coefficients of our approximation $g$, which
% describe our approximation.
%
%%
% There are other variants to obtain these Fourier-coefficients, but we
% only wanted to give a feel for what they are for.
%
%% 
% To concluse this session we plot the first ten spherical harmonics

surf(S2FunHarmonic(eye(10)))

