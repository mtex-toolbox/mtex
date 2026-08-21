%% Random Sampling
%
%%
% Assume an arbitrary <ODFTheory.html ODF> either from texture modeling
% or recovered from XRD pole figure measurements a common problem is the
% simulation of random individual orientations that are distributed
% according the given ODF. This is helpful crucial in many application,
% e.g., for running plastic deformation models like VPSC or verifying the
% accuracy <DensityEstimation.html density estimation methods>. Here we
% start with a trigonal alpha-fibre ODF which we define by

% fix the random seed, so that the numbers quoted on this page are reproducible
rng(0)

cs = crystalSymmetry('32');
fibre_odf = 0.5*uniformODF(cs) + 0.5*fibreODF(fibre.rand(cs),'halfwidth',20*degree);

%% Computing Random Orientations
%
% In order to compute $500$ random orientations from the ODF |fibre_odf|
% we use the command |<SO3Fun.discreteSample.html discreteSample>|.

ori = fibre_odf.discreteSample(500)

% plot the odf in Bunge sections
plot(fibre_odf,'sections',6,'silent')
mtexColorbar

% and plot the orientations on top of them
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
odf_rec = calcDensity(ori,'halfwidth',10*degree);

% plot the estimated ODF
plot(odf_rec,'sigma','silent')
mtexColorbar

% the error between the true and the reconstructed ODF
disp("difference between original and reconstructed ODF: " + calcError(odf_rec,fibre_odf))

%%
% Clearly, a halfwidth of 10 degree it too small for only 500 random
% orientations. Let's increase the halfwidth as long as the error between
% the reconstructed ODF and the true ODF descents.

% estimate an ODF from the random orientations
odf_rec = calcDensity(ori,'halfwidth',20*degree);

% plot the estimated ODF
plot(odf_rec,'sigma','silent')
mtexColorbar

disp("difference between original and reconstructed ODF: " + calcError(odf_rec,fibre_odf))

%%
% With halfwidth 20 degree the estimated ODF is much closer to the original
% ODF and does not show the random oscillation or the 10 degree estimate.
% The price we have to pay is that the reconstructed ODF is now much weaker
% than the true ODF. More precisely the texture index drops as 

disp("Texture index original ODF: " + norm(fibre_odf)^2)
disp("Texture index reconstructed ODF: " + norm(odf_rec)^2)

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

ori = fibre_odf.optimalSample(500)

%%
% Lets reconstruct the ODF with the small halfwidth 10 degree

odf_rec = calcDensity(ori,'halfwidth',10*degree);

plot(odf_rec,'sigma','silent')
mtexColorbar

disp("difference between original and reconstructed ODF: " + calcError(odf_rec,fibre_odf))

%%
% We visually observe a much butter reconstruction and also the error
% between the reconstructed and original ODF dropped by 50 percent.
% Finally, we have a look at the texture index.

disp("Texture index original ODF: " + norm(fibre_odf)^2)
disp("Texture index reconstructed ODF: " + norm(odf_rec)^2)

%%
% By default all sampled orientations carry the same weight. Asking
% |optimalSample| for a second output
%
%   [ori,c] = odf.optimalSample(500)
%
% optimizes the weights alongside the orientations, i.e. the ODF is
% represented by a weighted sum of point masses. Since this adds one degree of
% freedom per orientation, fewer orientations are needed for the same
% accuracy. The weights are volume fractions and are passed on directly by
% |calcDensity(ori,'weights',c)|. Whether they pay off depends on the
% halfwidth you intend to use - see <SO3Fun.optimalSample.html
% |optimalSample|> for the details.

%% The Optimal Halfwidth as a Function of the Sample Size
%
% All comparisons so far were made at one fixed sample size and one fixed
% halfwidth. Both samplers, however, ask for a different halfwidth, and the
% right halfwidth shrinks as the sample grows. In order to compare the two
% samplers fairly we therefore tune the halfwidth individually for every
% single sample, i.e. we give each sample the kernel it likes best, and only
% then compare the errors.

% the harmonic representation makes the L2 error below cheap to evaluate
odfH = SO3FunHarmonic(fibre_odf);

M = 2.^(5:9);  % 32, 64, ... 512 orientations
nRep = 5;      % repetitions, the random sample differs from run to run

hwRand = zeros(length(M),nRep); eRand = hwRand;
hwOpt = zeros(length(M),1); eOpt = hwOpt;

for i = 1:length(M)

  % the random sample, repeated a couple of times
  for j = 1:nRep
    oriR = discreteSample(odfH,M(i),'silent');
    err = @(hw) norm(odfH - calcDensity(oriR,'halfwidth',hw*degree))/norm(odfH);
    [hwRand(i,j),eRand(i,j)] = fminbnd(err,2.5,30,optimset('TolX',0.1));
  end

  % the optimal sample - deterministic, so a single run is enough
  oriO = optimalSample(odfH,M(i));
  err = @(hw) norm(odfH - calcDensity(oriO,'halfwidth',hw*degree))/norm(odfH);
  [hwOpt(i),eOpt(i)] = fminbnd(err,2.5,30,optimset('TolX',0.1));

end

%%
% Both halfwidths follow a power law $\delta = a \, M^{b}$ which we recover
% by a linear fit in a double logarithmic scale

powerLaw = @(y) polyfit(log(M(:)),log(y(:)),1);

pHwRand = powerLaw(mean(hwRand,2));
pHwOpt = powerLaw(hwOpt);

