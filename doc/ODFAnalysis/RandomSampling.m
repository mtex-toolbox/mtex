%% Random Sampling
%
%% 
% Assume an arbitrary <ODFTheorie.html ODF> either from texture modeling
% or recovered from XRD pole figure measurements a common problem is the
% simulation of random individual orientations that are distributed
% according the given ODF. This is helpful crucial in many application,
% e.g., for running plastic deformation models like VPSC or verifying the
% accuracy <DensityEstimation.html density estimation methods>. Here we
% start with a trigonal alpha-fibre ODF which we define by

cs = crystalSymmetry('32');
fibre_odf = 0.5*uniformODF(cs) + 0.5*fibreODF(fibre.rand(cs),'halfwidth',20*degree);

plot(fibre_odf,'sections',6,'silent')
mtexColorbar

%% Computing Random Orientations
%
% In order to compute $4000$ random orientations from the ODF |fibre_odf|
% we use the command |<SO3Fun.discreteSample.html discreteSample>|.

ori = fibre_odf.discreteSample(4000)

% plot the orientations into the Bunge sections
hold on
plot(ori,'MarkerFaceColor','none','all','MarkerEdgeColor','k','MarkerSize',4)
hold off

%%
% From the above plot it is very hard to judge whether the orientations are
% indeed distributed according to the given ODF. The reason for this is the
% not volume preserving projection of the Bunge sections. A better ODF
% representation for this purpose are <SigmaSections.html sigma sections>

% plot the ODF in sigma sections
plot(fibre_odf,'sections',6,'silent','sigma','contour','linewidth',2)

% plot the orientations into the sigma sections
hold on
plot(ori,'MarkerFaceColor','none','all','MarkerEdgeColor','k','MarkerSize',4)
hold off

%% ODF Estimation from Random Orientations
%
% From the last plot we clearly see that the orientations are more dense
% close to the alpha fibre. In order more quantitative measure for how well
% do the orientations approximate the ODF we may use the orientations to
% <DensityEstimation.html estimate a new ODF> and compare the fit of this
% estimate ODF with the initial ODF.

% estimate an ODF from the random orientations
odf_rec = calcDensity(ori,'halfwidth',15*degree);

% plot the estimated ODF
plot(odf_rec,'sections',6,'silent')
mtexColorbar

%%
% We may now compare the original model ODF |fibre_odf| with the
% reconstructed ODF |odf_rec|. 

calcError(odf_rec,fibre_odf)

%% Optimal Sample
%
% The command |discreteSample| computes the orientations completely at
% random. This is perfect if you want to statistically simulate different
% measurement procedures and estimate the accuracy of your computations,
% e.g. in a bootstrapping approach. However, if you are interested in
% orientations that reproduce your density function with the smallest error
% you are better off with the command <SO3Fun.optimalSample.html
% |odf.optimalSample(n)|>. This function optimizes the sampled orientation
% to be as representative for the ODF as possible. Lets verify this by
% comparing the error with respect to the original model ODF.

ori = fibre_odf.optimalSample(4000)

odf_rec = calcDensity(ori,'halfwidth',15*degree);

calcError(odf_rec,fibre_odf)

%% Exporting Random Orientations
%
% In order to make use of the sampled orientations you probably want to
% <OrientationExport.html export> them as <RotationDefinition.html Euler
% angles> into a text files. This can be done using the commands
% |<quaternion.export.html export>| and |<orientation.export_VPSC.html
% export_VPSC>|.
