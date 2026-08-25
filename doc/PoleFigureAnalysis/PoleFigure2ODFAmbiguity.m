%% Ambiguity of the Pole Figure to ODF Reconstruction Problem
%
%%
% Reconstructing an ODF from pole figures does not have one answer. It has
% three separate reasons not to, and they are worth keeping apart because
% only one of them can be cured by measuring more:
%
% # too few pole figures - different ODFs can agree on the ones that were
% measured and differ on the ones that were not
% # Friedel's law - diffraction cannot tell a direction from its opposite,
% so the noncentrosymmetric part of a texture is not measured at all
% # the odd order harmonics - even a complete set of pole figures does not
% determine an ODF, and this is inherent in the relation between the two
%
% Each is demonstrated below, and the third one leads to the ghost effect
% and to the correction that carries its name.

%% Too few pole figures
%
% Experiments measure a handful of lattice planes. As a rule of thumb the
% number needed grows as the texture gets weaker and the crystal symmetry
% lower, and theory would want it to scale with the square root of the
% number of measured directions per pole figure - far beyond what any
% diffractometer does.
%
% What that costs is best seen on two ODFs built to be different. The first
% has three components, rotations by 90 degrees about the three coordinate
% axes:

plottingConvention.default('y↑→x');
cs = crystalSymmetry('mmm');

orix = orientation.byAxisAngle(xvector,90*degree,cs);
oriy = orientation.byAxisAngle(yvector,90*degree,cs);
oriz = orientation.byAxisAngle(zvector,90*degree,cs);

odf1 = unimodalODF([orix,oriy,oriz])

%%
% The second has three as well, rotations about (1,1,1) by 0, 120 and 240
% degrees:

ori = orientation.byAxisAngle(vector3d(1,1,1),[0,120,240]*degree,cs);
odf2 = unimodalODF(ori)

%%
% The two share no component at all, as their sigma sections show.

figure(1)
plot(odf1,'sigma')
mtexColorMap LaboTeX

figure(2)
plot(odf2,'sigma')
mtexColorMap LaboTeX

%%
% Yet seven of their pole figures are identical - (100), (010), (001),
% (110), (101), (011) and (111). The eighth drawn here, (120), is not, which
% is how one can tell them apart at all.

figure(1)
h = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{1,0,1},{0,1,1},{1,1,1},{1,2,0},cs);
plotPDF(odf1,h,'contourf')
mtexColorMap LaboTeX

figure(2)
plotPDF(odf2,h,'contourf')
mtexColorMap LaboTeX

%%
% So if only those seven were measured, no algorithm could decide which ODF
% produced them. The question worth asking is what MTEX returns in that
% situation.

% 1. step: simulate pole figure data
pf = calcPoleFigure(odf1,h(1:7),'upper');

plot(pf)

%%

% 2. step: reconstruct an ODF
odf = calcODF(pf,'silent')

plot(odf,'sigma')

%%
% A mixture of the two, and an even one: the reconstruction reaches 66 mrd
% at the components of |odf1| and 66 mrd at those of |odf2|, although only
% |odf1| was measured. Any mixture would have fitted the data equally well,
% and the one returned is the admissible ODF closest to uniform. That is a
% defensible choice and it is still not the true answer.
%
% Adding five more lattice planes to the measurement changes the picture.

% 1. step: simulate pole figure data for all crystal directions
h = [h,Miller({0,1,2},{2,0,1},{2,1,0},{0,2,1},{1,0,2},cs)];
pf = calcPoleFigure(odf1,h,'upper');

% 2. step: reconstruct an ODF
odf = calcODF(pf,'silent')

plot(odf,'sigma')

%%
% The components of |odf2| have not vanished, but they are down to 5 mrd
% against 129 for those of |odf1| - and the true ODF has 130 and 0. Five
% more lattice planes have very nearly resolved the ambiguity. This is the
% one of the three that more measurement cures.

%% Friedel's law
%
% A diffraction peak is the same for a lattice plane and for its opposite,
% so a measured pole figure is antipodally symmetric whether the crystal is
% or not. Take the point group -43m, which has no four fold axis, and two
% orientations that differ by 90 degrees about the third Euler axis:

