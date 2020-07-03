%% ODF Tutorial
%
%% Theory
%
% The orientation distribution function (ODF) is a function on the
% orientation space that associates to each orientation $g$ the volume
% percentage of crystals in a polycrystaline specimen that are in this
% specific orientation, i.e.,
%
% $$\mathrm{odf}(g) = \frac{1}{V} \frac{\mathrm{d}V(g)}{\mathrm{d}g}.$$
%
% In MTEX an entirely random texure will have an ODF constant to one. In
% other word the values of ODFs in MTEX can be interpreted as multiples of
% the random distribution (mrd). 
%
%% Computing an ODF from Individual Orientations
%
% Individual orientations data may be obtained by experimental by EBSD,
% ACOM or 3d X-ray imaging; or from simulations, like VPSC. In the
% following we consider an EBSD map of an Titanium alloy.

% import the titanium data
mtexdata titanium

% plot an orientation map
plot(ebsd, ebsd.orientations)

%%
% Computing an ODF from individual orientations is done by
% <DensityEstimation.html kernel density estimation> using the command
% <orientation.calcDensity.html |calcDensity|>.

% extract the orientations
ori = ebsd.orientations;

% compute the ODF
odf = calcDensity(ori)

%%
% There many different ways to visualize ODF: <EulerAngleSections.html
% Euler> or <SigmaSections.html sigma sections>, <ODFPlot.html thee
% dimensional plots>, <ODFPoleFigure.html pole figures> and
% <ODFInversePoleFigure.html inverse pole figures>. The most common but not
% recommended way are sections with respect to the third Euler angle
% $\varphi_2$

plot(odf)

%% Computing an ODF from Pole Figure Data
%
% Pole figure data arises when textured materials are measured via x-ray,
% neutron or syncrotron radiation. Generaly, for $3$ to $10$ diffraction
% planes specified by Miller indices $(hk\ell)$ diffraction intensities are
% measured at a spherical grid of specimen directions. In the example below
% each dot corresponds to one diffraction intensity at the plane indicated
% at the top of the spherical plots measured from the direction
% corresponding to the pixel position.

% import pole figure data
mtexdata ptx

% plot the data
plot(pf)
mtexColorbar

%%
% The <PoleFigure2ODF.html reconstuction> of an ODF from pole figure data
% requires the solution of an ill posed inverse problem. This mean the
% reconstruction problem has in general <PoleFigure2ODFAmbiguity.html not a
% unique solution>, but there are several ODFs that correspond to the same
% set of pole figure data. MTEX applies <PoleFigure2ODFGhostCorrection.html
% some heuristics> to identify among all solutions the physically most
% reasonable.

% compute an ODF with default settings
odf = calcODF(pf)

%%
% Once an ODF is reconstructed we can check how well its pole figures fit
% the measured pole figures

% plot the recalculated pole figures 
plotPDF(odf,pf.h)


%% ODF Modelling
%
% Besides from experimental data MTEX allows also the definition of model
% ODFS of different type. These include <UnimodalODFs.html unimodal ODFs>,
% <FibreODFs.html fibre ODF>, <BinghamODFs.html Bingham Distributed ODFs>
% and any <ODFModeling.html combination of such ODFs>.

% define a fibre symmetric ODF
odf = fibreODF(fibre.gamma(odf.CS))

% plot it in sigma sections
plot(odf,'sigma')

