%% Spherical Kernel Functions
%#ok<*NOPTS>
%
% A spherical kernel is a scalar function whose value depends only on
% angular distance from the north pole $\vec e_3$. It is therefore radial:
% directions on the same circle around $\vec e_3$ have the same value.
%
% Kernels set the shape of localized spherical peaks. Their real-space
% profile controls locality, while their Legendre coefficients control
% harmonic cost and smoothing behaviour.
%
%% Reading a kernel in real space
%
% Begin with a de la Vallee Poussin kernel whose halfwidth is $10$ degree.
% The halfwidth is the angle at which the value falls to half of its peak.

psi = S2DeLaValleePoussinKernel('halfwidth',10*degree)

surf(psi,'resolution',2*degree,'EdgeColor','none')
hold on
arrow3d(2.4*zvector,'labeled','arrowwidth',0.01)
hold off
axis off

%%
% The peak is centred on $\vec e_3$, marked by the arrow. Concentric colour
% bands show that changing azimuth while keeping angular distance fixed
% does not change the value.
%
% A meridian profile makes the angular dependence easier to read.

close all
plot(psi,'linewidth',2,'symmetric')

%%
% The mirrored curve shows the same radial profile on either side of the
% north pole. The halfwidth is a half-maximum location, not a hard cutoff:
% this kernel remains positive beyond $10$ degree.
%
%% Halfwidth and bandwidth answer different questions
%
% *Halfwidth* describes the visible angular spread of a profile.
% *Bandwidth* is the largest Legendre degree stored by the kernel. A narrow
% or abruptly cut off profile usually needs a higher bandwidth.
%
% The main kernel families emphasize different properties:
%
% || family || main characteristic || typical use ||
% || <S2DeLaValleePoussinKernel.html de la Vallee Poussin> || nonnegative and finite for integer $\kappa$ || directional density estimation and texture analysis ||
% || <S2DirichletKernel.html Dirichlet> || exact cutoff with unit Fourier coefficients || physical-property calculations ||
% || <S2BumpKernel.html bump> || constant inside a strict angular cutoff || compact spatial support ||
% || <SchulzDefocusingKernel.html Schulz defocusing> || diffraction-instrument correction profile || XRD defocusing correction ||
% || <S2RestrictedDistanceKernel.html restricted distance> || negative distance-based interaction || point repulsion in spherical sampling ||
%
% MTEX uses these kernels for several tasks. Pass one to
% <vector3d.calcDensity.html |calcDensity|> for directional density
% estimation or to <S2Fun.smooth.html |smooth|> for spherical smoothing.
% The Schulz kernel corrects XRD defocusing. The
% <grainBoundary.calcGBND.html |calcGBND|> method uses a kernel to estimate
% a habit-plane normal distribution, and <fibreODF.html |fibreODF|> uses one
% to set the profile around a fibre.
%
%% De la Vallee Poussin: a nonnegative peak
%
% Compare two
% <S2DeLaValleePoussinKernel.html de la Vallee Poussin kernels>. The
% constructor converts each requested halfwidth to its concentration
% parameter $\kappa$.

psi15 = S2DeLaValleePoussinKernel('halfwidth',15*degree)
psi20 = S2DeLaValleePoussinKernel('halfwidth',20*degree)

fprintf('kappa(15 deg) = %.2f; kappa(20 deg) = %.2f\n', ...
  psi15.kappa,psi20.kappa)

%%
% The parameters are $40.34$ and $22.64$, respectively. Compare each
% real-space profile with its Fourier coefficients.

