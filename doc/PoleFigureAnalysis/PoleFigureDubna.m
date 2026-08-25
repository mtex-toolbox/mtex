%% ODF Reconstruction - Dubna Example
%
%%
% This page runs one data set from the file on disk to a finished ODF,
% touching each of the steps the other pages of this chapter treat
% separately. The data are three neutron diffraction measurements of a
% quartz specimen, made at Dubna, and they carry the two complications that
% make quartz interesting: trigonal symmetry, and a measurement in which two
% reflections overlap.

plottingConvention.default('y↑→x');

% specify crystal and specimen symmetry
CS = crystalSymmetry('-3m',[4.9 4.9 5.4]);

% specify file names
fname = {...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-10)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(10-11)(01-11)_amp.cnv'),...
  fullfile(mtexDataPath,'PoleFigure','dubna','Q(11-22)_amp.cnv')};

% specify crystal directions
h = {Miller(1,0,-1,0,CS),...
     [Miller(0,1,-1,1,CS),Miller(1,0,-1,1,CS)],... % superposed pole figures
     Miller(1,1,-2,2,CS)};

% specify structure coefficients
c = {1,[0.52 ,1.23],1};

% import data
pf = PoleFigure.load(fname,h,CS,'interface','dubna','superposition',c);

plot(pf)
mtexColorbar

%%
% Note the second file. Its diffraction peak is the sum of two reflections,
% (01-11) and (10-11), which the diffractometer cannot separate, so the
% measured intensity is a weighted superposition of two pole figures. The
% weights are the structure coefficients |c|, and giving them at import is
% what lets the reconstruction use that measurement at all - see
% <PoleFigureImport.html Import> for how they are found.

%% Looking at the data first
%
% The contents of a pole figure object are reachable as ordinary arrays.

I = pf.intensities; % intensities
h = pf.h;           % Miller indices
r = pf.r;           % specimen directions

%%
% and a few statistics come with it. |isOutlier| marks measurements that
% disagree with their neighbourhood - see
% <PoleFigureCorrection.html Data Correction>.

min(pf)
max(pf)
isOutlier(pf);

%% Selecting and rotating
%
% Any condition on the specimen directions selects measurements. Diffraction
% at high tilt angles is unreliable, so a band of them is a natural thing to
% remove:

pf_modified = pf(pf.r.theta < 70*degree | pf.r.theta > 75*degree)

plot(pf_modified)

%%
% The two rings at 70 and 75 degrees are gone, leaving 1224 of the original
% 1368 directions per pole figure. A rotation of the whole
% measurement is equally cheap, if the specimen frame of the file is not the
% one the analysis should be in:

rot = rotation.byAxisAngle(xvector-yvector,25*degree);
pf_modified = rotate(pf,rot)

plot(pf_modified)

%% The reconstruction
%
% A coarse and fast setting, to see whether the data hold together at all:

rec = calcODF(pf,'RESOLUTION',10*degree,'iter_max',6)

%%
% The first check is always the recalculated pole figures against the
% measured ones above.

plotPDF(rec,pf.h)
mtexColorbar

%%
% The maxima are in the same places and of the same order, so nothing is
% badly wrong - which at 10 degrees and six iterations is all one should ask.
% <PoleFigure2ODF.html ODF Estimation> discusses what the resolution and the
% iteration count cost, and <PoleFigureRefinement.html the refinement page>
% what an adaptive kernel gains.

%% The full reconstruction
%
% With the defaults instead:

rec = calcODF(pf)

%%
% and its error against the data, one value per pole figure:

calcError(pf,rec)

%%
% Where the remaining misfit sits is the more useful question, and
% <PoleFigure.plotDiff.html |plotDiff|> answers it.

plotDiff(pf,rec)

%%
% The superposed measurement in the middle fits best, at 0.18, and the
% (10-10) worst, at 0.43. In all three the misfit is scattered rather than
% patchy - noise, not one bad region - but it grows towards the rim of the
% figures, which is the systematic part: those are the high tilt angles,
% where the defocusing correction is least reliable.

%% Exercises
%
% Working through these on the same data set covers the rest of the chapter:
%
% # inspect the raw pole figures - are there measurements you would not
% trust?
% # remove them, recompute the ODF and see how the errors of
% <PoleFigure.calcError.html |calcError|> change
% # recompute the ODF from fewer pole figures. How few still give a
% recognisable texture?
% # compare a reconstruction with and without
% <PoleFigure2ODFGhostCorrection.html ghost correction>. Which of the two
% fits the pole figures better, and what does that tell you?

%#ok<*NASGU>
