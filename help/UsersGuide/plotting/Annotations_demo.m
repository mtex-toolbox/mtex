%% Annotations
%
%% Open in Editor
%
%% Abstract
% After generating a plot with MTEX it is possible to modify it
% interactivly using the MATLAB plotting tools in the plotting figure. This
% includes colorbars, legends, specimen directions and crystal directions.
%
%% Contents
%

%% Some sample ODFs
%
% Let us first define some model ODFs to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
mod1 = orientation('Euler',30*degree,40*degree,10*degree);
mod2 = orientation('Euler',10*degree,80*degree,70*degree);
odf = 0.7*unimodalODF(mod1,cs,ss) + 0.3*unimodalODF(mod2,cs,ss);


%% Adding a Colorbar
%
% Adding a colorbar is simply done by clicking the corresponding button in
% the figure toolbar or using the command <colorbar.html colorbar>. Note
% that the colorrange is automaticaly set to *equal* when adding a colorbar
% to a figure with  more then one plot (see. <ColorCoding_demo.html Color Coding>).

plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'antipodal','gray')
colorbar


%%
% Executing the command <colorbar.html colorbar> twice deletes the colorbar.
% You can also have a horzontal colorbar at the bottom of the figur using
% the option *south*.

colorbar           % delete vertical colorbar
colorbar('south')  % add horizontal colorbar

%% Adding Specimen and Crystal Directions
%
% Pole figure and inverse pole figures are much more readable if there are
% included specimen or crystal directions. Using the MTEX command 
% <annotate.html annotate> one can easily add <vector3d_index.html specimen
% coordinate axes> to a pole figure plot.

annotate([xvector,yvector,zvector],'label',{'x','y','z'},...
  'BackgroundColor','w');

%%
% The command <annotate.html annotate> allows also to plot
% <Miller_index.html crystal directions> to inverse pole figures.

plotipdf(odf,[xvector,zvector],'gray','antipodal','marginx',10,'minmax','off')
annotate([Miller(1,0,0),Miller(1,1,0),Miller(0,0,1),Miller(2,-1,0)],'all','labeled')
set(gcf,'position',[139 258 672 266])


%% Adding Preferred Orientations
%
% One can also mark specifc orientations in pole figure, inverse pole
% figures

plotipdf(odf,[xvector,zvector],'gray','antipodal','marginx',10,'minmax','off')
annotate(mod1,...
    'marker','s','MarkerSize',6,'MarkerFaceColor','r',...
    'label','A','color','w')

annotate(mod2,...
    'marker','s','MarkerSize',6,'MarkerFaceColor','g',...
    'label','B','color','w')

%%
% or ODF plots

plot(odf,'sections',12,'gray','position',[100,100,500,380])
annotate(mod1,...
    'MarkerSize',15,'MarkerEdgeColor','r','MarkerFaceColor','none')

annotate(mod2,...
  'MarkerSize',15,'MarkerEdgeColor','g','MarkerFaceColor','none')
  
%%
% or EBSD scatter plots

ebsd = simulateEBSD(odf,200);
scatter(ebsd,'center',mod1);
annotate(mod1,...
  'MarkerSize',10,'MarkerEdgeColor','r','MarkerFaceColor','r')
annotate(mod2,...
  'MarkerSize',10,'MarkerEdgeColor','g','MarkerFaceColor','g')


%% Adding a Legend
%
% If you have multiple data in one plot then it makes sence to add a legend
% saying which color / symbol correspond to which data set. 
%
% The following example compares the Fourier coefficients of the fibre ODF
% with the Fourier co,'margin'}efficients of an unimodal ODF.

plotFourier(odf)
hold all
plotFourier(fibreODF(Miller(1,0,0),zvector,cs,ss))

legend({'Fibre ODF','Unimodal ODF'})

%% Adding a Spherical Grid
%
% Sometimes it is usefull to have a spherical grid in your plot to make the
% projection easier to understand. For this reason there are the option
% *grid*, which enables the grid and the option *grid_res*, which allows to
% specifiy the spacing of the grid lines.

plotpdf(odf,[Miller(1,0,0),Miller(0,0,1)],'grid','grid_res',15*degree,...
  'gray','antipodal');
