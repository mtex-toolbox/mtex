%% Pole Figures
%
%%
% Let us first define some model ODFs to be plotted later on.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.2*unimodalODF(mod1) ...
  + 0.3*unimodalODF(mod2) ...
  + 0.5*fibreODF(Miller(0,0,1,cs),vector3d(1,0,0),'halfwidth',10*degree)

%odf = 0.2*unimodalODF(mod2)

%%
% and lets switch to the LaboTex colormap
setMTEXpref('defaultColorMap',LaboTeXColorMap);


%% Pole Figures
% Plotting some pole figures of an <ODF.ODF.html ODF> is straight forward
% using the <ODF.plotPDF.html plotPDF> command. The only mandatory
% arguments are the ODF to be plotted and the <Miller.Miller.html Miller
% indice> of the crystal directions you want to have pole figures for.

plotPDF(odf,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},cs))

%%
% While the first two  pole figures are plotted on the upper hemisphere
% only the (11-21) has been plotted for the upper and lower hemisphere. The
% reason for this behaviour is that MTEX automatically detects that the
% first two pole figures coincide on the upper and lower hemisphere while
% the (11-21) pole figure does not. In order to plot all pole figures with
% upper and lower hemisphere we can do

plotPDF(odf,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},cs),'complete')

%%
% We see that in general upper and lower hemisphere of the pole figure do
% not coincide. This is only the case if one one following reason is
% satisfied
%
% * the crystal direction h is symmetrically equivalent to -h, in the
% present example this is true for the c-axis h = (0001)
% * the symmetry group contains the inversion, i.e., it is a Laue group
% * we consider experimental pole figures where we have antipodal symmetry,
% due to Friedel's law.
%
% In MTEX antipodal symmetry can be enforced by the use the option *antipodal*.

plotPDF(odf,Miller(1,1,-2,1,cs),'antipodal','complete')


%%
% Finally, lets set back the default colormap.
setMTEXpref('defaultColorMap',WhiteJetColorMap);

%%

%%
% Evaluation of the corresponding pole figure or inverse pole figure is
% done using the command <ODF.calcPDF.html calcPDF>.

odf.calcPDF(Miller(1,0,0,cs),xvector)

%%

%%
% For a more complex example let us define a fibre and plot the ODF there.

fibre = orientation(fibre(Miller(1,0,0,odf.CS),yvector));

plot(odf.eval(fibre))
