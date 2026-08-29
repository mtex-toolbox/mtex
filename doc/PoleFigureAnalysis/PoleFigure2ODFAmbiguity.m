%% Ambiguity of the Pole Figure to ODF Reconstruction Problem
%
%%
% A pole figure is a two-dimensional projection of an orientation
% distribution function (ODF). Reconstructing the three-dimensional ODF
% from those projections is therefore an inverse problem without a unique
% answer.
%
% This page assumes the definitions of an ODF and mrd from
% <ODFTheory.html ODF Theory>, and the projection developed in
% <ODFPoleFigure.html Pole Figures of an ODF>. The practical reconstruction
% workflow is introduced in <PoleFigure2ODF.html ODF Reconstruction>.
%
% Three sources of ambiguity must be kept apart because only the first can
% be reduced by measuring more:
%
% * too few pole figures - different ODFs can agree on the ones that were
% measured and differ on the ones that were not
% * Friedel's law - ordinary diffraction cannot tell a direction from its
% opposite,
% so the noncentrosymmetric part of a texture is not measured at all
% * odd-degree harmonics - even a complete set of antipodal pole figures
% leaves part of the ODF undetermined
%
% Friedel's law underlies the last two losses, but they appear differently.
% The first is a symmetry ambiguity, while the second is the null space of
% the pole-figure transform. The latter produces the ghost effect and
% motivates ghost correction.

%% Too few pole figures
%
% Experiments measure only a handful of lattice planes. The number needed
% generally grows as the texture becomes weaker and the crystal symmetry
% becomes lower. A classical sampling argument puts it on the order of the
% square root of the number of measured directions in each pole figure,
% which is far beyond routine measurements.
%
% What that costs is best seen on two ODFs built to be different. The first
% has three components, rotations by 90 degrees about the three coordinate
% axes:

plottingConvention.default('y↑→x');
cs = crystalSymmetry('mmm');

orix = orientation.byAxisAngle(xvector,90*degree,cs);
oriy = orientation.byAxisAngle(yvector,90*degree,cs);
oriz = orientation.byAxisAngle(zvector,90*degree,cs);

odf1 = unimodalODF([orix,oriy,oriz]);

%%
% The second has three as well, rotations about (1,1,1) by 0, 120 and 240
% degrees:

ori = orientation.byAxisAngle(vector3d(1,1,1),[0,120,240]*degree,cs);
odf2 = unimodalODF(ori);

%%
% The two share no component. Their sigma sections make the different peak
% positions visible.

figure(1)
plot(odf1,'sigma')
mtexColorMap LaboTeX

figure(2)
plot(odf2,'sigma')
mtexColorMap LaboTeX

%%
% Both textures put their bright peaks in the sigma = 0 and sigma = 90
% degree sections, but at different positions inside them: where one has a
% single peak at the centre, the other has four at the rim. This confirms
% that the two model textures have no common component.
%
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
% The first seven panels have the same maxima and contours in both figures.
% Only the (120) panel changes, at the lower right.
%
% So if only those seven were measured, no algorithm could decide which ODF
% produced them. The question worth asking is what MTEX returns in that
% situation.

% 1. step: simulate pole figure data
pf = calcPoleFigure(odf1,h(1:7),'upper');

plot(pf)

%%
% These seven simulated pole figures contain no panel that distinguishes
% the two model ODFs.

% reconstruct an ODF
odf = calcODF(pf,'silent');

plot(odf,'sigma')

% compare the mean density at the two sets of component orientations
densityAtModes7 = [mean(odf.eval([orix,oriy,oriz])), ...
  mean(odf.eval(ori))]

%%
% The two values printed above are the mean density at the components of
% |odf1| and |odf2|. Both are 66.1665 mrd, although only |odf1| generated
% the data. Any mixture would fit the seven pole figures equally well. MTEX
% returns an admissible ODF close to uniform, which is a defensible choice
% but still not the true answer.
%
% Adding five more lattice planes to the measurement changes the picture.

% 1. step: simulate pole figure data for all crystal directions
h = [h,Miller({0,1,2},{2,0,1},{2,1,0},{0,2,1},{1,0,2},cs)];
pf = calcPoleFigure(odf1,h,'upper');

% reconstruct an ODF
odf = calcODF(pf,'silent');

plot(odf,'sigma')

