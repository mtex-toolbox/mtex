%% SO(3)-Kernel Functions
%
%%
% We examine some radial symmetric kernel functions $\tilde\psi \colon \mathcal{SO}(3) \to \mathbb R$ 
% on $\mathcal{SO}(3)$. For rotations $R\in\mathcal{SO}(3)$ we write this
% $\mathcal{SO}(3)$-kernels as functions of $t=\cos\frac{\omega(R)}2$ on 
% the real numbers. Hence we write
%
% $$ \psi(t) = \tilde\psi(R) $$.
%
% Moreover, we have $\psi \in L^2([-1,1],\sqrt{1-t^2}\mathrm{d}t) and we describe
% this $\mathcal{SO}(3)$ kernel functions by there Chebyshev expansion
%
% $$ \psi(t) = \sum\limits_{n=0}^{\infty} \hat\psi_n \, \mathcal U_{2n}(t) $$
%
% where $\mathcal U_{n}$ denotes the Chebyshev polynomials of second kind and degree
% $n\in\mathbb N$.
%
% The class |@SO3Kernel| is needed in MTEX to define the specific form of
% unimodal ODFs. It has to be passed as an argument when calling the
% methods <uniformODF.html uniformODF>.
% Furthermore $\mathcal{SO}(3)-Kernels are also used for computing an ODF 
% from EBSD data.
%
%%
% Within the class |@SO3Kernel| kernel functions are represented by
% their Chebyshev coefficients, that are stored in the field |fun.A|. 
% As an example lets define an $\mathcal{SO}(3)$ kernel function with
% Chebyshev coefficients $a_1 = 1$, $a_2 = 0$, $a_3 = 3$ and $a_4 = 1$

psi = SO3Kernel([1;0;3;1])

plot(psi)

%%
% In MTEX there are a lot of SO3Kernels included. The two most importants are
%
% * de la Vallee Poussin kernel (used for ODF, MODF, Pole figures, etc),
% * Dirichlet kernel (uesd for physical properties).
% * Abel Poisson kernel
% * von Mises Fisher kernel
% * Gauss Weierstrass kernel
% * Laplace kernel
% * Sobolev kernel
% * Square Singularity kernel
% * Bump kernel
%
%%
% A specific $\mathcal{SO}(3)$ kernel function like the de la Vallee Poussin kernel
% is specified by a half-width angle in orientation space ($\mathcal{SO}(3)$) 
% or bandwidth in Fourier space, which is the maximum development in Fourier coefficients.

psi = SO3deLaValleePoussin('halfwidth',30*degree)

plot(psi)

%%
% In the following we want to look at some different types of 
% $\mathcal{SO}(3)$ kernel functions.
%

%% The de La Vallee Poussin Kernel
% The <SO3deLaValleePoussin.html de la Vallee Poussin kernel> has the unique 
% property that for a given halfwidth it can be described exactly by a 
% finite number of Fourier coefficients. This kernel is recommended for 
% Texture analysis as it is always positive in Orientation space and there 
% is no truncation error in Fourier space.
%
% Hence we can define the de la Vallee Poussin kernel $\psi_{\kappa}$ depending 
% on a parameter $\kappa \in \mathbb N \setminus \{0\}$ by its finite 
% Chebyshev expansion
%
% $$ \psi_{\kappa}(t) = \frac{(\kappa+1)\,2^{2\kappa-1}}{\binom{2\kappa-1}{\kappa}}
% \, t^{2\kappa}  = \binom{2\kappa+1}{\kappa}^{-1} \, 
% \sum\limits_{n=0}^{\kappa} (2n+1)\,\binom{2\kappa+1}{\kappa-n} \,
% \mathcal U_{2n}(t)$$.
%
% Lets construct two of them.

psi1 = SO3deLaValleePoussin('halfwidth',15*degree)
psi2 = SO3deLaValleePoussin('halfwidth',20*degree)

