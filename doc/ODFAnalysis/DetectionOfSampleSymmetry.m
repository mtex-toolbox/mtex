%% Detection of Sample Symmetry
%
%%
% A rolled sheet is often modelled with orthotropic sample symmetry. In
% MTEX, |specimenSymmetry('222')| represents the three twofold rotations
% about rolling, transverse and normal direction. In conventional
% antipodal pole figures this is also seen as mirror symmetry about the
% specimen axes. A measurement rarely has the specimen mounted exactly in
% that frame; <SO3Fun.centerSpecimen.html |centerSpecimen|> finds the tilt.
%
%% A Synthetic Example
%
% Start from an ODF that really is orthotropic. Since it is a rolling type
% texture, work in the rolling frame.

specimenFrame.rolling.makeDefault
CS = crystalSymmetry('cubic');
SS = specimenSymmetry('222');

% some component center
ori = [orientation.byEuler(135*degree,45*degree,120*degree,CS,SS) ...
  orientation.byEuler( 60*degree, 54.73*degree, 45*degree,CS,SS) ...
  orientation.byEuler(70*degree,90*degree,45*degree,CS,SS)...
  orientation.byEuler(0*degree,0*degree,0*degree,CS,SS)];

% with corresponding weights
c = [.4,.13,.4,.07];

% the model odf
odf = unimodalODF(ori(:),'weights',c,'halfwidth',12*degree)

% plot some pole figures
h = [Miller(1,1,1,CS),Miller(2,0,0,CS),Miller(2,2,0,CS)];
plotPDF(odf,h,'antipodal','silent','complete','upper')

%%
% The pole figures are symmetric about the horizontal and the vertical
% axis, which is what orthotropic symmetry looks like.
%
%% A Rotated Measurement
%
% Now simulate a measurement of the same material with the specimen mounted
% slightly askew: draw orientations from the ODF, rotate them, and estimate
% an ODF back. The rotation destroys the symmetry with respect to x, y, z -
% not the symmetry itself, only its alignment.

rng(0)

% define a sample rotation
rot = rotation.byEuler(15*degree,12*degree,-5*degree);

% Simulate individual orientations and rotate them.
% The symmetry is no longer aligned with the coordinate axes.
ori = rot * discreteSample(odf,1000)

% estimate an ODF from the individual orientations
odf_est = calcDensity(ori,'halfwidth',10*degree)

% and visualize it
plotPDF(odf_est,h,'antipodal',8,'silent');

%%
% The reconstructed pole figures are still nearly orthotropic, but about
% tilted axes.
%
%% Recovering the Alignment
%
% <SO3Fun.centerSpecimen.html |centerSpecimen|> searches for the rotation
% that brings the symmetry axes back onto x, y and z. Its second argument
% is a starting direction for that search.

[odf_corrected,rot_inv] = centerSpecimen(odf_est);

plotPDF(odf_corrected,h,'antipodal',8,'silent')

% the difference between the applied rotation and the estimate rotation
angle(rot,inv(rot_inv)) / degree

%%
% The returned angle measures how closely the estimated correction recovers
% the applied rotation. It will not be exactly zero: 1000 sampled
% orientations and the subsequent smoothing introduce statistical error.


%% On Measured Pole Figure Data
%
% The same on real data, an ODF reconstructed from measured pole figures.

fname = fullfile(mtexDataPath,'PoleFigure','aachen_exp.EXP');
pf = PoleFigure.load(fname);

plot(pf,'silent')

%%
% Reconstruct the ODF, see <PoleFigure2ODF.html Reconstructing an ODF>.

odf = calcODF(pf,'silent')

plotPDF(odf,h,'antipodal','silent','noLabel','grid','on')

%%
% |centerSpecimen| also returns the symmetry axes it found, so they can be
% compared with the axes the specimen was supposed to have.

[~,~,a1,a2] = centerSpecimen(odf,vector3d.Y,'Fourier')

%%

a3 = cross(a1,a2)

%%
% Where these three sit relative to x, y and z is the mounting error of the
% experiment. Imposing an orthotropic
% <SpecimenSymmetry.html specimen symmetry> before correcting for it would
% average the texture over the wrong axes.

%% Next
%
% What specimen symmetry means, and when to impose one at all, is
% <SpecimenSymmetry.html Specimen Symmetry>.

%#ok<*NOPTS>

annotate([a1,a2,a3],'label',{'RD','TD','ND'},'backgroundcolor','w','MarkerSize',8)
