%% ODF Shapes (The class @kernel) 
% standard distributions on SO(3)
%
%% Contents
%
%% Class Description 
% The class *kernel* is needed in MTEX to define the specific form of
% unimodal and fibre symmetric ODFs. It has to be passed as an argument
% when calling the methods [[uniformODF.html,uniformODF]] and
% [[fibreODF.html,fibreODF]]. 
%
%% SUB: Defining a kernel function
%
% A kernel is defined by specifying its name and its free parameter.
% Alternatively one can also specify the halfwidth of the kernel. Below you
% find a list of all kernel functions supported by MTEX.

demok(1) = kernel('Abel Poisson',0.79);
demok(2) = kernel('de la Vallee Poussin',13);
demok(3) = kernel('von Mises Fisher',7.5);
demok(4) = kernel('bump',35*degree);
demok(5) = kernel('Square Singularity',0.72);
demok(6) = kernel('fibre von Mises Fisher',7.2);
demok(7) = kernel('Gauss Weierstrass',0.07);
demok(8) = kernel('Dirichlet',3);
%demok(4) = kernel('local',0.85);


%% SUB: Plotting the kernel
%
% Using the plot command you can plot the kernel as a function on SO(3) as
% well as the corresponding PDF, or its Fourier coefficients

% the kernel on SO(3)
close; figure('position',[100,100,500,450])
plot(demok,'K','legend');

%%
% the corresponding PDF
plot(demok,'RK','legend');
ylim([-5,20])

%%
% the Fourrier coefficients of the kernels
plot(demok,'Fourier','bandwidth',32,'legend');