% compare reconstructed and true densities at both sets of modes
densityAtModes12 = [mean(odf.eval([orix,oriy,oriz])), ...
  mean(odf.eval(ori)),mean(odf1.eval([orix,oriy,oriz])), ...
  mean(odf1.eval(ori))]

%%
% The four values are the reconstructed densities at the |odf1| and |odf2|
% modes, followed by the two true densities. The unwanted modes fall from
% 66.1665 to 5.3985 mrd, while the wanted modes rise from 66.1665 to
% 128.4721 mrd. The true values are 129.6016 and 0 mrd. Five more lattice
% planes have nearly resolved this ambiguity. This is the one ambiguity
% that more measurement can cure.

%% Friedel's law
%
% Under Friedel's law, a diffraction peak is the same for a lattice plane
% and its opposite. An ordinary diffraction pole figure is therefore
% antipodally symmetric whether the crystal point group is or not.
%
% Consider point group -43m, which has no fourfold axis, and two
% orientations that differ by 90 degrees about the third Euler axis.

cs = crystalSymmetry('-43m');

%%

ori1 = orientation.byEuler(30*degree,60*degree,10*degree,cs);

ori2 = orientation.byEuler(30*degree,60*degree,100*degree,cs);

h = Miller({1,0,0},{1,1,0},{1,1,1},{1,2,3},cs);
plotPDF(ori1,h,'MarkerSize',12)
hold on
plotPDF(ori2,h,'MarkerSize',8)
hold off

%%
% The large and small markers do not coincide in the (111) and (123)
% panels. The two orientations are therefore distinct under -43m.
%
% Now impose antipodal symmetry, as ordinary diffraction does.

plotPDF(ori1,h,'MarkerSize',12,'antipodal')
hold on
plotPDF(ori2,h,'MarkerSize',8,'antipodal')
hold off

%%
% Every small marker now lies inside a large marker. The measurement cannot
% distinguish these orientations.
%
% Imposing antipodal symmetry on all pole figures is the same as adding the
% inversion to the point group, that is, replacing it by its Laue group.
% Doing that explicitly gives the same picture:

ori1.CS = ori1.CS.Laue;
ori2.CS = ori2.CS.Laue;
h.CS = h.CS.Laue;

plotPDF(ori1,h,'MarkerSize',12)
hold on
plotPDF(ori2,h,'MarkerSize',8)
hold off

%%
% The marker pairs still coincide, confirming the equivalence between
% antipodal pole figures and Laue symmetry.
%
% So an ODF reconstructed from diffraction pole figures is always
% centrosymmetric: its point group is a Laue group, and the
% noncentrosymmetric part of the texture is not lost by the algorithm but
% was never measured. No amount of additional ordinary pole figures
% recovers it. If the crystal point group is already a Laue group, as it is
% for most materials measured this way, this symmetry step costs nothing.
%
% This statement assumes ordinary kinematic diffraction. Anomalous or
% resonant scattering can distinguish opposite directions and has been used
% to determine the odd part of a texture.

%% The odd order harmonics
%
% The third ambiguity survives even a complete set of pole figures and a
% centrosymmetric crystal. Consider triclinic symmetry and a weak unimodal
% ODF at the identity:

cs = crystalSymmetry('-1');

odf1 = 2/3 * uniformODF(cs) + 1/3 * ...
  unimodalODF(orientation.id(cs),'halfwidth',30*degree);

plotPDF(odf1,Miller({1,0,0},{0,1,0},{0,0,1},cs),'antipodal')

%%
% The three pole figures contain broad, weak maxima. They are the complete
% diffraction data used for the harmonic comparison below.
%
% Written as a harmonic series it is the same function in another
% representation.

odf1 = FourierODF(odf1,10);

plotPDF(odf1,Miller({1,0,0},{0,1,0},{0,0,1},cs))

%%
% The pole figures are unchanged by converting the representation.
%
% Its coefficients decay quickly, which is why cutting the series at degree
% 10 loses nothing here.

close all
plotSpektra(odf1,'linewidth',2)

%%
% The spectrum falls rapidly towards zero by degree 10.
%
% Now build a second ODF that differs only in the odd order coefficients -
% all of them set to zero.

A = mod(1:11,2)';
odf2 = conv(odf1,A);

hold on
plotSpektra(odf2,'linewidth',2)

hold off
legend('odf1','odf2')

