%% Halfwidth of SO3Kernels needs a consistent definition  [DONE]
%
% In the Following we compare the halfwidth of a kernel of a specific class
% with the halfwidth of the correponding SO3Kernel
%

  % kappa in (0,1)
  psi = SO3AbelPoissonKernel(0.1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3AbelPoissonKernel(0.4)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3AbelPoissonKernel(0.99)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %% r in (0,pi)
  psi = SO3BumpKernel(0.01)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3BumpKernel(1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3BumpKernel(pi-0.1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %% kappa in N
  psi = SO3DeLaValleePoussinKernel(1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3DeLaValleePoussinKernel(100)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3DeLaValleePoussinKernel(2000)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %% bandwidth
  psi = SO3DirichletKernel(1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3DirichletKernel(50)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3DirichletKernel(400)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %% kappa > 0
  psi = SO3GaussWeierstrassKernel(0.1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3GaussWeierstrassKernel(0.5)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3GaussWeierstrassKernel(1)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %%
  psi = SO3LaplaceKernel
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %%
  psi = SO3SobolevKernel(0.1,'bandwidth',20)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3SobolevKernel(1.1,'bandwidth',20)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3SobolevKernel(5,'bandwidth',20)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %% kappa in (0,1)
  psi = SO3SquareSingularityKernel(0.091)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3SquareSingularityKernel(0.5)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3SquareSingularityKernel(0.99)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  %% kappa > 0
  psi = SO3vonMisesFisherKernel(0.347)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3vonMisesFisherKernel(10)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree
  psi = SO3vonMisesFisherKernel(500)
  [psi.halfwidth, halfwidth(SO3Kernel(psi.A))]/degree




%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The Halfwidth should describe the support
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% The halwidth should be the same for the gradient of a SO3Kernel
%

clear

p = SO3DeLaValleePoussinKernel(10)
%p = SO3DirichletKernel(1000)
%p = SO3AbelPoissonKernel(0.25) 
%p = SO3AbelPoissonKernel(0.9999) % hw2
%p = SO3GaussWeierstrassKernel(1)
%p = SO3LaplaceKernel  % beide  
%p = SO3SobolevKernel(0.001)  % hw2
%p = SO3SquareSingularityKernel(0.9989) % hw2
%p = SO3SquareSingularityKernel(0.091) % hw1
%p = SO3vonMisesFisherKernel(450)       % beide
%p = SO3BumpKernel(20*degree)

p.grad

figure(1)
subplot(121)
plot(p)
subplot(122)
plot(p.grad)