plot(psi1)
hold on
plot(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%%
% Here the parameter $\kappa$ is $40.34$ for function $\psi_1$ and $22.64$ 
% in function $\psi_2$.
%
% We also take a look at the Fourier coefficients

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%% The Dirichlet Kernel
% The <SO3DirichletKernel.html Dirichlet kernel> has the 
% unique property of being a convergent finite series in Fourier coefficients 
% with an integral of one. This kernel is recommended for calculating 
% physical properties as the Fourier coefficients always have a value of one
% for a given bandwidth.
% 
% On the rotation group $\mathcal{SO}(3)$ the Dirichlet kernel 
% $\psi_N \in L^2(\mathcal{SO}(3))$ is defined by its Chebyshev series
%
% $$ \psi_N(t) = \sum\limits_{n=0}^N (2n+1) \, \mathcal U_{2n}(t)$$.
%
% Lets construct two of them.

psi1 = SO3DirichletKernel(10)
psi2 = SO3DirichletKernel(5)

plot(psi1)
hold on
plot(psi2)
hold off
legend('bandwidth = 5','bandwidth = 10')

%%
% We also take a look at the Fourier coefficients

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('bandwidth = 5','bandwidth = 10')

%% The Abel Poisson Kernel
% The <SO3AbelPoisson.html Abel Poisson kernel> $\psi_{\kappa}\in L^2(\mathcal{SO}(3))$ 
% is a nonnegative function depending on a parameter $\kappa \in (0,1)$ and 
% is defined by its Chebyshev series
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{\infty} (2n+1) \, \kappa^{2n} \,
% \mathcal U_{2n}(t)$$.
%
% Lets construct two of them.

psi1 = SO3AbelPoisson('halfwidth',15*degree)
psi2 = SO3AbelPoisson('halfwidth',20*degree)

plot(psi1)
hold on
plot(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%%
% Here the parameter $\kappa$ is $0.82$ for function $\psi_1$ and $0.76$ 
% in function $\psi_2$.
%
% We also take a look at the Fourier coefficients

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%% The von Mises Fisher Kernel
% The <SO3vonMisesFisher.html von Mises Fisher kernel> $\psi_{\kappa}\in L^2(\mathcal{SO}(3))$ 
% is a nonnegative function depending on a parameter $\kappa>0$ and 
% is defined by its Chebyshev series
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{\infty} 
% \frac{\mathcal{I}_n(\kappa}-\mathcal{I}_{n+1}(\kappa)}
% {\mathcal{I}_0(\kappa)-\mathcal{I}_1(\kappa)}  \, \mathcal U_{2n}(t)$$ 
%
% or directly by
%
% $$ \psi_{\kappa}(t) = \frac1{\mathcal{I}_0(\kappa)-\mathcal{I}_1(\kappa)}
% \, \mathrm{e}^{2\kappa t}$$
% 
% while $\mathcal I_n,\,n\in\mathbb N_0$ denotes the the modified Bessel 
% functions of first kind
%
% $$ \mathcal I_n (\kappa) = \frac1{\pi} \int_0^{\pi} \mathrm e^{\kappa \,
% \cos \omega} \, \cos n\omega \, \mathrm d\omega $$.
%
% Lets construct two of this kernels.

psi1 = SO3vonMisesFisher('halfwidth',15*degree)
psi2 = SO3vonMisesFisher('halfwidth',20*degree)

plot(psi1)
hold on
plot(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%%
% Here the parameter $\kappa$ is $20.34$ for function $\psi_1$ and $11.49$ 
% in function $\psi_2$.
%
% We also take a look at the Fourier coefficients

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%% The Gauss Weierstrass Kernel
% The <SO3GaussWeierstrassKernel.html Gauss Weierstrass kernel> $\psi_{\kappa}\in L^2(\mathcal{SO}(3))$ 
% is a nonnegative function depending on a parameter $\kappa>0$ and 
% is defined by its Chebyshev series
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{\infty} (2n+1) \, 
% \mathrm e^{-n(n+1)\kappa} \, \mathcal U_{2n}(t)$$.
%
% Lets construct two of them by the parameter $\kappa$.

psi1 = SO3GaussWeierstrassKernel(0.025)
psi2 = SO3GaussWeierstrassKernel(0.045)

plot(psi1)
hold on
plot(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%%
% We also take a look at the Fourier coefficients

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('halfwidth = 15°','halfwidth = 20°')

%% TODO: add the definition of the other kernel functions
% ( Bump, Laplace, Dirichlet, Square Singularity )




