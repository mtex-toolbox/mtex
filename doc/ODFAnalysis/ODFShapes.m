%% Unimodal ODF Shapes
%
%%
% Also take a look at the page <SO3Kernels.html SO3Kernels>.
%
% In order to control the shape of unimodal ODF
% The classes @SO3Kernel and @S2Kernel are needed in MTEX to define the 
% specific form of unimodal and fibre symmetric ODFs. It has to be passed 
% as an argument when calling the methods <uniformODF.html uniformODF> or
% <fibreODF.html fibreODF>. 
%
% A kernel is defined by specifying its name and its free parameter.
% Alternatively one can also specify the halfwidth of the kernel. Below you
% find a list of some important SO3Kernel functions supported by MTEX.

psi{1} = SO3AbelPoissonKernel(0.79);
psi{2} = SO3DeLaValleePoussinKernel(13);
psi{3} = SO3BumpKernel(35*degree);
psi{4} = SO3DirichletKernel(3);
psi{5} = SO3vonMisesFisherKernel(7.5);
psi{6} = SO3GaussWeierstrassKernel(0.07);
psi{7} = fibreVonMisesFisherKernel(7.2);
psi{8} = SO3SquareSingularityKernel(0.72);


%% 
% Lets visualize these kernel functions as one dimensional sections through
% the orientation space

% the kernel on SO(3)
close; 
figure('position',[100,100,1000,450])
hold all
for i = 1:numel(psi)
  plot(psi{i},'DisplayName',class(psi{i}));
end
hold off
legend(gca,'show','Location','eastoutside')


%%
% one dimensional sections through the corresponding PDF

close; figure('position',[100,100,1000,450])
hold all
for i = 1:numel(psi)
  plot(psi{i}.radon,'symmetric','DisplayName',class(psi{i}),'linewidth',2);
end
hold off

ylim([-5,20])

legend(gca,'show','Location','eastoutside')
%%
% the Fourier coefficients of the kernels

close; figure('position',[100,100,500,450])
hold all
for i = 1:numel(psi)
  plotSpektra(psi{i},'bandwidth',32,'linewidth',2,'DisplayName',class(psi{i}));
end
hold off
legend(gca,'show')

