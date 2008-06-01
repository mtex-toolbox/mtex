%% Plotting
%
% In MTEX you can plot almost any type data. Simply apply the *plot*
% command to any variable and MTEX tries to plot the content of the
% variable in the most intuive way. In this way you can plot three
% Miller indeces, rotations, pole figures, or ODFs. MTEX also offers you
% a wide range of possibilities to custumize your plots, e.g. by changing
% the <PlotTypes_demo.html plot style>, the 
% <SphericalProjection_demo.html spherical projection>, the
% <ColorCoding_demo.html color coding>, or by adding 
% <Annotations_demo.html colorbars or other annotations> to the plot. This way
% MTEX allows you to create publication ready plots which can be exported
% to almost any format using the commands <savefigure.html savefigure>.
%
%
%% Plotting Three Dimensional Vectors
%
% A three dimensional vector is plotted by its
% <SphericalProjection_demo.html spherical projection>.

close all;figure('position',[100,100,200,200]);
plot([xvector,yvector,zvector])


%% Plotting Miller Indice
%
% Miller indeces are first converted into three dimensional vectors using
% the crystal coordinate system and then plotted as described above. Using
% the option *all* one makes MTEX plotting all crystallographic equivalent
% directions to a given one.

close all;figure('position',[100,100,400,200]);
cs = symmetry('-3m',[1 1 3])
plot(Miller(1,1,-2,2,cs),'all')

%% Plotting Rotations
%
% Rotations are visualzied by plotting the rotated X, Y, and Z axis in a
% spherical plot. Take care the rotations have first be converted into
% quaternions to be plotted, e.g. by using <euler2quat.html euler2quat>,
% <axis2quat.html axis2quat>, or <Miller2quat.html Miller2quat>.

q = euler2quat(30*degree,50*degree,10*degree);
plot(q)

%% Plotting Pole Figures Data
%
% Pole figure data are plotted in MTEX by single points in a 
% <SphericalProjection_demo.html spherical projection> which are colored
% according to their intensity.

pf = simulatePoleFigure(santafee,Miller(1,0,0),S2Grid('regular'));
plot(pf)


%% Plotting ODFs
%
% The ODF plotting command <ODF_plotodf.html plotodf> allows to plot
% various sections of an ODF. Pole figure of an ODF are plotted by
% <ODF_plotpdf.html plotpdf> and inverse pole figures by 
% <ODF_plotipdf.html plotipdf>. In all cases one can specify the 
% <SphericalProjection_demo.html spherical projections>, the 
% <PlotTypes_demo.html plotting type>, and the <ColorCoding_demo.html color coding>.

close; figure('position',[46 171 752 486]);
plot(santafee,'alpha','sections',18,'resolution',5*degree,...
  'projection','plain','gray','contourf','FontSize',10,'silent')

%% Plotting EBSD Data
%
% EBSD data are plotted by default in Rodriguez space. The command
% <EBSD_plotpdf.html plotpdf> allows also to plot the individual axis
% orientations.

cs = symmetry('-3m'); ss = symmetry('triclinic');
odf = unimodalODF(idquaternion,cs,ss);
ebsd = simulateEBSD(odf,100);
plot(ebsd)

%%
% MTEX allows also to plot pole figures of EBSD data.
h = [Miller(0,0,0,1,cs),Miller(1,0,-1,0,cs)];
plotpdf(ebsd,h,'reduced','diameter',0.05)


%% Combining Several Plots
%
% Sometimes it is usefull to combine several plots, e.g. plotting on the
% top of an inverse pole figure some important crystall directions. This
% can be performed by the command <a href="matlab:doc hold">hold all</a>,
% which preserfes MATLAB from replacing the old plot by the new one.
%
% First we want to superpose the above EBSD pole figure with another EBSD
% pole figure.
ebsd_rotated = simulateEBSD(rotate(odf,euler2quat(60*degree,60*degree,0*degree)),100);

hold all % keep plot
plotpdf(ebsd_rotated,h,'diameter',0.05);
hold off % next plot command deletes all plots

%%
% Next we are going to add some Miller indece to an inverse pole figure
% plot.

close all;figure('position',[100,100,300,200]);
plotipdf(odf,xvector);

hold all % keep plot
plot(Miller(1,1,-2,0,cs),'all')
plot(Miller(1,1,-2,1,cs),'all')
hold off % next plot command deletes all plots
