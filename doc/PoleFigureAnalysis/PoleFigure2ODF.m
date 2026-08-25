%% ODF Estimation from Pole Figure Data
%
%%
% A pole figure does not measure orientations. Each of its values is a sum
% over all the orientations that put one lattice plane in one specimen
% direction - a whole one dimensional family of them - so a single pole
% figure cannot be inverted at all, and several of them determine the
% orientation distribution only up to what the measurement cannot see.
% Reconstruction is therefore an inverse problem: find an ODF whose
% recalculated pole figures match the measured ones, knowing that more than
% one will.
%
% This page is about doing that with <PoleFigure.calcODF.html |calcODF|>,
% and about checking the result. What the ambiguity costs, and what can be
% done about it, is the subject of
% <PoleFigure2ODFAmbiguity.html The Ghost Effect>.

plottingConvention.default("y↑→x");
mtexdata dubna

%%
% Seven pole figures of a quartz specimen, measured by neutron diffraction.
% See <PoleFigureImport.html Import> for how such data get into MTEX.

% plot pole figures
plot(pf)

%% The reconstruction
%
% With no options at all:

odf = calcODF(pf)

%%
% The table above the result is the iteration history. |calcODF| solves for
% the weights of some tens of thousands of unimodal components, and each row
% reports, for one step, the RP error of every pole figure - seven columns
% for seven measurements. They fall from 0.9 to between 0.2 and 0.6, and the
% iteration stops when they stop falling.
%
% The result is an <SO3FunRBF.SO3FunRBF.html |SO3FunRBF|>, a superposition
% of those components, which behaves like any other ODF - see
% <ODFAnalysis.html ODF Analysis>.

%% Does it reproduce the data
%
% The first check is to recalculate the pole figures that were measured and
% compare them by eye with the ones above.

plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)

%%
% The maxima sit in the same places and reach comparable heights, which is
% what one wants to see. The recalculated figures are smoother than the
% measured ones, since the noise of the measurement is not in the ODF.
%
% <PoleFigure.calcError.html |calcError|> puts numbers on the same
% comparison, one per pole figure. Three measures are available, |'RP'|,
% |'l1'| and |'l2'|:

calcError(pf,odf,'RP')

%%
% The values run from 0.36 to 0.86 across the seven pole figures. Note what
% RP is: the mean absolute difference divided by the recalculated intensity,
% so it is a relative error, and the weak parts of a pole figure - where a
% small absolute difference is a large relative one - dominate it. That one
% pole figure scores twice another says less about the reconstruction than
% it appears to.
%
% Where the misfit sits is more informative than how large it is.
% <PoleFigure.plotDiff.html |plotDiff|> draws the difference between the
% measured and the recalculated intensities, pole figure by pole figure.

plotDiff(pf,odf)

%%
% A misfit spread evenly over a pole figure is noise. A misfit concentrated
% in one region is a systematic problem - a defocusing correction that was
% not applied, a background that was, or a pole figure that does not belong
% with the others.

%% Comparing two ODFs
%
% The same |calcError| compares two ODFs rather than an ODF and a
% measurement. Here we build a single unimodal component at the strongest
% orientation of the reconstruction and ask how far the two are apart.

% define a unimodal ODF with the same preferred orientation
[~,ori_pref] = max(odf);
odf_model = unimodalODF(ori_pref,'halfwidth',15*degree)

% plot the pole figures
plotPDF(odf_model,pf.allH,'antipodal','superposition',pf.c)

% compute the difference
calcError(odf_model,odf)

%%
% Its pole figures show the same maxima and nothing else. The difference is
% large, as it should be: the model keeps one component of a texture that
% has several.

%% Discretization
%
% The ODF is built as a superposition of unimodal components sitting on a
% grid in orientation space. By default that grid has 1.5 times the
% resolution of the pole figure measurements, and each component is a de la
% Vallee Poussin kernel of the same halfwidth as the grid spacing.
%
% A coarser grid gives a smoother ODF and a faster reconstruction:

odf = calcODF(pf,'resolution',15*degree)
plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)

%%
% Much faster - a tenth of a second against nearly two - and much blunter:
% the ODF now peaks at 27 mrd where the default reached 94, and the mean RP
% error rises from 0.59 to 0.75. A coarse grid cannot represent a sharp
% texture. Going the other way costs time and, past the resolution of the
% data, invents detail.
%
% Two further options control the same thing from the other end:
% |'kernel'| takes a kernel function outright, |'halfwidth'| keeps the
% default kernel and sets its width.

%% The zero range method
%
% Where a pole figure is zero, every orientation contributing to it must be
% zero too. That is a strong constraint, and for a sharp texture with large
% empty regions it removes most of the orientation space from the problem -
% which makes the reconstruction both faster and finer.

odf = calcODF(pf,'zero_range')
plotPDF(odf,pf.allH,'antipodal','silent','superposition',pf.c)

%%
% On this data set it changes nothing at all: the same 94 mrd, the same
% errors, the same running time. Sharp as this quartz texture is, its
% measured pole figures never drop close enough to zero for the constraint
% to take hold. It is worth trying rather than assuming, and
% <zeroRangeMethod.zeroRangeMethod.html |zeroRangeMethod|> documents the
% threshold that decides what counts as zero.

%% Ghost correction
%
% The odd order harmonics of an ODF do not appear in its pole figures at
% all, so nothing in the data determines them. Setting them to zero produces
% a characteristic artefact - a raised uniform background with a
% correspondingly weakened texture, the *ghost effect*.
% <PoleFigure2ODFGhostCorrection.html Ghost correction> is Matthies'
% remedy, and it matters most for weak textures.
% <PoleFigureSantaFe.html The Santa Fe example> measures how much it buys on
% a model ODF where the true answer is known.

%% The maths behind this
%
% |calcODF| minimises a modified least squares functional over the weights
% of the components:
%
% $$f_{est} = argmin \sum_{i=1}^N \sum_{j=1}^{N_i}\frac{|\alpha_i R f(h_i,r_{ij}) - I_{ij})|^2}{I_{ij}  }$$
%
% The division by $I_{ij}$ is what makes it *modified*: it weights each
% measurement by its own intensity, so that a bright point is not allowed to
% dominate a dark one. $\alpha_i$ absorbs the unknown scale of each pole
% figure, which is why unnormalized data can be used.
%
% A precise description of the estimator and the algorithm is in the paper
% _Pole Figure Inversion - The MTEX Algorithm_.

%#ok<*NOPTS>
