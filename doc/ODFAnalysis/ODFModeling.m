%% ODF Modeling
%
%%
% An orientation distribution function (ODF) does not have to come from a
% measurement. A *model ODF* is built from a few chosen ingredients: a
% preferred orientation and its spread, a fibre, or a mixture of these.
% Because its ingredients are known, a model ODF can serve as a reference
% for measured textures, as a starting point for texture-evolution
% simulations, or as test data with a known answer.
%
% This page assumes the normalization and multiples of a random distribution
% (mrd) introduced in <ODFTheory.html ODF Theory>. Every ODF in MTEX follows
% the <SO3FunConcept.html |@SO3Fun|> interface for functions on the rotation
% group $SO(3)$. The physical model and its numerical representation are
% related, but they are not the same choice:
%
% || construction || meaning ||
% || <RadialODFs.html uniform> || constant, the untextured reference ||
% || <RadialODFs.html unimodal> || a radial peak about one orientation ||
% || <RadialODFs.html multimodal> || several radial peaks ||
% || <FibreODFs.html fibre> || a peak spread along a curve in orientation space ||
% || <BinghamODFs.html Bingham> || a parametric peak with three independent spreads ||
% || <SO3FunHarmonicRepresentation.html harmonic representation> || a series expansion, the classical form used for pole figure inversion ||
%
% Harmonic names a representation, not another physical peak shape. The
% current <PoleFigure.calcODF.html |calcODF|> normally returns a radial-basis ODF.
% It can then be converted to a harmonic series. All of these objects share
% one interface for evaluation, plotting, scaling, and addition. This is why
% components with different representations can be mixed in one model.

plottingConvention.default('y↑→x');

%% The Uniform ODF
%
% The simplest model is the constant function
%
% $$f(g) = 1,\quad g \in SO(3).$$
%
% It needs only the crystal and specimen symmetries. The returned summary is
% useful here: it records both symmetries and identifies the constant
% component.

cs = crystalSymmetry('cubic');
ss = specimenSymmetry('orthorhombic');

odf = uniformODF(cs,ss)

%%
% A value of 1 mrd everywhere is an untextured specimen. This uniform ODF is
% the reference against which every other mrd value is measured.

%% A Single Component
%
% A unimodal ODF is a peak about one preferred orientation. A
% <SO3Kernels.html kernel> sets the shape, and its halfwidth sets the angular
% distance at which the kernel falls to half its maximum. The halfwidth is a
% spread parameter, not a cutoff: the component continues beyond that angle.

psi = SO3vonMisesFisherKernel('halfwidth',10*degree);

mod1 = orientation.byMiller([1,2,2],[2,2,1],cs,ss);

odf1 = unimodalODF(mod1,psi)

%%
% The summary records the kernel, centre, and component weight. The maximum
% sits at the preferred orientation and its symmetry-equivalent copies. Its
% value measures concentration rather than volume fraction. A narrower
% normalized peak has a higher maximum because its mean must remain one.

odfMax = max(odf1)

%%

plotPDF(odf1,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal',...
  'colorRange','equal')
mtexColorbar('title','mrd')

%%
% The localized spots are projections of one preferred orientation and its
% symmetry-equivalent copies. They are not separate components.

%% Mixtures
%
% ODFs are added and scaled like functions, so a textured component can sit
% on a uniform background. The classical Santa Fe standard is 27 percent of
% the component above and 73 percent uniform background.

odf = 0.73 * uniformODF(cs,ss) + 0.27 * unimodalODF(mod1,psi)

%%
% The printed summary separates the uniform and unimodal terms. Both are
% individually normalized, so their coefficients act as mixture volume
% fractions. They must add up to one if the mixture is to remain normalized.

mean(odf)

%%
% The mean is 1. The component peaks may overlap in orientation space, but
% the coefficients still describe the fractions assigned to the two terms.
% They are not volumes of disjoint regions drawn around the maxima.

close all
plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal',...
  'colorRange','equal')
mtexColorbar('title','mrd')

%%
% The uniform term contributes a 0.73 mrd background, while the unimodal
% term produces the spots. This known model is commonly used to test pole
% figure inversion; <PoleFigureSantaFe.html The Santa Fe Example> simulates
% pole figures from it and scores the reconstruction against the answer.

%% Rotating a Model
%
% <SO3Fun.rotate.html |rotate|> actively moves a model relative to the
% specimen axes. By default, the rotation acts on the specimen side of every
% component orientation.

odfRot = rotate(odf,rotation.byAxisAngle(vector3d.Z,30*degree));

plotPDF(odfRot,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal',...
  'colorRange','equal')
mtexColorbar('title','mrd')

%%
% Compared with the preceding pole figures, every feature turns by
% $30^\circ$ about the centre. The original |mmm| specimen symmetry was tied
% to x, y, and z. It is no longer coordinate-aligned after this rotation, so
% MTEX drops the specimen-symmetry label and issues a warning. The physical
% twofold axes have rotated with the texture.
%
% A frame change is different: it re-expresses the same physical texture in
% another reference frame and leaves the texture itself untouched. Use
% <SO3Fun.transformReferenceFrame.html |transformReferenceFrame|> when the
% crystal frame changes. The corresponding coordinate transformation is
% inverse to an active rotation.

%% Further Reading
%
% * <https://doi.org/10.1016/C2013-0-11769-2 Bunge, Texture Analysis in Materials Science> develops the mathematical foundations of ODFs and their representations.
% * <https://doi.org/10.1515/9783112736173 Matthies, Vinel, and Helming, Standard Distributions in Texture Analysis> is an atlas of cubic-orthorhombic model textures.
% * <https://doi.org/10.1063/1.1714396 Roe (1965)> gives the classical harmonic solution of the pole figure inversion problem.
% * <https://doi.org/10.1023/B:MATG.0000048799.56445.59 Kunze and Schaeben (2004)> develop quaternion Bingham distributions for texture analysis.

%% Next
%
% <ODFPlot.html Plotting an ODF> compares the views used to inspect these
% models. The model-family pages begin with <RadialODFs.html Radial ODFs>.
% <FibreODFs.html Fibre ODFs> and <BinghamODFs.html Bingham ODFs> cover the
% other shapes listed above.
% <RandomSampling.html Random Sampling> turns a model back into discrete
% orientations, while <ODFCharacteristics.html Properties> extracts the
% numbers that describe any ODF.

%#ok<*NASGU>
%#ok<*NOPTS>