cs = crystalSymmetry('-43m')

%%

ori1 = orientation.byEuler(30*degree,60*degree,10*degree,cs)

ori2 = orientation.byEuler(30*degree,60*degree,100*degree,cs)

h = Miller({1,0,0},{1,1,0},{1,1,1},{1,2,3},cs);
plotPDF(ori1,h,'MarkerSize',12)
hold on
plotPDF(ori2,'MarkerSize',8)
hold off

%%
% They are genuinely different orientations - the (111) pole figure puts
% their poles in different places. But in a measured pole figure, with
% antipodal symmetry imposed, every pole of the one falls on a pole of the
% other:

plotPDF(ori1,h,'MarkerSize',12,'antipodal')
hold on
plotPDF(ori2,'MarkerSize',8)
hold off

%%
% Imposing antipodal symmetry on all pole figures is the same as adding the
% inversion to the point group, that is, replacing it by its Laue group.
% Doing that explicitly gives the same picture:

ori1.CS= ori1.CS.Laue;
ori2.CS= ori2.CS.Laue;
h.CS = h.CS.Laue;

plotPDF(ori1,h,'MarkerSize',12)
hold on
plotPDF(ori2,'MarkerSize',8)
hold off

%%
% So an ODF reconstructed from diffraction pole figures is always
% centrosymmetric: its point group is a Laue group, and the
% noncentrosymmetric part of the texture is not lost by the algorithm but
% was never measured. No amount of extra pole figures recovers it. If the
% crystal's point group is already a Laue group - as it is for most
% materials one measures this way - Friedel's law costs nothing.

%% The odd order harmonics
%
% The third ambiguity survives even a complete set of pole figures and a
% centrosymmetric crystal. Consider triclinic symmetry and a weak unimodal
% ODF at the identity:

cs = crystalSymmetry('-1');

odf1 = 2/3 * uniformODF(cs) + 1/3 * unimodalODF(orientation.id(cs),'halfwidth',30*degree)

plotPDF(odf1,Miller({1,0,0},{0,1,0},{0,0,1},cs),'antipodal')

%%
% Written as a harmonic series it is the same function in another
% representation.

odf1 = FourierODF(odf1,10)

plotPDF(odf1,Miller({1,0,0},{0,1,0},{0,0,1},cs))

%%
% Its coefficients decay quickly, which is why cutting the series at degree
% 10 loses nothing here.

close all
plotSpektra(odf1,'linewidth',2)

%%
% Now build a second ODF that differs only in the odd order coefficients -
% all of them set to zero.

A = mod(1:11,2)';
odf2 = conv(odf1,A)

hold on
plotSpektra(odf2,'linewidth',2)

hold off
legend('odf1','odf2')

%%
% All pole figures of |odf2| are identical to those of |odf1|:

plotPDF(odf2,Miller({1,0,0},{0,1,0},{0,0,1},cs),'antipodal')

%%
% The odd order coefficients simply do not appear in a pole figure. Nothing
% in the data distinguishes the two functions, and they are not the same
% function - along the alpha fibre:

alphaFibre = orientation.byAxisAngle(zvector,(-180:180)*degree,cs);

close all
plot(-180:180,odf1.eval(alphaFibre),'linewidth',2)
hold on
plot(-180:180,odf2.eval(alphaFibre),'linewidth',2)
hold off
legend('odf1','odf2')
xlim([-180,180])

%%
% Flipping the sign of the odd coefficients instead of zeroing them makes
% the point sharper.

odf1 = 4/5 * uniformODF(cs) + 1/5 * unimodalODF(orientation.id(cs),'halfwidth',30*degree);

A = (-1).^(0:10)';
odf2 = conv(odf1,A);

close all
plot(-180:180,odf1.eval(alphaFibre),'linewidth',2)
hold on
plot(-180:180,odf2.eval(alphaFibre),'linewidth',2)
hold off
legend('odf1','odf2')
xlim([-180,180])

