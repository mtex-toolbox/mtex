%% Optimal Kernel Selection
%
%%
% <DensityEstimation.html Density Estimation> showed that kernel width
% decides which features survive smoothing. A width that is too small
% leaves oscillations and sharp peaks at individual observations. A width
% that is too large erases genuine features of the unknown density.
%
% There is no universally optimal halfwidth. The useful value depends on
% both the number of independent observations and the smoothness of the
% unknown density. <orientation.calcKernel.html |calcKernel|> therefore
% selects it from the data. Its method |'UCV'| estimates the error of the
% density for every candidate halfwidth and takes the halfwidth where that
% error is least. This page applies the selection to orientations drawn
% from a known model, so that its choice can be checked, and then compares
% it with the other methods |calcKernel| offers.

plottingConvention.default('y↑→x');

%% Build a model with several kinds of structure
%
% The example uses the trigonal point group 321.

cs = crystalSymmetry('321');

%%
% Combine a uniform background, one localized component, and one fibre.
% Their coefficients sum to one, so |modelODF| remains normalized.

modelODF = 0.25 * uniformODF(cs) + ...
  0.25 * unimodalODF(...
  orientation.byEuler([35,45,0]*degree,cs)) + ...
  0.5 * fibreODF(Miller(7,-1,10,cs),vector3d(7,-5,11),...
  'halfwidth',10*degree);

plot(modelODF,'sections',6,'silent','sigma');
mtexColorbar('title','mrd');

%%
% The sections contain a localized maximum and an elongated fibre feature
% above a non-zero background. A useful selected kernel should retain both
% shapes without turning finite-sample noise into new maxima.

%% Select a kernel and estimate the density
%
% Draw 10000 orientations from the model.

ori = discreteSample(modelODF,10000,'silent');
sampleCount = length(ori)

%%
% |calcKernel| returns a de la Vallée Poussin kernel rather than an ODF.

psi = calcKernel(ori,'method','UCV','silent')
selectedHalfwidth = psi.halfwidth ./ degree

%%
% Pass that kernel to <rotation.calcDensity.html |calcDensity|>. The same
% |psi| can be reused for another sample that represents the same
% population and sampling process.

reconstructedODF = calcDensity(ori,'kernel',psi,'silent');
reconstructionError = calcError(reconstructedODF,modelODF,...
  'resolution',5*degree)

plot(reconstructedODF,'sections',6,'silent','sigma');
mtexColorbar('title','mrd');

%%
% Compare these sections with the model above. The localized maximum and
% the fibre remain in the same places, while their contours are not
% identical because only a finite random sample was reconstructed.
%
% |reconstructionError| compares density values over orientation space.
% It is not an angular error and must not be labelled in degrees.

%% How UCV selects
%
% Unbiased cross-validation, |'UCV'|, works as follows. For each of
% 60 candidate halfwidths between 2 and 40 degrees it estimates the
% integrated squared error between the density estimate and the unknown
% texture, and returns the candidate where that error is least. The
% estimate is computed from the harmonic coefficients of the sample, so it
% costs about one harmonic transform of the orientations, and no model of
% the texture is needed.
%
% The selection is bounded below by a noise floor. It never returns a
% halfwidth so narrow that the sampling noise could raise bumps above a
% fifth of the estimate's maximum. For small samples this bound, rather
% than the error estimate, decides the halfwidth. The flag |'noNoiseFloor'|
% removes it.

%% A cautious alternative
%
% The selected halfwidth is the best estimate, not a guarantee. When
% spurious features would be costly, |'conservative'| inserts lower
% confidence bounds for the harmonic content of the texture into the same
% error formula. Less content favours a wider kernel, so its halfwidth is
% at least the one of least error whenever the bounds hold.

psiConservative = calcKernel(ori,'method','conservative','silent');
conservativeHalfwidth = psiConservative.halfwidth ./ degree

%%
% With 10000 orientations the harmonic content of this texture is resolved
% well enough that the conservative choice nearly agrees with UCV. With few
% orientations, or few grains in a map, it stays much wider.

%% Orientations that are not independent
%
% Automatic selection assumes that the input orientations are independent
% observations of the intended population. Neighbouring pixels in one EBSD
% grain are strongly correlated, so treating every pixel as independent
% selects a kernel that follows the grains instead of the texture.
%
% Pass the map after grain reconstruction instead.
% <EBSD.calcKernel.html |calcKernel(ebsd)|> splits it into parts that share
% no grain and compares only pixels of different parts. The option
% |'groups'| does the same for orientations or directions given with their
% grain ids, |calcKernel(ori,'groups',grainId)|. <EBSD2ODF.html ODF
% Estimation from EBSD Data> works through a map and through the separate
% question of how pixels and grains should be weighted.

