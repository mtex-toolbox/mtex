%% ODF Plots
%
%% Open in Editor
%

%% Abstract
% In this section the basic plotting commands for ODFs are described. MTEX 
% offers a lot of possibilities the customize the resulting plots, e.g. by
% changing the projection or the colorcoding, by outlining certain 
% orientations or directions, or simply by adding colorbars or legends to
% plots. All these posibilities are described in the section
% <plot_index.html Plotting>. 
%
%% Contents
%
%% A Model ODF
% Lets start with a simple ODF which is the superposition of a unimodal ODF
% and a fibre symmetric model ODF 

cs = symmetry('-3m'); 
ss = symmetry('-1');
mod1 = orientation('euler',50*degree,30*degree,20*degree,'ZYZ',cs,ss);

odf = 0.1 * unimodalODF(mod1,cs,ss) ...
  + 0.9*fibreODF(Miller(0,0,1),xvector,cs,ss) 

%% Pole Figure Plots
% 
% In order to plot the pole figures corresponding to a certain list of
% crystal directions one uses the command <ODF_plotpdf.html plotpdf>.

h = [Miller(1,0,-1,0,cs),Miller(0,0,0,1,cs),...
  Miller(1,1,-2,1,cs),Miller(1,1,-2,3,cs)];
plotpdf(odf,h,'position',[100 100 600 300])

%%
% One recognizes that for each crystal direction the northern and the
% southern hemisphere of the pole figure is plotted. Since specimen
% symmetry here is tricline they might differ. It is well known that
% diffration data results in pole figures where the norther and the
% southern hemispheres are superposed. This can achieved in MTEX by passing
% the option *antipodal*.

plotpdf(odf,h,'antipodal')

%% Inverse Pole Figure Plots
%
% Plotting inverse pole figures with respect to certain specimen directions
% is as simple as plotting ordinary pole figures. Here one has to use the
% command <ODF_plotipdf.html plotipdf>. 

r = [vector3d(1,0,0),vector3d(0,0,1)];
plotipdf(odf,r,'position',[100 100 600 300])

%%
% Due to the trigonal crystal symmetry not a complete sphere is plotted but
% only a 120° sector. In order to plot the complete inverse pole figure
% simply add the option *complete*.

plotipdf(odf,r,'complete')

%% ODF Sections
%
% In order to plot an ODF directly one has to specify a certain type
% sections. Currently the following sections are supported.
%
% * alpha sections
% * gamma sections
% * phi1 sections
% * phi2 sections
% * sigma sections
%
% The default section type is *sigma sections* since it does not introduce 
% distortions into the orientation space.

plot(odf,'sections',12,'position',[100 100 450 350],'silent')

%%
% In order to specify a different section type one simpy adds the
% corresponding name as an option. E.g. the traditional ODF plot is
% achieved by

plot(santafee,'alpha','sections',9,...
  'projection','plain','gray','contourf','silent')


%% Radial ODF Plots
%
% In case you have an unimodal ODF a radial plot is sometimes usefull. 
%

plot(odf,'radially','center',euler2quat(50*degree,30*degree,20*degree))

%% Power Plot
%
% Last but not least there is a power plot, plotting the Fourier
% coefficients of an ODF

plotFourier(odf,'bandwidth',32)