%%
% One ODF has a single preferred orientation at the identity; the other has
% preferred orientations at every 180 degree rotation. They have the same
% pole figures. No reconstruction method can prefer one over the other on
% the evidence.
%
% Matthies' way out is not mathematical but physical: a real texture is
% usually a uniform background plus a few components, so among all the ODFs
% that fit the data, prefer the one with the largest uniform portion. That
% is what ghost correction does, and MTEX applies it by default.

%% Ghost correction at work
%
% Simulating pole figures from the peaked ODF above:

h = Miller({1,0,0},{1,0,0},{0,1,0},{0,0,1},{1,1,0},{0,1,1},{1,0,1},{1,1,1},cs);
pf = calcPoleFigure(odf1,h);

plot(pf)

%%
% and reconstructing with the default, that is with ghost correction:

odf_rec1 = calcODF(pf,'silent')

%%
% and without:

odf_rec2 = calcODF(pf,'noGhostCorrection','silent')

%%
% Along the alpha fibre the corrected reconstruction recovers |odf1|
% closely, while the uncorrected one lands between |odf1| and |odf2| - a
% peak that is too low sitting on a background that is too high.

close all
plot(-180:180,odf_rec1.eval(alphaFibre),'linewidth',2)
hold on
plot(-180:180,odf_rec2.eval(alphaFibre),'linewidth',2)
hold off
legend('odf rec1','odf rec2')
xlim([-180,180])

%%
% The harmonic coefficients say the same thing in the language the problem
% lives in: without correction the recovered odd order coefficients are far
% too small.

close all
plotSpektra(odf1,'linewidth',2,'bandwidth',10)
hold on
plotSpektra(odf2,'linewidth',2)
plotSpektra(odf_rec1,'linewidth',2)
plotSpektra(odf_rec2,'linewidth',2)
hold off
legend('odf1','odf2','odf rec1','odf rec2')

%% The Santa Fe example
%
% Historically the ghost effect is tied to one model ODF, the Santa Fe
% standard.

odf = SantaFe;
plot(odf,'contourf')
mtexColorMap white2black

%%
% Simulate diffraction pole figures from it:

% crystal directions
h = Miller({1,0,0},{1,1,0},{1,1,1},{2,1,1},odf.CS);

% simulate pole figures
pf = calcPoleFigure(SantaFe,h,'antipodal');

% plot them
plot(pf,'MarkerSize',5)

%%
% and reconstruct twice.

% one with Ghost Correction
rec = calcODF(pf,'silent')

% one without Ghost Correction
rec2 = calcODF(pf,'NoGhostCorrection','silent')

%%
% Both reproduce the measured pole figures. This is the crux of the whole
% page: agreeing with the data is not evidence of being right.

figure(1)
plotPDF(rec,pf.h,'antipodal','complete','upper')
mtexColorMap parula

%%
figure(2)
plotPDF(rec2,pf.h,'antipodal','complete','upper')
mtexColorMap parula

%%
% The ODFs, however, differ - and the extra components in the second one are
% the ghosts.

close all
figure(1)
plot(rec,'gray','contourf')
mtexColorMap white2black

%%
figure(2)
plot(rec2,'gray','contourf')
mtexColorMap white2black

%%
% And once more the harmonic coefficients show where it comes from.

close all;
% the harmonic coefficients of the sample ODF
plotSpektra(SantaFe,'bandwidth',32,'linewidth',2,'MarkerSize',10)

% keep plot for adding the next plots
hold on

% the harmonic coefficients of the reconstruction with ghost correction:
plotSpektra(rec,'bandwidth',32,'linewidth',2,'MarkerSize',10)

% the harmonic coefficients of the reconstruction without ghost correction:
plotSpektra(rec2,'bandwidth',32,'linewidth',2,'MarkerSize',10)

legend({'true ODF','with ghost correction','without ghost correction'})
% next plot command overwrites plot
hold off

%%
% <PoleFigureSantaFe.html The Santa Fe example> works the same model
% through quantitatively, and
% <PoleFigure2ODFGhostCorrection.html Ghost Effect Analysis> measures what
% the correction buys on a weak texture.
