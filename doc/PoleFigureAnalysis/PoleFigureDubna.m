%% Reconstructing the Dubna Quartz ODF
%
%%
% This page follows a three-file subset of the seven bundled Dubna pole
% figures from their files to a reconstructed orientation distribution
% function (ODF), then checks its fit. Florian Wobbe measured the quartz
% specimen at Dubna in 2005 using neutron diffraction, as recorded in the
% <https://mtex-toolbox.github.io/HomepageOld/files/doc/dubna_demo.html
% original MTEX Dubna example>.
%
% The example brings together the import, inspection, reconstruction, and
% validation steps developed earlier in this chapter. It assumes the
% pole-figure idea from <PoleFigureAnalysis.html Pole Figures>, the import
% model from <PoleFigureImport.html Import>, and the inversion workflow from
% <PoleFigure2ODF.html ODF Reconstruction>. The origin of the ghost effect is
% explained in <PoleFigure2ODFAmbiguity.html The Ghost Effect>.
%
% A plotting convention states how the specimen reference frame is drawn.
% This data set uses Y upward and X to the right. The convention does not
% rotate the specimen directions or change their intensities.

plottingConvention.default('y↑→x');

%% Import the three measurements
%
% Quartz is trigonal. The lattice parameters below define its crystal frame
% as well as the metric used to interpret the four-index notation introduced
% in <CrystalDirections.html Miller Indices>.

CS = crystalSymmetry('-3m',[4.9 4.9 5.4]);

fname = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-22)_amp.cnv')};

% crystal-plane normals, one cell per measured file
h = {Miller(1,0,-1,0,CS),...
  [Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],...
  Miller(1,1,-2,2,CS)};

% relative structure coefficients, in the same order as h
c = {1,[0.52,1.23],1};

%%
% The second diffraction peak contains the unresolved $(01\bar{1}1)$ and
% $(10\bar{1}1)$ reflections. Its measured intensity is therefore a
% weighted superposition of two pole figures, not a fourth measurement.
% Passing |c| at import makes that same weighted sum part of the forward
% model used during reconstruction. See <PoleFigureImport.html Import> for
% how the structure coefficients are found.

pf = PoleFigure.load(fname,h,CS,'interface','dubna','superposition',c)

%%
% The summary reports three entries on identical $72 \times 19$ direction
% grids. The double Miller label on the second entry confirms that its two
% reflections have not been mistaken for separate measurements.

plot(pf)
mtexColorbar('title','intensity')

%%
% The three panels contain sharp maxima in different specimen directions.
% The second panel has a much larger raw intensity range, which is why the
% solver estimates one scale factor per pole figure. These counts are not
% yet pole densities in multiples of a random distribution (mrd); see
% <ODFTheory.html ODF Theory>.

%% Inspect the stored data
%
% The object exposes the measured intensities, crystal-plane normals, and
% specimen directions as ordinary arrays. Different pole figures can use
% different direction grids, so <PoleFigure.PoleFigure.html |PoleFigure|>
% also provides the cell-valued properties |allI|, |allH|, and |allR|.

I = pf.intensities;
latticeDirections = pf.h;
specimenDirections = pf.r;

%%
% Minimum and maximum intensities give a first scale check. The rows follow
% the three entries in the object summary above.

poleFigureLabel = {'(10-10)';'(01-11)+(10-11)';'(11-22)'};
intensitySummary = table(min(pf).',max(pf).',...
  'VariableNames',{'minimum','maximum'},'RowNames',poleFigureLabel)

%%
% <PoleFigure.isOutlier.html |isOutlier|> compares every measurement with
% its neighbourhood. Use it to create a mask for inspection:
%
%   outlierMask = isOutlier(pf);
%
% A flag is a prompt to inspect the experiment, not permission to delete a
% value automatically. Background, defocusing, normalization, and an
% executable outlier example are in
% <PoleFigureCorrection.html Data Correction>.

%% Select a diagnostic band
%
% High-tilt measurements are especially vulnerable to defocusing. The next
% condition demonstrates indexed selection by removing only the two rings
% from 70 through 75 degrees. It deliberately retains directions above 75
% degrees, so it is not a recommended high-tilt correction.

keep = pf.r.theta < 70*degree | pf.r.theta > 75*degree;
pf_bandRemoved = pf(keep)

plot(pf_bandRemoved)
mtexColorbar('title','intensity')

%%
% The blank band is the direct visual consequence of the selection. Each
% entry now contains 1224 of its original 1368 specimen directions.

%% Rotate the measured directions
%
% <PoleFigure.rotate.html |rotate|> actively moves every measured specimen
% direction while leaving its intensity unchanged. This is not a frame
% change and not a plotting convention. If import assigned the wrong
% specimen reference frame, correct the import whenever possible.

