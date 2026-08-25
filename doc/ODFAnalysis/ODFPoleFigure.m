%% Pole Figures of an ODF
%
%%
% A <ODFTheory.html pole density function> is what an ODF looks like from
% the outside. Fix a crystal direction $\vec h$ and ask, for every specimen
% direction $\vec r$, how much material has $\vec h$ pointing along $\vec
% r$. Formally it is the ODF integrated over all orientations that achieve
% this,
%
% $$ P_{\vec h}(\vec r) = \int_{g \vec h = \vec r} f(g)\, dg. $$
%
% Like the ODF itself it is a density, in multiples of a random
% distribution: 2 mrd at a specimen direction means twice as much material
% has $\vec h$ there as an untextured specimen would. And like the ODF, it
% is proportional to what a diffraction experiment measures after
% background, defocusing and structure-factor corrections - which is why
% pole figures are the bridge between measurement and texture, see
% <PoleFigure2ODF.html Reconstructing an ODF>.

plottingConvention.default('y↑→x');

%% A Model Texture to Look At
%
% Three components: two single orientations and one fibre.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.2*unimodalODF(mod1) ...
  + 0.3*unimodalODF(mod2) ...
  + 0.5*fibreODF(Miller(0,0,1,cs),vector3d(1,0,0),'halfwidth',10*degree);

%%
% <SO3Fun.plotPDF.html |plotPDF|> needs the ODF and the crystal directions
% to compute pole figures for.

plotPDF(odf,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},cs))
mtexColorMap LaboTeX

%%
% The two single components show as spots, the fibre as a ring - a fibre
% leaves one rotation free, and that freedom becomes a curve in the pole
% figure.
%
% Note also that the first two pole figures are drawn on the upper
% hemisphere alone while the third shows both. MTEX checks whether the two
% halves carry the same information and only then omits one.

%% When the Two Hemispheres Differ
%
% Forcing both to be drawn shows what the check found.

plotPDF(odf,Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},cs),'complete')
mtexColorMap LaboTeX

%%
% Upper and lower hemisphere agree in exactly three situations:
%
% * the crystal direction $\vec h$ is symmetrically equivalent to $-\vec h$
% - true here for $(10\bar10)$ and for the c-axis $(0001)$, not for
% $(11\bar21)$;
% * the symmetry group contains the inversion, i.e. is a Laue group;
% * antipodal symmetry is assumed, as is conventional for kinematic
% diffraction under Friedel's law, see <VectorsAxes.html Axes and Antipodal
% Symmetry>. Dynamical or resonant diffraction may distinguish the two
% sides, so the assumption belongs to the experiment rather than to the
% definition of an ODF.
%
% The last is the |'antipodal'| flag, and it makes the two halves equal by
% averaging them.

plotPDF(odf,Miller(1,1,-2,1,cs),'antipodal','complete')
mtexColorMap LaboTeX

%% Values Rather Than Pictures
%
% <SO3Fun.calcPDF.html |calcPDF|> evaluates the pole density function, at
% one specimen direction or on a whole grid.

odf.calcPDF(Miller(1,0,0,cs),vector3d.X)

%%
% 0.2 mrd along X - a direction this texture avoids. Averaged over the whole
% sphere a pole density function is 1, exactly as the ODF is.

mean(odf.calcPDF(Miller(1,0,0,cs)))

%% Along a Fibre
%
% A section through the ODF along a curve is often more informative than a
% projection of it. <SO3Fun.plotFibre.html |plotFibre|> plots the ODF along
% a <OrientationFibre.html fibre>.

f = fibre(Miller(1,0,0,odf.CS),vector3d.Y);

close all
plotFibre(odf,f,'LineWidth',2)

%%
% The curve is the density itself, not a projection of it, so its peaks are
% the components the fibre passes through.

%% Next
%
% The other projection, fixing a specimen direction instead of a crystal
% one, is <ODFInversePoleFigure.html Inverse Pole Figures>. Going the other
% way - from measured pole figures to an ODF - is
% <PoleFigure2ODF.html Reconstructing an ODF>.

%#ok<*NOPTS>