disp("halfwidth for discreteSample: " + round(exp(pHwRand(2)),1) + ...
  " degree * M^" + round(pHwRand(1),3))
disp("halfwidth for optimalSample: " + round(exp(pHwOpt(2)),1) + ...
  " degree * M^" + round(pHwOpt(1),3))

%%
% Let us display the measured halfwidths together with the fitted laws

Mf = logspace(log10(M(1)),log10(M(end)),100);
evalLaw = @(p,x) exp(polyval(p,log(x)));
cRand = ind2color(1); cOpt = ind2color(2);

% a plain figure - plotting into a left over MTEX figure would hijack one of
% its tiles
figure

loglog(Mf,evalLaw(pHwRand,Mf),'LineWidth',1.5,'Color',cRand)
hold on
loglog(Mf,evalLaw(pHwOpt,Mf),'LineWidth',1.5,'Color',cOpt)
loglog(M,mean(hwRand,2),'o','MarkerSize',8,'Color',cRand,'MarkerFaceColor',cRand)
loglog(M,hwOpt,'s','MarkerSize',8,'Color',cOpt,'MarkerFaceColor',cOpt)
hold off
xlabel('number of orientations M')
ylabel('optimal halfwidth in degree')
legend('discreteSample','optimalSample','Location','southwest')
grid on

%%
% The two exponents are of a similar size, i.e. the halfwidth of an optimal
% sample decays only slightly faster and most of the difference between the
% two samplers is a constant factor. This factor is the practical message of
% this section - an optimal sample tolerates a distinctly sharper kernel

disp("ratio of the halfwidths: " + round(hwOpt(1)/mean(hwRand(1,:)),2) + ...
  " at M = " + M(1) + " and " + round(hwOpt(end)/mean(hwRand(end,:)),2) + ...
  " at M = " + M(end))

%%
% For comparison, the |'magicRule'| implemented in
% <orientation.calcKernel.html |calcKernel|> sets the kernel parameter to
% $\kappa \sim M^{2/7}$, and since the halfwidth of a
% <SO3DeLaValleePoussinKernel.html de la Vallee Poussin kernel> behaves like
% $\delta \sim \kappa^{-1/2}$, this corresponds to $\delta \sim M^{-1/7}
% \approx M^{-0.14}$. That is the classical asymptotic rate for kernel
% density estimation on a three dimensional space. The exponents measured
% above are steeper, which is not a contradiction - the rate is an asymptotic
% statement, while the fit is taken over less than two decades of $M$ and
% over a model ODF that is half uniform. What matters here is the comparison
% of the two samplers with each other, since both are measured in exactly the
% same way.
%
% Note also that all halfwidth rules of |calcKernel| are derived for random
% samples and will therefore oversmooth an optimal one.
%
%% The Approximation Error as a Function of the Sample Size
%
% Once every sample is equipped with its own optimal halfwidth we may finally
% compare the errors themselves.

pERand = powerLaw(mean(eRand,2));
pEOpt = powerLaw(eOpt);

figure

loglog(Mf,evalLaw(pERand,Mf),'LineWidth',1.5,'Color',cRand)
hold on
loglog(Mf,evalLaw(pEOpt,Mf),'LineWidth',1.5,'Color',cOpt)
loglog(M,mean(eRand,2),'o','MarkerSize',8,'Color',cRand,'MarkerFaceColor',cRand)
loglog(M,eOpt,'s','MarkerSize',8,'Color',cOpt,'MarkerFaceColor',cOpt)
hold off
xlabel('number of orientations M')
ylabel('relative L^2 error of the reconstruction')
legend('discreteSample','optimalSample','Location','southwest')
grid on

disp("error for discreteSample: " + round(exp(pERand(2)),2) + ...
  " * M^" + round(pERand(1),3))
disp("error for optimalSample: " + round(exp(pEOpt(2)),2) + ...
  " * M^" + round(pEOpt(1),3))

%%
% In contrast to the halfwidth, the errors do not differ by a constant factor
% - the optimal sample converges at a genuinely faster rate. Equating the two
% laws answers the question a user actually cares about, namely how many
% random orientations are needed to reach the accuracy of an optimal sample
% of size $M$

nEquiv = @(m) exp((polyval(pEOpt,log(m)) - pERand(2))/pERand(1));

for m = M
  disp(m + " optimal orientations correspond to " + round(nEquiv(m)) + " random ones")
end

%%
% Two warnings about these numbers. They are measured for the specific model
% ODF of this page and neither the prefactors nor the exponents carry over
% unchanged to a different ODF - the prefactors scale with the halfwidth of
% the true ODF, and the exponents come out flatter for a sharper texture. What
% does carry over is the structure: two similar exponents, and an optimal
% sample that works with a kernel about a third sharper. And the advantage of
% the optimal sample is bounded by the |bandwidth| up to which it has been
% optimized, see <SO3Fun.optimalSample.html |optimalSample|>. As soon as the
% halfwidth becomes small enough that the reconstruction depends on harmonic
% degrees beyond that bandwidth, the optimization no longer controls the
% error and the two curves start to approach each other again.

%% Exporting Random Orientations
%
% In order to make use of the sampled orientations you probably want to
% <OrientationExport.html export> them as <RotationDefinition.html Euler
% angles> into a text files. This can be done using the commands
% |<quaternion.export.html export>| and |<orientation.export_VPSC.html
% export_VPSC>|.