rot = rotation.byAxisAngle(xvector-yvector,25*degree);
pf_rotated = rotate(pf,rot);

plot(pf_rotated)
mtexColorbar('title','intensity')

%%
% All three intensity patterns turn together relative to the plotted axes.
% Their values and the number of sampled directions do not change.

%% Make a coarse reconstruction
%
% A 10 degree orientation grid and at most six solver iterations provide a
% quick consistency check.

recCoarse = calcODF(pf,'resolution',10*degree,'iterMax',6)

%%
% The first check is always the recalculated pole figures against the
% measured ones above. Recalculate exactly the three measured entities. The
% |'superposition'| option combines the two unresolved reflections with
% their imported structure coefficients instead of drawing them as separate
% pole figures.

plotPDF(recCoarse,pf.allH,'antipodal','silent',...
  'superposition',pf.c)
mtexColorbar('title','mrd')

%%
% The broad maxima occupy the same regions as in the measured panels and
% have the same relative order. At this coarse resolution that agreement is
% only a screening result, not evidence that the recovered ODF is unique.
% <PoleFigure2ODF.html ODF Reconstruction> explains the cost of resolution
% and iteration count. <PoleFigureRefinement.html Iterative ODF
% Reconstruction> shows what successively narrowing the kernel can gain.

%% Reconstruct at the default resolution
%
% The final reconstruction uses the default orientation grid and kernel.
% Its iteration trace is suppressed because
% <PoleFigure2ODF.html ODF Reconstruction> explains that output in detail.

rec = calcODF(pf,'silent');

%%
% <PoleFigure.calcError.html |calcError|> returns one regularised relative
% residual per measured pole figure. Label the values so the superposed
% measurement remains identifiable.

regularisedRelativeResidual = calcError(pf,rec,'silent').';
fitSummary = table(regularisedRelativeResidual,...
  'RowNames',poleFigureLabel)

%%
% The superposed measurement in the middle fits best, at 0.18, and the
% $(10\bar{1}0)$ measurement fits worst, at 0.43. A smaller residual means a
% better match to the measured projection. It does not prove that the ODF
% itself is unique or true.

%% Locate the remaining mismatch
%
% <PoleFigure.plotDiff.html |plotDiff|> shows the same regularised relative
% residual at every measured direction.

plotDiff(pf,rec,'silent')
mtexColorbar('title','relative residual')

%%
% The mismatch is scattered rather than concentrated in one patch, which
% is consistent with measurement noise. It also grows towards the rim,
% where the high specimen tilt makes defocusing correction least reliable.
% Both patterns are diagnostic clues, not proof of a single cause.

%% Exercises
%
% Working through these on the same data set covers the rest of the chapter:
%
% # inspect the raw pole figures and identify measurements you would not
% trust;
% # remove only values for which you have a physical reason, reconstruct the
% ODF, and compare the <PoleFigure.calcError.html |calcError|> values;
% # reconstruct from fewer pole figures and find the smallest set that still
% gives a recognisable texture; and
% # compare reconstructions with and without
% <PoleFigure2ODFGhostCorrection.html ghost correction>. Which fits the pole
% figures better, and why does that comparison not identify the true ODF?

%% Further reading
%
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A novel pole figure inversion
% method: specification of the MTEX algorithm>, _Journal of Applied
% Crystallography_ 41, 1024--1037, 2008. This specifies the estimator and
% numerical reconstruction used here.
% * S. Matthies, H.-R. Wenk and G. W. Vinel,
% <https://doi.org/10.1107/S0021889888000275 Some basic concepts of texture
% analysis and comparison of three methods to calculate orientation
% distributions from pole figures>, _Journal of Applied Crystallography_
% 21, 285--304, 1988. It motivates using both integral errors and difference
% pole figures to assess an inversion.
% * K. Ullemeyer et al.,
% <https://doi.org/10.23689/fidgeo-1862 Neutron time-of-flight texture
% measurements in Dubna: status and developments>, in _11. Symposium
% Tektonik, Struktur- und Kristallgeologie_, 2006. It describes the SKAT
% instrument and why time-of-flight diffraction records several pole
% figures from bulk geological samples.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, English ed., 1982. This is
% the standard textbook treatment of pole figures and ODF reconstruction.

%% Next
%
% <PoleFigureExport.html Export> shows how to write measured and
% recalculated pole figures. Continue to <ODFAnalysis.html ODF Analysis> to
% quantify the assessed ODF and derive texture characteristics from it.

%#ok<*NASGU>
