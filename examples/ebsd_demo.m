%% MTEX - Analysis of EBSD Data
%
% Analysis of single orientation measurement.
%
% 
% 

%% specify crystal and specimen symmetry

cs = symmetry('cubic');
ss = symmetry('triclinic');

%% load EBSD data

ebsd = loadEBSD([mtexDataPath,'/aachen_ebsd/85_829grad_07_09_06.txt'],cs, ...
                ss,'header',1,'layout',[5,6,7,2],'phase',1)

%% plot pole figures as scatter plots
h = [Miller(1,0,0),Miller(1,1,0),Miller(1,1,1)];
close; figure('position',[100,100,600,300])
plotpdf(ebsd,h,'points',500,'reduced')

%% kernel density estimation
odf = calcODF(ebsd)

%% plot pole figures
plotpdf(odf,h,'reduced')

%% plot ODF
close;figure('position',[46   171   752   486]);
plotodf(odf,'alpha','sections',18,'resolution',2*degree,...
     'plain','gray','contourf','FontSize',10,'silent')
   
   
%% Estimation of Fourier Coefficients
%
% Once, a ODF has been estimated from EBSD data it is straight forward to
% calculate Fourier coefficients. E.g. by
Fourier(odf,'order',4);
%%
% However this is a biased estimator of the Fourier coefficents which
% underestimates the true Fourier coefficients by a factor that
% correspondes to the decreasing of the Fourier coeffients of the kernel
% used for ODF estimation. Hence, one obtains a *unbiased* estimator of the
% Fourier coefficients if they are calculated from an ODF estimated with
% the help fo the Direchlet kernel. I.e.

k = kernel('dirichlet',4);
odf2 = calcODF(ebsd,'kernel',k);
Fourier(odf2,'order',4);

%%
k = kernel('dirichlet',32);
odf2 = calcODF(ebsd,'kernel',k);
odf2 = calcFourier(odf2,32);
odf = calcFourier(odf,32);

plotFourier(odf,'color','b')
hold on
plotFourier(odf2,'color','r')

%% A Sythetic Example
%
% simulate EBSD data for the Santafee sample ODF

ebsd = simulateEBSD(santafee,10000)
plotodf(santafee,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10,'silent')

%% 
% estimate an ODF from the simulated EBSD data

odf = calcODF(ebsd,'halfwidth',10*degree)

%%
% plot the estimated ODF

plotodf(odf,'alpha','sections',18,'resolution',5*degree,...
     'plain','gray','contourf','FontSize',10,'silent')

%%
% calculate estimation error
calcerror(odf,santafee,'resolution',5*degree)

%% Exploration of the relationship between estimation error and number of single orientations
%
% simulate 10, 100, ..., 1000000 single orientations of the Santafee sample ODF, 
% estimate an ODF from these data and calcuate the estimation error

odf = {};
for i = 1:6

  ebsd = simulateEBSD(santafee,10^i);

  odf{i} = calcODF(ebsd);
  %odf{i} = calcFourier(odf{i},32);
  
  %fodf{i} = calcODF(ebsd,'kernel',kernel('Dirichlet',32));
  %fodf{i} = calcFourier(fodf{i},32);

  e(i) = calcerror(odf{i},santafee,'resolution',2.5*degree);
  
end

%% 
% plot the error in dependency of the number of single orientations
close all;
semilogx(10.^(1:6),e)

% %% 
% % plot Fourier coefficients in dependency of the 
% colororder = ['b','g','r','c','m','k','y'];
% l = {};
% for i = 2:6
%   plotFourier(odf{i},'color',colororder(i));
%   l = {l{:},['10^' int2str(i) ' points - de la Vallee Poussin']};
%   hold on
%   plotFourier(fodf{i},'color',colororder(i),'LineStyle',':');
%   l = {l{:},['10^' int2str(i) ' points - Dirichlet']};
% end
% plotFourier(santafee,'color','k','Linewidth',2,'bandwidth',32);
% ylim([0,0.4])
% legend(l)
% hold off
% 
% %% 
% % plot Fourier coefficients in dependency of the 
% colororder = ['b','g','r','c','m','k','y'];
% l = {};
% for i = 2:6
%   plotFourier(odf{i},'color',colororder(i),'LineStyle','none','Marker','o');
%   l = {l{:},['10^' int2str(i) ' points - de la Vallee Poussin']};
%   hold on
%   plotFourier(fodf{i},'color',colororder(i),'LineStyle','none','Marker','x');
%   l = {l{:},['10^' int2str(i) ' points - Dirichlet']};
% end
% plotFourier(santafee,'color','k','Marker','d','bandwidth',32,'LineStyle','none');
% ylim([0,0.4])
% legend(l)
% hold off