%% Other selection methods
%
% |calcKernel| offers three further methods, chosen by the option
% |'method'|.
%
% || method || information used || practical reading ||
% || |'UCV'| || unbiased estimate of the integrated squared error, with a noise floor || aims at the halfwidth of least error ||
% || |'conservative'| || lower bounds of the harmonic content, with a noise floor || errs towards smoothing ||
% || |'KLCV'| || leave-one-out likelihood on ten candidate kernels || default; data-adaptive and fast ||
% || |'RuleOfThumb'| || nearest-neighbour resolution of the sample || quick scale estimate ||
% || |'magicRule'| || sample size and crystal/specimen symmetry || conservative asymptotic rule ||
%
% Kullback--Leibler cross-validation, |'KLCV'|, scores how well kernels
% centred on the other orientations predict each omitted orientation. The
% |'SamplingSize'| option limits how many observations contribute to that
% score. It reduces computation, but it does not create an independent
% validation dataset. |'KLCV'| is the default of |calcKernel|: it is two to
% four times faster than |'UCV'| and selects somewhat wider kernels.
% |'RuleOfThumb'| uses a quantile of nearest-neighbour
% angular distances, with a lower halfwidth limit of 2 degrees.
% |'magicRule'| reads only the number of orientations and the symmetry.
% None of the three accepts grain ids.
%
% Since the model is known here, the error of each choice can be measured.
% Compare UCV and the conservative rule with KLCV on the same sample.

method = ["UCV","conservative","KLCV"];
for m = method
  psiM = calcKernel(ori,'method',char(m),'silent');
  odfM = calcDensity(ori,'kernel',psiM,'silent');
  fprintf('%-12s halfwidth %5.2f%s, error %.3f, L2 error %.3f\n',m,...
    psiM.halfwidth/degree,mtexdegchar,...
    calcError(odfM,modelODF,'resolution',5*degree),calcError(odfM,modelODF,'L2'));
end

%%
% UCV and the conservative rule ask for about 4 degrees, KLCV for 5.7 to 7
% degrees. The default error of |calcError|, half the mean absolute
% difference, finds the three close. The |'L2'| error, the integrated
% squared error that UCV minimises, separates them: UCV meets the best
% candidate halfwidth for that error, and KLCV's error is a third to twice
% as large again.

%% Compare the methods across sample sizes
%
% The full scaling experiment associated with this page uses 10, 100, ...,
% 1000000 orientations. That run is appropriate for an attended benchmark,
% not an executable documentation page. Uncomment the alternative
% |sampleSize| line when that full study is intended.

sampleSize = [30 100 300 1000];
% sampleSize = 10.^(1:6); % full study: 10 through 1000000

method = ["UCV","conservative","KLCV","RuleOfThumb","magicRule"];
halfwidthInDegree = zeros(numel(sampleSize),numel(method));
estimationError = zeros(numel(sampleSize),numel(method));

for i = 1:numel(sampleSize)

  oriTrial = discreteSample(modelODF,sampleSize(i),'silent');

  for j = 1:numel(method)

    psiTrial = calcKernel(oriTrial,'method',char(method(j)),...
      'SamplingSize',1000,'silent');
    trialODF = calcDensity(oriTrial,'kernel',psiTrial,'silent');

    halfwidthInDegree(i,j) = psiTrial.halfwidth ./ degree;
    estimationError(i,j) = calcError(trialODF,modelODF,...
      'resolution',7.5*degree);

  end
end

rowName = compose('N_%d',sampleSize);
halfwidthTable = array2table(halfwidthInDegree,...
  'VariableNames',cellstr(method),'RowNames',cellstr(rowName))

errorTable = array2table(estimationError,...
  'VariableNames',cellstr(method),'RowNames',cellstr(rowName))

%%
% Read each row as one random sample tested five ways. This controls the
% sample-to-sample variation when comparing methods within a row. One draw
% at each size is a demonstration, not evidence that one method is always
% best.
%
% With 30 orientations the noise floor keeps UCV and the conservative rule
% wide, and their choice changes strongly from one draw to the next. No
% narrower kernel would stand out of the sampling noise. From a few hundred
% orientations on, UCV's error is close to that of KLCV or below it, and at
% 1000 orientations UCV asks for 6 to 7 degrees where KLCV asks for 9.4.
% From 100 orientations on, the two rules that ignore the data beyond its
% size have the largest error.