figure
subplot(1,2,1)
plot(psi15,'linewidth',2,'symmetric')
hold on
plot(psi20,'linewidth',2,'symmetric')
hold off
legend('halfwidth = 15°','halfwidth = 20°')
subplot(1,2,2)
plotSpektra(psi15,'linewidth',2)
hold on
plotSpektra(psi20,'linewidth',2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%%
% The $15$ degree kernel is narrower and taller. Its coefficients remain
% significant to higher degrees, which is the harmonic cost of resolving
% the sharper peak. Both profiles remain nonnegative.
%
%% Dirichlet: an exact spectral cutoff
%
% The <S2DirichletKernel.html Dirichlet kernel> keeps every Fourier
% coefficient through its requested bandwidth. Compare bandwidths 10 and
% 5 in real and harmonic space.

dirichlet10 = S2DirichletKernel(10)
dirichlet5 = S2DirichletKernel(5)

figure
subplot(1,2,1)
plot(dirichlet10,'linewidth',2,'symmetric')
hold on
plot(dirichlet5,'linewidth',2,'symmetric')
hold off
legend('bandwidth = 10','bandwidth = 5')
subplot(1,2,2)
plotSpektra(dirichlet10,'linewidth',2)
hold on
plotSpektra(dirichlet5,'linewidth',2)
hold off
legend('bandwidth = 10','bandwidth = 5')

%%
% The bandwidth-10 kernel has a narrower central lobe and more side lobes.
% It crosses below zero, so it is not a nonnegative density kernel. The
% spectra verify that every retained Fourier coefficient is exactly one.
% This exact cutoff is why the family is recommended for calculating
% physical properties.
%
%% Bump: an exact spatial cutoff
%
% The <S2BumpKernel.html bump kernel> is constant inside its halfwidth and
% zero outside. Compare two cutoffs using bandwidth 128 for their stored
% Legendre expansions.

bump30 = S2BumpKernel(30*degree,'bandwidth',128)
bump50 = S2BumpKernel(50*degree,'bandwidth',128)

figure
subplot(1,2,1)
plot(bump30,'linewidth',2,'symmetric')
hold on
plot(bump50,'linewidth',2,'symmetric')
hold off
legend('halfwidth = 30°','halfwidth = 50°')
subplot(1,2,2)
plotSpektra(bump30,'linewidth',2)
hold on
plotSpektra(bump50,'linewidth',2)
hold off
legend('halfwidth = 30°','halfwidth = 50°')

%%
% The flat tops and abrupt cutoffs give exact compact support in real space.
% The oscillating spectra decay slowly, so many coefficients are needed to
% represent that discontinuity. This can produce high runtimes.
%
% Earlier documentation stated that the value inside the cap was 1. The
% current kernel instead divides by the cap's relative area. This gives the
% kernel mean value one, consistent with the other normalized families.
%
%% The maths behind radial kernels
%
% Let $\theta$ be the angle from $\vec v$ to $\vec e_3$ and set
% $t=\cos\theta=\vec v\cdot\vec e_3$. A kernel $\Psi$ on the sphere is then
% represented by a one-variable function $\psi$:
%
% $$ \Psi(\vec v)=\psi(t), \qquad t\in[-1,1]. $$
%
% MTEX expands this function in Legendre polynomials $\mathcal P_n$,
%
% $$ \psi(t)=\sum_{n=0}^{\infty}(2n+1)\,\widehat\psi_n\,
% \mathcal P_n(t). $$
%
% A general @S2FunHarmonic has $2n+1$ spherical harmonic coefficients at
% degree $n$. Radial symmetry leaves only the zonal coefficient. An
% <S2Kernel.S2Kernel.html |S2Kernel|> stores the scaled coefficients
% $(2n+1)\widehat\psi_n$ in its |A| property. The
% <S2Kernel.plotSpektra.html |plotSpektra|> method divides by $2n+1$ and
% plots $\widehat\psi_n$.
%
% This degree-by-degree representation makes radial convolution cheap. The
% <S2FunRadon.html spherical Radon transform> earlier in this chapter is
% another radial convolution, with zero coefficients at every odd degree.
%
%% Formulae for the three examples
%
% On the full interval $t\in[-1,1]$, the de la Vallee Poussin profile is
%
% $$ K(t)=(1+\kappa)\left(\frac{1+t}{2}\right)^\kappa. $$
%
% Earlier documentation restricted this formula to $t\in[0,1]$. The class
% evaluates it on the full cosine interval. For positive integer
% $\kappa\in\mathbb N\setminus\{0\}$, the profile is a polynomial and has
% an exact finite Legendre expansion. A requested halfwidth generally gives
% a noninteger $\kappa$, so its stored finite expansion is a truncation.
%
% With the normalization above, the first coefficients are
% $\widehat\psi_0=1$ and
% $\widehat\psi_1=\kappa/(\kappa+2)$. The implementation continues them with
%
% $$ (\kappa+l+2)\widehat\psi_{l+1}=-(2l+1)\widehat\psi_l
% +(\kappa-l+1)\widehat\psi_{l-1}. $$
%
% Earlier documentation instead gave
% $\widehat\psi_1=\kappa/(6+3\kappa)$ and the recurrence
%
% $$ (\kappa+l+2)(2l+3)\widehat\psi_{l+1}
% =-(2l+1)^2\widehat\psi_l
% +(\kappa-l+1)(2l-1)\widehat\psi_{l-1}. $$
%
% Those factors do not match the coefficients returned by the current
% constructor.
%
% The bandwidth $N$ Dirichlet kernel is
%
% $$ \psi_N(t)=\sum_{n=0}^{N}(2n+1)\mathcal P_n(t). $$
%
% Hence $\widehat\psi_n=1$ for $0\leq n\leq N$ and zero above $N$.
% For bump halfwidth $r\in(0,\pi)$, the normalized profile is
%
% $$ \psi_r(\cos\theta)=
% \begin{cases}
% \displaystyle\frac{2}{1-\cos r}, & 0\leq\theta<r,\\
% 0, & r\leq\theta\leq\pi.
% \end{cases} $$
%
%% References
%
% * W. Freeden and M. Schreiner,
% <https://doi.org/10.1007/978-3-540-85112-7 Spherical Functions of
% Mathematical Geosciences: A Scalar, Vectorial, and Tensorial Setup>,
% Springer, 2009, develops scalar zonal kernels and their spherical harmonic
% representations.
% * H. Schaeben,
% <https://doi.org/10.1155/TSM.33.365 The de la Vallee Poussin Standard
% Orientation Density Function>, _Textures and Microstructures_ 33 (1999),
% 365--373, relates kernel halfwidth to the finite harmonic representation
% used in texture analysis.
%
%% Next
%
% <SphericalHarmonics.html Spherical Harmonics> develops the basis functions
% whose zonal coefficients reduce to one value per degree for a kernel.
