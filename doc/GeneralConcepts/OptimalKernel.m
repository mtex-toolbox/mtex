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
% unknown density. This page compares the three selection methods provided
% by <orientation.calcKernel.html |calcKernel|> and shows how to check their
% choices against a known model.

plottingConvention.default('y↑→x');

%% Build a model with several kinds of structure
%
% The original example described the following crystal symmetry as cubic.
% Point group 321 is trigonal, so the code and its resulting fundamental
% region must be read as a trigonal example.

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

%% Select a kernel from sampled orientations
%
% Draw 10000 orientations from the model. The random seed makes the sample
% and every reported result reproducible.

ori = discreteSample(modelODF,10000,'silent');
sampleCount = length(ori)

%%
% With no method option, |calcKernel| uses Kullback--Leibler
% cross-validation (KLCV). It returns a de la Vallée Poussin kernel rather
% than an ODF.

psi = calcKernel(ori,'silent')
selectedHalfwidth = psi.halfwidth ./ degree

%%
% Pass that kernel to <rotation.calcDensity.html |calcDensity|>. The same
% |psi| can therefore be reused for another sample that represents the same
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

%% What the three methods use
%
% The method names are sometimes described as flags in older material.
% The current interface passes each name as the value of |'method'|.
%
% || method || information used || practical reading ||
% || |'KLCV'| || leave-one-out likelihood on candidate kernels || default; data-adaptive ||
% || |'RuleOfThumb'| || nearest-neighbour resolution of the sample || quick scale estimate ||
% || |'magicRule'| || sample size and crystal/specimen symmetry || conservative asymptotic rule ||
%
% Older descriptions say that |'RuleOfThumb'| uses the variance of the
% orientations to estimate smoothness. The current implementation instead
% uses a quantile of nearest-neighbour angular distances, with a lower
% halfwidth limit of 2 degrees.
%
% KLCV evaluates how well kernels centred on the other orientations predict
% each omitted orientation. The |'SamplingSize'| option limits how many
% observations contribute to that score. It reduces computation, but it
% does not create an independent validation dataset.

%% Compare the methods on the same samples
%
% The full scaling experiment associated with this page uses 10, 100, ...,
% 1000000 orientations. That run is appropriate for an attended benchmark,
% not an executable documentation page. Uncomment the alternative
% |sampleSize| line when that full study is intended.

sampleSize = [30 100 300 1000];
% sampleSize = 10.^(1:6); % full study: 10 through 1000000

method = ["KLCV","RuleOfThumb","magicRule"];
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
% Read each row as one random sample tested three ways. This controls the
% sample-to-sample variation when comparing methods within a row. One draw
% at each size is a demonstration, not evidence that one method is always
% best.

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
% Automatic selection assumes that the input orientations represent the
% intended population. Neighbouring pixels in one EBSD grain are strongly
% correlated, so treating every pixel as independent can select a kernel
% that follows intragranular scatter. Use grain means to select the kernel
% when grains are the independent sampling units.
%
% Weighting answers a separate question. After selecting a kernel from
% grain means, an area-based ODF may still use pixels or grain-area weights.
% <EBSD2ODF.html ODF Estimation from EBSD Data> works through that choice.
%
% Also inspect the selected halfwidth and the reconstructed plots. A value
% at the edge of the tested candidate range, or peaks supported by only one
% or two observations, is a reason to test nearby kernels manually.

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

%% Next
%
% <ClusterDemo.html Clustering> replaces a continuous density by discrete
% groups of nearby orientations. Use it when group membership is the goal
% rather than estimating how probability varies through orientation space.