%%
% The second spectrum agrees at every even degree and is zero at every odd
% degree. Nevertheless, all pole figures of |odf2| are identical to those
% of |odf1|:

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
% The two curves differ along the fibre even though their pole figures do
% not. Setting the odd degrees to zero has changed the ODF, not merely its
% representation.
%
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
% Matthies' way out is a physical prior, not additional information in the
% data. A real texture is usually a uniform background plus a few
% components. Among the ODFs that fit the data, ghost correction therefore
% prefers the one with the largest uniform portion. MTEX applies this
% correction by default.

%% Ghost correction at work
%
% Simulate seven distinct pole figures from the peaked ODF above.

h = Miller({1,0,0},{0,1,0},{0,0,1},{1,1,0},{0,1,1},{1,0,1}, ...
  {1,1,1},cs);
pf = calcPoleFigure(odf1,h);

plot(pf)

%%
% These smooth pole figures constrain the even-degree coefficients but
% contain no direct evidence for the missing odd degrees.
%
% Reconstruct with the default, which includes ghost correction.

odf_rec1 = calcODF(pf,'silent');

%%
% Reconstruct once more without ghost correction.

odf_rec2 = calcODF(pf,'noGhostCorrection','silent');

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
% The harmonic coefficients say the same thing in the natural language of
% the problem. Without correction, the recovered odd-degree coefficients
% are far too small.

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
% Historically, the ghost effect is tied to the Santa Fe model ODF. This
% standard texture gives different inversion programs the same known truth
% to reconstruct.

odf = SantaFe;
plot(odf,'contourf')
mtexColorMap white2black

%%
% The sections show several broad components on a nonzero background. That
% combination makes the model sensitive to an incorrect uniform portion.
%
% Simulate diffraction pole figures from it:

% crystal directions
h = Miller({1,0,0},{1,1,0},{1,1,1},{2,1,1},odf.CS);

% simulate pole figures
pf = calcPoleFigure(SantaFe,h,'antipodal');

% plot them
plot(pf,'MarkerSize',5)

%%
% The four pole figures contain the projections that both reconstructions
% below must reproduce.
%
% Reconstruct twice.

% one with ghost correction
rec = calcODF(pf,'silent');

% one without ghost correction
rec2 = calcODF(pf,'noGhostCorrection','silent');

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
% The same maxima and contour shapes appear in both sets of recalculated
% pole figures. Agreement with the measured projections does not select the
% correct ODF.
%
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
% Extra maxima appear in the uncorrected sections even though they did not
% spoil the pole-figure fit. Once more, the harmonic coefficients show
% where they come from.

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
% Cubic crystal and orthorhombic sample symmetry leave degree 9 as the only
% odd degree with weight here, and that is where the three curves part: the
% true value 0.29 is met by the corrected reconstruction and missed by the
% uncorrected one, which reaches 0.10. Every even degree is reproduced
% either way. Ghost correction has selected a physically
% plausible member of the solution family; it has not created new measured
% information.

%% Further reading
%
% * R.-J. Roe,
% <https://doi.org/10.1063/1.1714396 Description of crystallite orientation
% in polycrystalline materials. III. General solution to pole figure
% inversion>, _Journal of Applied Physics_ 36, 2024-2031, 1965. This is the
% classical harmonic solution and its ambiguity.
% * S. Matthies and G. W. Vinel,
% <https://doi.org/10.1002/pssb.2221120254 On the reproduction of the
% orientation distribution function of texturized samples from reduced pole
% figures using the conception of a conditional ghost correction>,
% _physica status solidi (b)_ 112, K111-K114, 1982. This introduces the
% conditional ghost correction used by MTEX.
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A novel pole figure inversion
% method: specification of the MTEX algorithm>, _Journal of Applied
% Crystallography_ 41, 1024-1037, 2008. This specifies the component method
% implemented by <PoleFigure.calcODF.html |calcODF|>.
% * H.-J. Bunge and C. Esling,
% <https://doi.org/10.1107/S0021889881009308 Determination of the odd part
% of the texture function by anomalous scattering>, _Journal of Applied
% Crystallography_ 14, 253-255, 1981. This explains the experimental
% exception to the ordinary Friedel limitation.

%% Next
%
% <PoleFigure2ODFGhostCorrection.html Ghost Effect Analysis> quantifies what
% the correction buys on a deliberately weak texture.
% <PoleFigureSantaFe.html The Santa Fe Example> then adds counting noise and
% compares both reconstructions with the known model.
