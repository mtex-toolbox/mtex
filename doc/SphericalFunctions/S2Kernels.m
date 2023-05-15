%% S2-Kernel Functions
%
%%
% We examine some radial symmetric kernel functions $\tilde \psi \colon R \to R$
% on the sphere.
% We describe this functions by there Legendre polynomial expansion
% 
% $$ \psi(t) = \sum\limits_{n=0}^{\infty} \hat\psi_n \, \mathcal P_{n}(t) $$
%
% where $\mathcal P_{n}$ denotes the Legendre polynomials with degree
% $n\in\mathbb N$.
%
% The class |@S2Kernel| is needed in MTEX to define the specific form of
% fibre ODFs. It has to be passed as an argument when calling the
% methods <fibreODF.html fibreODF>.
%


% For rotations $R \in SO(3)$ we write this
% $\mathcal{SO}(3)$-kernels as functions of $t = \cos\frac{\omega(R)}2$ on 
% the real numbers. Hence we write
%
% $$ \psi(t) = \tilde\psi(R) $$.
%
%
%
%%
% Within the class |@S2Kernel| kernel functions are represented by
% their Legendre coefficients, that are stored in the field |fun.A|. 
% As an example lets define an spherical kernel function with
% Legendre coefficients $a_0 = 1$, $a_1 = 0$, $a_2 = 3$ and $a_3 = 1$

psi = S2Kernel([1;0;3;1])
%%
% We plot this function by evaluation of its Legendre series in $\cos(\omega)$
% for $\omega\in[0,\pi].$

plot(psi)

%%
% It is also possible to differentiate this S2Kernel functions with |grad|.
% By default we get the derivative of $\psi(\cos(\theta))$ with respect to
% $\theta$. 

plot(psi.grad)
%%
% The flag |'polynomial'| yields the ploynomial derivative of $\psi(x)$ 
% with respect to $x$. 

plot(psi.grad,'polynomial')

%%
% We can define an fibre ODF from a kernel function $\psi$ and 2 spherical 
% elements at a specific orientation $R$ by using the class 
% <SO3FunCBF.html |SO3FunCBF|>, i.e.

psi = S2DeLaValleePoussinKernel
SO3F = SO3FunCBF(vector3d(1,0,0),vector3d(0,0,1),1,psi)
plot(SO3F)

%%
% The following kernel function are predefined in MTEX
%
% * <S2Kernels.html#9 de la Vallee Poussin kernel>
% * <S2Kernels.html#11 Dirichlet kernel>
% * <S2Kernels.html#13 Bump kernel>
% * Schulz defousing kernel
%
%

%% The de La Vallee Poussin Kernel
% The <S2Kernels.S2DeLaValleePoussinKernel.html spherical de la Vallee Poussin kernel>
% is defined by 
% 
% $$ K(t) = (1+\kappa)\,(\frac{1+t}{2})^{\kappa}$$ 
% 
% for $t\in[0,1]$. The de la Vallee Poussin kernel additionaly has the 
% unique property that for a given halfwidth it can be described exactly 
% by a finite number of Fourier coefficients. This kernel is recommended
% for Texture analysis as it is always positive and there is no truncation 
% error in Fourier space.
%
% Hence we can define the de la Vallee Poussin kernel $\psi_{\kappa}$ 
% depending on a parameter $\kappa \in \mathbb N \setminus \{0\}$ by its 
% finite Legendre polynomial expansion
%
% $$ \psi_{\kappa}(t) = \sum\limits_{n=0}^{L} a_n(\kappa) \mathcal P_{n}(t).$$
%
% We obtain the Legendre coefficients $a_n(\kappa)$ by $a_0=1$, 
% $a_1=\frac{\kappa}{2+\kappa}$ and the three term recurence relation
%
% $$ (\kappa+l+2) a_{l+1} = -(2l+1)\,a_l + (\kappa-l+1)\,a_{l-1}.$$
%
% Lets construct two of them.

psi1 = S2DeLaValleePoussinKernel('halfwidth',15*degree)
psi2 = S2DeLaValleePoussinKernel('halfwidth',20*degree)

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
% The <S2Kernels.S2DirichletKernel.html spherical Dirichlet or Christoffel-Darboux kernel> 
% has the unique property of being a convergent finite series in Fourier 
% coefficients with an integral of one.
% This kernel is recommended for calculating physical properties as the 
% Fourier coefficients always have a value of one for a given bandwidth.
%
% It is defined by its Legendre series
%
% $$ \psi_N(t) = \sum\limits_{n=0}^N (2n+1) \, \mathcal P_{n}(t).$$
%
% Lets construct two of them.

psi1 = S2DirichletKernel(10)
psi2 = S2DirichletKernel(5)

plot(psi1)
hold on
plot(psi2)
hold off
legend('bandwidth = 5','bandwidth = 10')

%%
% By looking at the fourier coefficients we see, that they are exactly 1.

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('bandwidth = 5','bandwidth = 10')

%% The Bump kernel
% The <S2Kernels.S2BumpKernel.html spherical bump kernel> is a radial 
% symmetric kernel function depending on the halfwidth $r\in (0,pi)$. 
% The function value is 0, if the angle is greater then the halfwidth $r$. 
% Otherwise it is 1.
%
% The main problem of the bump kernel is that we need lots of legendre
% coefficients to describe it. That possibly can result in high runtimes. 
%

psi1 = S2BumpKernel(30*degree)
psi2 = S2BumpKernel(40*degree)

plot(psi1)
hold on
plot(psi2)
hold off
legend('halfwidth = 30°','halwidth = 40°')

%%
% We also take a look at the Fourier coefficients

plotSpektra(psi1)
hold on
plotSpektra(psi2)
hold off
legend('\kappa = 0.2','\kappa = 0.3')

