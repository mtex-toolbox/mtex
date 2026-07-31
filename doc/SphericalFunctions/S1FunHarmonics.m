%% Functions on the Circle
%
%% 
% Functions on the circle are $2\pi$-periodic functions. Geometrically, one
% can also denote them as functions on the 1-dimensional torus, or the
% 1-dimensional sphere.
%
% In MTEX, such functions arise whenever a scalar quantity depends on an
% in-plane angle. Typical examples are
%
% * angular density distributions of grain long axes or other in-plane
%   shape directions,
% * distributions of grain-boundary segment directions, optionally
%   weighted by their segment lengths,
% * caliper and projection lengths as functions of the projection
%   direction, and
% * azimuth-angle distributions of three-dimensional directions.
%
%
%% Representations of Functions on the Circle
%
% In MTEX, functions on the circle can be represented in different ways.
% If a function is given by an explicit formula, it can be represented by
% an |S1FunHandle|. In this representation, the function values are
% computed directly from the given formula.
%
% Alternatively, a function can be represented by a finite Fourier series
% using |S1FunHarmonic|. This representation is discussed in detail in the
% next section.
%
% As an example, consider the function
%
% $$f(\rho)=1+\frac{1}{2}\cos(2\rho).$$
%
% We define it by an anonymous MATLAB function and pass it to
% |S1FunHandle|.

S1F = S1FunHandle(@(rho) 1 + 0.5*cos(2*rho))

%%
% The resulting function can be evaluated and plotted like any other
% function on the circle.

clf
subplot(1,2,1)
plot(S1F,'linewidth',2)
mtexTitle('Polar Plot')
subplot(1,2,2)
plot(S1F,'linewidth',2,'notPolar')
mtexTitle('Cartesian Plot')

%% Harmonic Representation of Functions on the Circle
%
% Functions on the circle are $2\pi$-periodic functions. Hence they may be 
% represented as weighted sums of sines and cosines (Fourier series).
% In MTEX, we use the numerically more convenient representation in terms
% of the complex exponentials $\mathrm e^{\mathrm i k\rho}$.
% Hence, a function $f$ on the circle can be written as series of the form
%
% $$ f(\rho) = \sum_{k=-N}^N \hat f_k \, \mathrm e^{\mathrm ik\rho} $$
%
% where $N$ is the bandwidth and $\hat f_k$ are the Fourier coefficients.
% Here $\rho\in[0,2\pi)$ is the angle.
% MTEX uses the coefficient convention
%
% $$\hat f_k = \frac{1}{2\pi} \int_0^{2\pi} f(\rho)\,\mathrm e^{-\mathrm i k\rho}\,\mathrm d\rho.$$
%
% Hence, the constant Fourier coefficient $\hat f_0$ describes the mean 
% value of $f$.
%
%% 
% Within the class |@S1FunHarmonic|, functions on the circle are
% represented by their Fourier coefficients, which are stored in the
% field |fun.fhat|.
% As an example, the following Fourier coefficients describe the 
% real-valued function $f(\rho)=1+\cos\rho+2\sin(2\rho)$.

fhat = [-1i; 0.5; 1; 0.5; 1i];
S1FH = S1FunHarmonic(fhat)

clf
plot(S1FH,'linewidth',2)

%% 
% *Fourier Expansion of an S1FunHandle*
%
% An |S1FunHandle| can be converted into an |S1FunHarmonic| by computing
% the corresponding Fourier coefficients. In MTEX, this conversion is
% performed directly using the command |S1FunHarmonic|. The desired
% bandwidth can be specified to balance computational cost and
% approximation accuracy: a higher bandwidth generally yields a more
% accurate approximation but requires more computation.
% Note that, in practice, computations with a bandwidth of 1024 are still
% very fast and usually provide a good approximation.

S1F = S1FunHandle(@(rho) exp(cos(rho)));
S1FH = S1FunHarmonic(S1F,'bandwidth',20)

clf
plot(S1F,'linewidth',2)
hold on
plot(S1FH,'--','linewidth',2)
hold off
legend('S1FunHandle','S1FunHarmonic')

%% 
% *Interpolation of Sampled Data*
%
% Frequently, a function on the circle is known only through its values at
% a finite set of angles. From these discrete data, MTEX can construct an
% |S1FunHarmonic| using the command |S1FunHarmonic.interpolate|. The
% resulting trigonometric polynomial provides a periodic interpolation of
% the sampled values and can subsequently be evaluated at arbitrary
% angles, plotted, differentiated, or used in further computations.
%
% The bandwidth determines the number of Fourier modes used for the
% interpolation. It should be chosen sufficiently large to resolve the
% angular variation of the data, while unnecessarily large bandwidths may
% introduce oscillations or amplify noise.

rho = linspace(0,2*pi,11).';
values = 1 + cos(rho) + 2*sin(2*rho);

S1FI = S1FunHarmonic.interpolate(rho,values)

clf
plot(rho,values,'x')
hold on
plot(S1FI,'linewidth',2,'noPolar')
hold off

%% 
% *Smoothing by |S1Kernel's|*
%
% Harmonic functions obtained from measured or interpolated data may
% contain small-scale oscillations or noise. Such variations can be reduced
% by convolving the function with an |S1DeLaValleePoussinKernel|.
%
% The halfwidth of the kernel determines the angular scale of the
% smoothing. A small halfwidth preserves more local detail, whereas a
% larger halfwidth produces a smoother function. 
%
% In MTEX, smoothing is performed using the command |smooth|.

f = S1FunHandle(@(rho) 1 + cos(rho) + 0.4*cos(2*rho)+ 0.15*sin(20*rho) + 0.1*cos(35*rho));
f = S1FunHarmonic(f,'bandwidth',64);

fSmooth = f.smooth('halfwidth',8*degree);

clf
plot(f,'linewidth',2,'displayName','original')
hold on
plot(fSmooth,'linewidth',2,'displayName','smoothed')
hold off
legend show


%% Basic Operations
%
% Standard MATLAB operations can be applied directly to an
% |S1FunHarmonic|. The command |mean| computes the mean value
%
% $$\operatorname{mean}(f) = \frac{1}{2\pi}\int_0^{2\pi} f(\rho)\,\mathrm d\rho,$$
%
% whereas |sum| returns the integral over the circle,
%
% $$\operatorname{sum}(f) = \int_0^{2\pi} f(\rho)\,\mathrm d\rho = 2\pi\,\operatorname{mean}(f).$$

meanValue = mean(S1FH)
integralValue = sum(S1FH)

%%
% The maximum and minimum values and their angular positions can be
% computed directly.

[maxValue,maxPosition] = max(S1FH)
[minValue,minPosition] = min(S1FH)

%% Density Estimation from Angular Data
%
% More practically, periodic functions appear after density estimation from
% circular data, e.g. of the azimuth angle of three dimensional vectors

% some random directions
v = vector3d.rand(1000);

% perform density estimation of the azimuth angle
fun = calcDensity(v.rho,'periodic')

clf
plot(fun,'linewidth',2)

