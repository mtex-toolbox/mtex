%% Density Estimation
%
%%
% Density estimation is a concept to estimate a probability density
% function $f_N$ from given random samples $x_n$, $n=1,\ldots,N$. In the
% simplest case the random samples $x_n$ are real numbers and come from an
% unknown distribution function $f$. The goal is than that $f_N$
% approximates $f$ as best as possible.
%
% Lets illustrate this setting at a the example of a mixed Gaussian
% distribution

% the true density function
f = @(x) Gaussian(0.2,0.05,x) + Gaussian(0.5,0.2,x);

% plot the true density function
x = linspace(0,1,1000);
plot(x,f(x),'linewidth',2)

% a random sample
N = 20;
xN = discreteSample(f,N,'range',[0,1]);

% plot the random sample
hold on
plot(xN,zeros(size(xN)),'o','LineWidth',2,'MarkerEdgeColor','r')
hold off

%% The Histogramm
% The easiest way to estimate a density function from the samples $x_n$ is
% a histogram

histogram(xN,10)
hold on
plot(x,f(x),'linewidth',2)
plot(xN,zeros(size(xN)),'o','LineWidth',2,'MarkerEdgeColor','r')
hold off

%%
% However, since the histogram allways leads to a picewice constant
% function the fit to the true density function $f$ is usually not so good.
% A better alternative is kernel density estimation.
%
%% Kernel Density Estimation 
%
% The idea of kernel density estimation is to fix some kernel function
% $\psi$, e.g. a Gaussian with mean $0$ and stadard deviation $0.05$,

psi = Gaussian(0,0.05);

%%
% shift its center to the position of each sample points $x_n$

% plot the random sample
plot(xN,zeros(size(xN)),'o','LineWidth',2,'MarkerEdgeColor','r')
hold on

% for each random sample plot a centered Gaussian
for n = 1:N, plot(x,psi(x-xN(n)),'k'); end
hold off
  
%%
% and take the mean 
%
% $$ f(x) = \frac{1}{N} \sum_{n=1}^N \psi(x-x_n) $$
%
% of all the these shifted kernel functions

% take the mean over all shifted kernel functions
fN = @(x) mean(psi(x-xN),1);

hold on
% plot the resulting function
plot(x,fN(x),'linewidth',2)

% plot the "true" density function
plot(x,f(x),'linewidth',2)
hold off

%%
% We observe that this gives a much better approximation to true density
% function $f$. The most important parameter when computing the kernel
% density estimate of a random sample is the halfwidth or standard
% deviation of the corresponding kernel function. Lets repeat the above
% density estimation with three different standard deviations

% plot the true density function
plot(x,f(x),'linewidth',2)
hold on

% and on top the kernel density estimates with different halfwidth
delta = [0.01 0.05 0.25];
for d = delta

  psi = Gaussian(0,d);
  fN = @(x) mean(psi(x-xN),1);
  plot(x,fN(x),'linewidth',2)
  
end
hold off
legend('$f$','$f_{0.01}$','$f_{0.05}$','$f_{0.25}$','interpreter','Latex'), 

%%
% In general a too small halfwidth leads to heavily oscillating functions,
% while a to large halfwdith will result in too smooth functions. In the
% case of one dimensional data the optimal half width is determined
% automatically when using the command <calcDensity.html |calcDensity|>.

fN = calcDensity(xN,'range',[0;1]);

plot(x,f(x),'linewidth',2)
hold on
plot(x,fN(x),'linewidth',2)
hold off

%% Kernel Density Estimation in d-Dimensions
% The command <calcDensity.html calcDensity> may also be applied to
% $d$-dimenional data. For simplicity lets consider a two dimensional
% example where both $x$ and $y$ coordinates are distributed according to
% the distribution $f$ defined at the very beginning of this section.

% the number of sample points
N = 100;
xN = discreteSample(f,N);
yN = discreteSample(f,N);

% plot the random sample
scatter(xN,yN)

%%
% Similarly to the one dimensional example we need to specify the range of
% the $x$ and $y$ coordinates for the estimated density function. The
% format is |[xMin yMin; xMax yMax]|.

% compte the two dimensional density function
fN = calcDensity([xN,yN],'range',[0 0;1 1]);

% plot the two dimensional density function 
[x,y] = ndgrid(linspace(0,1));
pcolor(x,y,fN(x,y))
shading interp

% plot the original random sample on top
hold on
scatter(xN,yN,'.','k')
hold off

%% Density Estimation on the Sphere





%% Density Estimation in Orientation Space