figure;
loglog(sampleSize,estimationError,'o-','LineWidth',2);
legend(cellstr(method),'Location','best');
xlabel('number of orientations');
ylabel('ODF estimation error');
grid on;

%%
% The curves compare density-space error, with smaller values indicating a
% closer reconstruction. Their differences show that kernel selection is
% part of the statistical model rather than a display preference.

%% Before trusting an automatic halfwidth
%
% Inspect the selected halfwidth and the reconstructed plots. A value at
% the edge of the candidate range, or peaks supported by only one or two
% observations, is a reason to test nearby kernels manually.

%% The maths behind UCV and the conservative rule
%
% Write the density in harmonics orthonormal for the uniform distribution,
% $f = 1 + \sum_{\ell \ge 1} f_\ell$, with the degree energies
% $A_\ell = \|f_\ell\|^2$. A radial kernel multiplies degree $\ell$ by a
% factor $b_\ell$ that falls as the halfwidth grows. For $N$ independent
% orientations the mean integrated squared error is exactly
%
% $$ \mathrm{MISE} = \sum_{\ell \ge 1} (1 - b_\ell)^2 A_\ell
% + \frac{1}{N} \sum_{\ell \ge 1} b_\ell^2 \left( d_\ell - A_\ell \right), $$
%
% where $d_\ell$ is the dimension of degree $\ell$ reduced by the crystal
% and specimen symmetry. |'UCV'| inserts unbiased estimates of $A_\ell$ and
% minimises over the candidates. |'conservative'| obtains the estimates
% from products of disjoint parts of the sample, inserts lower confidence
% bounds, and sets the unresolved high degrees to zero. Lowering the
% energies can only move the minimiser to a wider kernel. Splitting a map
% into parts that share no grain keeps the estimates unbiased when pixels of
% one grain are correlated.
%
% The noise floor looks at the estimate itself. At an orientation where the
% smoothed density is $y$, the estimate is a sum of $N$ independent terms,
% none larger than $\psi(0)/N$, with variance $y\,\|\psi\|^2/N$. Bennett's
% inequality bounds its deviation at every one of the independent kernel
% footprints of orientation space. The floor is the smallest halfwidth at
% which that bound stays below a fifth of the estimate's maximum plus half
% the local density. <selectHalfwidth.html |selectHalfwidth|> exposes the
% candidates, the bandwidth and these constants as options.

%% The maths behind the sample-size rule
%
% For the de la Vallée Poussin kernel, |'magicRule'| sets the concentration
% parameter $\kappa$ proportional to $N^{2/7}$. The kernel halfwidth then
% behaves approximately as
%
% $$ \delta \mathrel{\sim} \kappa^{-1/2}
% \mathrel{\sim} N^{-1/7}. $$
%
% The rule therefore narrows the kernel as the sample grows. It cannot use
% the unknown density's feature sizes, which is why it is conservative.
% Rule-of-thumb and cross-validation methods use the observations to add
% information about those scales.

%% References
%
% * R. Hielscher,
% <https://doi.org/10.1016/j.jmva.2013.03.014 Kernel density estimation on
% the rotation group and its application to crystallographic texture
% analysis>, _Journal of Multivariate Analysis_ 119 (2013), 119--143,
% derives the orientation-space estimator, asymptotic halfwidth rules, and
% fast algorithms used for large orientation samples.
% * P. Hall, G. S. Watson and J. Cabrera,
% <https://doi.org/10.1093/biomet/74.4.751 Kernel density estimation with
% spherical data>, _Biometrika_ 74 (1987), 751--762, introduces least
% squares and likelihood cross-validation for kernel estimates on the
% sphere, the criteria behind |'UCV'| and |'KLCV'|.
% * G. Bennett, <https://doi.org/10.1080/01621459.1962.10482149 Probability
% inequalities for the sum of independent random variables>, _Journal of the
% American Statistical Association_ 57 (1962), 33--45, gives the deviation
% bound of the noise floor.

%% Next
%
% <ClusterDemo.html Clustering> replaces a continuous density by discrete
% groups of nearby orientations. Use it when group membership is the goal
% rather than estimating how probability varies through orientation space.
