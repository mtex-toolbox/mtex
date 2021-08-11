%% ODF Tutorial
%
%% Theory
%
% The orientation distribution function (ODF) is a function in
% orientation space that associates each orientation $g$ with the volume
% fraction of crystals in a polycrystaline specimen that are in this
% specific orientation, i.e.,
%
% $$\mathrm{odf}(g) = \frac{1}{V} \frac{\mathrm{d}V(g)}{\mathrm{d}g}.$$
%
% In MTEX a perfectly random texure will have an ODF equal to a value of one for all orientations. In
% other word the values of ODFs in MTEX can be interpreted as multiples of
% the random distribution (mrd). 
%
%% Computing an ODF from Individual Orientations
%
% Individual orientation data may be obtained experimentally by EBSD (orientation mapping in a SEM),
% ACOM (orientation mapping in a TEM) or 3d X-ray imaging; or from computer simulations involving texture modeling, such as VPSC. In the
% following example we consider an EBSD map of an Titanium alloy.  Note that this test data is based on hexagonal layout rather than the more common x-y grid.

% import the titanium test data downloaded with the MTEX package
mtexdata titanium

% plot an orientation map
plot(ebsd, ebsd.orientations)

%%
% Computing an ODF from individual orientations is done by
% <DensityEstimation.html kernel density estimation> using the command
% <orientation.calcDensity.html |calcDensity|>.

% copy the EBSD orientations to a separate variable
ori = ebsd.orientations;

% compute the ODF
odf = calcDensity(ori)

%%
% There many different ways to visualize an ODF: <EulerAngleSections.html
% Euler> or <SigmaSections.html sigma sections>, <ODFPlot.html thee
% dimensional plots>, <ODFPoleFigure.html pole figures> and
% <ODFInversePoleFigure.html inverse pole figures>. The most common but not
% recommended method uses sigma sections, slices with respect to the third Euler angle
% $\varphi_2$

plot(odf)

%% Computing an ODF from Pole Figure Data
%
% Pole figure data is often generated when textured materials are measured via x-ray,
% neutron or syncrotron radiation. When performing this type of diffraction experiment, 
% diffraction intensities are measured over a spherical grid of specimen directions for $3$ to $10$ diffraction
% planes specified by Miller indices $(hk\ell)$ . In the example below, for each plane indicated
% at the top of the spherical plot, each dot colour corresponds to a measured diffraction intensity 
% at the position corresponding to the dot location.

% import the PTX pole figure test data downloaded with the MTEX package
mtexdata ptx

% plot the pole figures, representing the experimental data acquired
plot(pf)
% show the colour bar.  Note the maximum intensity is different for each pole figure.
mtexColorbar

%%
% The <PoleFigure2ODF.html reconstuction> of an ODF from pole figure data
% requires the solution of an *ill posed inverse problem*. This means the
% reconstruction problem generally <PoleFigure2ODFAmbiguity.html does not have a
% unique solution>, and there are several ODFs that may be constructed from the same
% set of pole figure data. MTEX generates multiple possibilities, and then applies <PoleFigure2ODFGhostCorrection.html
% some selection criteria> to identify the physically most
% reasonable result.

% compute an ODF from the three input pole figures with default settings
odf = calcODF(pf)

%%
% Once an ODF is reconstructed we can check how well the ODF's pole figures fit
% the experimentally measured pole figures

% plot the pole figures of the calculated ODF
plotPDF(odf,pf.h)


%% ODF Modelling
%
% Aside from using experimental data, MTEX also allows the definition of model
% ODFs of different types. These include <UnimodalODFs.html unimodal ODFs>,
% <FibreODFs.html fibre ODFs>, <BinghamODFs.html Bingham Distributed ODFs>
% and any <ODFModeling.html combination of such ODFs>.

% define a gamma fibre ODF
odf = fibreODF(fibre.gamma(odf.CS))

% plot it in sigma sections
plot(odf,'sigma')

