%% Annotations
%
% After generating a plot with MTEX it is possible to modify it
% interactivly using the MATLAB plotting tools in the plotting figure. This
% includes colorbars, legends, specimen directions and crystal directions.


%% Some sample ODFs
%
% Let us first define some model ODFs to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
odf = fibreODF(Miller(1,1,0),zvector,cs,ss)


%% Adding a Colorbar
%
% Adding a colorbar is simply done by clicking the corresponding button in
% the figure toolbar or using the command <colorbar.html colorbar>. Note
% that the colorrange is automaticaly set to *equal* when adding a colorbar
% to a figure with  more then one plot (see. <ColorCoding_demo.html Color Coding>).

plotpdf(odf,[Miller(1,0,0),Miller(1,1,1)],'reduced')
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
% <plot2all.html plot2all> one can easily add <vector3d_index.html specimen
% coordinate axes> to a pole figure plot.

plot2all([xvector,yvector,zvector],'data',{'X','Y','Z'},'FontSize',16);

%%
% The command <plot2all.html plot2all> allows also to plot
% <Miller_index.html crystal directions> to inverse pole figures.

plotipdf(odf,[xvector,zvector])
plot2all([Miller(1,0,0,cs),Miller(1,1,0,cs),Miller(0,0,1,cs)],'all','FontSize',16)
set(gcf,'position',[139 258 672 266])


%% Adding a Legend
%
% If you have multiple data in one plot then it makes sence to add a legend
% saying which color / symbol correspond to which data set. 
%
% The following example compares the Fourier coefficients of the fibre ODF
% with the Fourier coefficients of an unimodal ODF.

plotFourier(odf)
hold all
plotFourier(unimodalODF(idquaternion,cs,ss))

legend({'Fibre ODF','Unimodal ODF'})

%% Adding a Spherical Grid
%
% Sometimes it is usefull to have a spherical grid in your plot to make the
% projection easier to understand. For this reason there are the option
% *grid*, which enables the grid and the option *grid_res*, which allows to
% specifiy the spacing of the grid lines.

plotpdf(odf,[Miller(1,0,0),Miller(0,0,1)],'grid','grid_res',15*degree,...
  'gray','reduced');
