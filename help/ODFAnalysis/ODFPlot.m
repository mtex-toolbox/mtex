%% Visualising ODFs
%
%% Open in Editor
%

%% Abstract
% This sections gives you an overview over the functionality MTEX offers to
% visualize ODfs.
%
%% Contents
%
%% Some sample ODFs
%
% Let us first define some model ODFs to be plotted later on.

cs = symmetry('-3m'); ss = symmetry('-1');
mod1 = orientation('euler',30*degree,40*degree,10*degree,'ZYZ');
mod2 = orientation('euler',10*degree,80*degree,70*degree,'ZYZ');
odf = 0.7*unimodalODF(mod1,cs,ss) + 0.3*unimodalODF(mod2,cs,ss);

%% Plot Pole Figures
% Plotting some pole figures of an <ODF_index.html ODF> is straight forward
% using the <ODF_plotpdf.html plotpdf> command. The only mandatory
% arguments are the ODF to be plotted and the <Miller_index.html Miller
% indice> of the crystal directions you want to have pole figures for.

close; figure('position',[100,100,800,200])
plotpdf(odf,[Miller(1,0,-1,0),Miller(0,0,0,1)])

%%
% By default the <ODF_plotpdf.html plotpdf> command plots the upper as well
% a the lower hemisphere of each pole sphere. In order to superpose
% antipodal directions you have to use the option *antipodal*.

plotpdf(odf,[Miller(1,0,-1,0),Miller(0,0,0,1)],'antipodal')


%% Plot Inverse Pole Figures
% Plotting inverse pole figures is analogously to plotting pole figures
% with the only difference that you have to use the command
% <ODF_plotipdf.html plotipdf> and you to specify specimen directions and
% not crystal directions.

plotipdf(odf,[xvector,zvector],'antipodal')

%% 
% By default MTEX alway plots only the Fundamental region with respect to
% the crystal symmetry. In order to plot the complete inverse pole figure
% you have to use the option *complete*.

close; figure('position',[100,100,400,200])
plotipdf(odf,[xvector,zvector],'antipodal','complete')

%% Plot ODF Sections
% 
% Plotting an ODF in two dimensional sections through the orientation space
% is done using the command <ODF_plotodf.html plot>.

close; figure('position',[46 171 752 486]);
plot(odf,'sections',12,'silent')

%%
% By default ODFs are plotted in sigma sections. One can also plot ODF
% sections along any of the Euler angles alpha, gamma, ph1 or phi2.
% Adapting <SphericalProjection_demo.html spherical projection> and
% <ColorCoding_demo color coding> one can produce any standard ODF plot.

close; figure('position',[46 171 752 486]);
plot(odf,'alpha','sections',12,...
     'projection','plain','gray','contourf','FontSize',10,'silent')


%% Plot One Dimensional ODF Sections
% In the case you have a simple ODF it might be helpfull to plot one
% dimensional ODF sections.

plot(odf,'radially','LineWidth',2)

%% Plot Fourier Coefficients
% A last way to visualize an ODF is to plot its Fourier coefficients

close all;
plotFourier(odf,'bandwidth',32)
