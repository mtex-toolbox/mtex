%% Pole Figures of an ODF
%
%%
% A *pole density function* is a two-dimensional projection of an ODF.
% Fix a crystal direction $\vec h$ and ask how much material points it
% along each specimen direction $\vec r$.
%
% This page assumes the ODF and mrd normalization introduced in
% <ODFTheory.html ODF Theory>. Crystal directions and their Miller indices
% are introduced in <CrystalDirections.html Miller Indices>.
%
% Formally, the pole density function is the ODF integrated over every
% orientation that maps $\vec h$ onto $\vec r$,
%
% $$ P_{\vec h}(\vec r) = \int_{g \vec h = \vec r} f(g)\, \mathrm{d}g. $$
%
% This integral is the spherical Radon transform of the ODF. It collapses
% a whole <OrientationFibre.html orientation fibre> to one value, so a pole
% figure is a projection rather than a section through orientation space.
% One pole figure cannot determine a three-dimensional ODF, and different
% ODFs can produce the same pole figure.
%
% Like the ODF itself, the result is a density in multiples of a random
% distribution (mrd). A value of 2 mrd means twice the random density at
% that specimen direction, not two percent of the material.
%
% After background, defocusing, and structure-factor corrections, this
% density is proportional to what a diffraction experiment measures. Pole
% figures therefore connect diffraction measurements to texture; see
% <PoleFigure2ODF.html Reconstructing an ODF> for the inverse problem.
%
% A *plotting convention* states how a reference frame is laid out on
% screen. The following convention draws specimen Y upward and specimen X
% to the right. It does not rotate the specimen or change the ODF.

plottingConvention.default('y↑→x');

%% A Model Texture to Look At
%
% The example combines two single-orientation components with one fibre
% component. Trigonal symmetry makes the difference between a direction
% and its opposite visible in the third pole figure.

cs = crystalSymmetry('32');
mod1 = orientation.byEuler(90*degree,40*degree,110*degree,'ZYZ',cs);
mod2 = orientation.byEuler(50*degree,30*degree,-30*degree,'ZYZ',cs);

odf = 0.2*unimodalODF(mod1) ...
  + 0.3*unimodalODF(mod2) ...
  + 0.5*fibreODF(Miller(0,0,1,cs),vector3d.X,...
  'halfwidth',10*degree);

% select three crystal directions in four-index notation
h = Miller({1,0,-1,0},{0,0,0,1},{1,1,-2,1},cs);

%%
% <SO3Fun.plotPDF.html |plotPDF|> fixes each crystal direction in |h| and
% draws its pole density over specimen directions. The panels use the
% <SphericalProjections.html default spherical projection>.

plotPDF(odf,h);
mtexColorMap LaboTeX;

%%
% The two single-orientation components make localized spots. The fibre
% component makes a ring because its remaining rotational freedom becomes
% a curve in the pole figure.
%
% MTEX draws only the upper hemisphere when the lower hemisphere contains
% no independent information. That is why the first two pole figures use
% one disc while the third uses two.

%% When the Two Hemispheres Differ
%
% The |'complete'| flag displays both hemispheres for every direction. It
% changes the displayed region; it does not symmetrize the pole density or
% restore information lost by the projection.

plotPDF(odf,h,'complete');
mtexColorMap LaboTeX;

%%
% The upper and lower hemispheres agree in exactly three situations:
%
% * the crystal direction $\vec h$ is symmetrically equivalent to $-\vec h$
% - true here for $(10\bar10)$ and the c-axis $(0001)$, but not for
% $(11\bar21)$;
% * the crystal symmetry contains inversion and is therefore a
% <CrystalSymmetries.html Laue group>;
% * antipodal symmetry is assumed, as is conventional for kinematic
% diffraction under Friedel's law; see <VectorsAxes.html Axes and Antipodal
% Symmetry>.
%
% Dynamical or resonant diffraction may distinguish the two sides. The
% antipodal assumption therefore belongs to the experiment, not to the
% definition of an ODF.
%
% The |'antipodal'| flag averages opposite directions. With |'complete'|
% retained below, both equal halves remain visible for comparison.

plotPDF(odf,h(3),'antipodal','complete');
mtexColorMap LaboTeX;

%%
% Opposite points in the two discs now have the same colour. Drawing both
% discs does not make them independent measurements.

%% Values Rather Than Pictures
%
% <SO3Fun.calcPDF.html |calcPDF|> with only a crystal direction returns a
% spherical function. Passing a specimen direction as well evaluates that
% function at one point.

pdf = calcPDF(odf,Miller(1,0,0,cs))
densityAtX = calcPDF(odf,Miller(1,0,0,cs),vector3d.X)

%%
% The printed summary identifies |pdf| as a spherical function. Its value
% along specimen X is 0.1982 mrd, so this texture avoids that direction.
%
% Averaged over the whole sphere, every normalized pole density function is
% 1 mrd, just as every normalized ODF has mean 1 mrd.

meanDensity = mean(pdf)

%% Following a Pole-Figure Maximum into Orientation Space
%
% A pole-figure maximum still represents a whole orientation fibre. Find
% the strongest specimen direction for the third pole figure, then inspect
% the ODF along the corresponding fibre with
% <SO3Fun.plotFibre.html |plotFibre|>.

pdfPeak = calcPDF(odf,h(3));
[~,rPeak] = max(pdfPeak);
f = fibre(h(3),rPeak);

close all;
plotFibre(odf,f,'LineWidth',2,'figSize','small');

%%
% The line is the ODF density itself, not another projection. Its peaks
% locate the components that this fibre passes through, while their average
% along the curve is the pole-figure value at |rPeak|. This is the degree of
% freedom that the pole figure hides.

%% Further Reading
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982. Chapters on pole figures and orientation distributions develop the
% classical forward and inverse transforms.
% * ASTM International,
% <https://doi.org/10.1520/E0081-96R24 ASTM E81-96(2024): Standard Test
% Method for Preparing Quantitative Pole Figures>. It covers quantitative
% X-ray pole figures and the distinction between complete, partial, and
% calculated pole figures.
% * H.-J. Bunge and C. Esling,
% <https://doi.org/10.1107/S0021889881009308 Determination of the odd part
% of the texture function by anomalous scattering>, _Journal of Applied
% Crystallography_ 14 (1981), 253--255. It explains why ordinary
% diffraction loses the odd ODF part and how anomalous scattering changes
% that limitation.

%% Next
%
% The other projection fixes a specimen direction instead of a crystal
% direction; continue with <ODFInversePoleFigure.html Inverse Pole
% Figures>. Going the other way, from measured pole figures to an ODF, is
% <PoleFigure2ODF.html Reconstructing an ODF>.

%#ok<*NOPTS>
