%% ODF Modeling
%
%%
% An ODF does not have to come from a measurement. A *model ODF* is built
% from a few numbers - a preferred orientation and a spread, a fibre, a
% mixture - and it serves three purposes: as a reference to compare a
% measured texture against, as a starting point for simulating how a texture
% evolves, and as a way of generating test data with a known answer.
%
% Every ODF in MTEX is an <SO3FunConcept.html |@SO3Fun|>, a function on the
% rotation group, and the model ones differ only in how that function is
% represented:
%
% || <RadialODFs.html uniform> || constant, the untextured reference ||
% || <RadialODFs.html unimodal> || a peak of given halfwidth about one orientation ||
% || <RadialODFs.html multimodal> || several such peaks ||
% || <FibreODFs.html fibre> || a peak spread along a curve in orientation space ||
% || <BinghamODFs.html Bingham> || a peak with three different widths ||
% || <SO3FunHarmonicRepresentation.html harmonic> || a series expansion, the form pole figure inversion produces ||
%
% They are freely mixed, because ODFs can be scaled and added.

plottingConvention.default('y↑→x');

%% The Uniform ODF
%
% The simplest model is the constant one,
%
% $$f(g) = 1,\quad  g \in SO(3),$$
%
% which needs nothing but the two symmetries.

cs = crystalSymmetry('cubic');
ss = specimenSymmetry('orthorhombic');

odf = uniformODF(cs,ss)

%%
% It is the texture a specimen has when it has no texture, and the reference
% every mrd value is measured against.

%% A Single Component
%
% A unimodal ODF is a peak about one orientation, with a shape given by a
% <SO3Kernels.html kernel> and a width given by its halfwidth.

psi = SO3vonMisesFisherKernel('halfwidth',10*degree);

mod1 = orientation.byMiller([1,2,2],[2,2,1],cs,ss);

odf1 = unimodalODF(mod1,psi)

%%
% Its maximum sits where the component does, and the value there says how
% concentrated the peak is - a narrower halfwidth means a higher maximum,
% since the total is fixed at a mean of one.

max(odf1)

%% Mixtures
%
% ODFs are added and scaled like functions, so a texture with a background
% is a weighted sum. The classical Santa Fe example is 27 percent of the
% component above on top of a uniform background.

odf = 0.73 * uniformODF(cs,ss) + 0.27 * unimodalODF(mod1,psi)

%%
% The mean is still 1 - the weights are volume fractions and have to add up
% to one because both component ODFs are individually normalized. The two
% peaks may overlap in orientation space; the coefficients still describe
% the fractions assigned to the two terms of the mixture, not disjoint
% regions cut out around their maxima.

mean(odf)

%%

close all
plotPDF(odf,[Miller(1,0,0,cs),Miller(1,1,0,cs)],'antipodal')

%%
% Against the uniform background, the component shows as the discrete spots.
% This is the ODF that pole figure inversion is usually tested on: the
% answer is known, so a reconstruction can be scored against it, see
% <PoleFigure2ODF.html Reconstructing an ODF>.

%% Rotating a Model
%
% A model built in one frame is moved to another by rotating it, which is
% how a component is placed relative to the specimen axes.

odfRot = rotate(odf,rotation.byAxisAngle(vector3d.Z,30*degree));

plotPDF(odfRot,Miller(1,0,0,cs),'antipodal')

%%
% The pole-figure pattern turns by $30^\circ$ about the centre because the
% rotation is applied on the specimen side of every component orientation.
% The original |mmm| specimen symmetry was tied to x, y and z, so it is no
% longer a coordinate-aligned specimen symmetry after this rotation and
% MTEX drops that label with a warning. The physical twofold axes have
% rotated with the texture. A passive change of coordinate frame instead
% requires the corresponding inverse transformation.

%% Next
%
% The individual model types have pages of their own, starting with
% <RadialODFs.html Radial ODFs>. What such a model looks like once it is
% sampled back into discrete orientations is
% <RandomSampling.html Random Sampling>, and the numbers that describe any
% ODF are <ODFCharacteristics.html Properties>.

%#ok<*NASGU>
%#ok<*NOPTS>
