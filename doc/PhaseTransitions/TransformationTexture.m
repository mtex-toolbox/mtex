%% Transformation Texture
%
% Parent grain reconstruction asks which parent produced measured children.
% This page asks the forward question: which child texture does a known
% parent texture and parent-to-child orientation relationship (OR) predict?
%
% The example first transforms one orientation and then an entire orientation
% distribution function (ODF). It ends by showing why variant selection must
% be stated when a predicted texture is compared with a measured one.

plottingConvention.default('y↑→x');
rng(1)

%% Define the parent and child phases
%
% During a phase transformation or twinning, a crystal can rapidly change
% from a parent orientation |oriA| to a child orientation |oriB|.
% An OR describes the fixed angular relation between their lattices.
% Here both phases are cubic, and the Nishiyama-Wassermann (NW) OR relates
% austenite to ferrite.

csP = crystalSymmetry('432','mineral','Austenite');
csC = crystalSymmetry('432','mineral','Ferrite');
p2c = orientation.NishiyamaWassermann(csP,csC)

%% Transform one parent orientation
%
% Start with an arbitrary austenite orientation.

oriA = orientation.rand(csP)

%%
% Symmetry means that the OR does not predict only one ferrite orientation.
% <ParentChildVariants.html Parent and Child Variants> defines a variant and
% derives how <orientation.variants.html |variants|> removes equivalent
% candidates. Applying it here returns all distinct NW child variants.

oriB = variants(p2c,oriA);
numChildVariants = length(oriB)

%%
% The printed result is 12 ferrite variants for this parent orientation.
% The pole figures show their crystallographic spread.

hC = Miller({1,1,1},{1,1,0},csC);
hP = Miller({1,1,0},{1,0,0},csP);

plotPDF(oriB,hC,'MarkerSize',5,'markerColor','black',...
  'figSize','medium');

opt = {'MarkerFaceColor','none','MarkerEdgeColor','darkred',...
  'lineWidth',3};
for k = 1:2
  nextAxis(k)
  hold on
  plot(oriA * hP(k).symmetrise,opt{:})
  xlabel(char(hP(k),'latex'),'Color','red',...
    'Interpreter','latex')
  hold off
end
drawNow(gcm)

%%
% Black points are poles of the 12 child variants.
% Red open markers are symmetry-equivalent poles of their one parent.
% The repeated black clusters show that one sharp parent component produces
% several symmetrically related child components.

%% Define a parent texture
%
% An ODF is a normalized density on orientation space.
% Density is reported in multiples of a random distribution (mrd).
% We place a 5-degree unimodal austenite ODF around |oriA|.

odfA = unimodalODF(oriA,'halfwidth',5*degree)

plotPDF(odfA,hP,'figSize','medium')
mtexColorbar('title','mrd')

%%
% Each pole-density maximum surrounds a pole of the modal parent orientation.
% The finite halfwidth represents a parent texture component rather than one
% perfectly sharp orientation.

%% Approximate the child texture by sampling
%
% A Monte Carlo route draws parent orientations from |odfA|.
% Each of the 10,000 draws produces all 12 equally populated child variants.

n = 10000;
oriASim = odfA.discreteSample(n);
oriBSim = variants(p2c,oriASim);
numSimulatedChildren = length(oriBSim)

%%
% The 120,000 child orientations approximate the transformed texture.
% <calcDensity.html |calcDensity|> turns that discrete set back into an ODF.

odfBSim = calcDensity(oriBSim)

plotPDF(odfBSim,hC,'contourf','figSize','medium');
mtexColorbar('title','mrd')

%%
% The lobes occupy the same symmetry-related positions as the single-parent
% variants. Their finite width comes from the parent ODF, while small contour
% irregularities come from random sampling and density estimation.

%% Transform the ODF directly
%
% The direct route passes |odfA| to
% <orientation.variants.html |variants|>.
% MTEX averages the parent density over the 12 candidate-parent branches.
% This calculation therefore assumes equal population of all child variants.

odfB = variants(p2c,odfA)

plotPDF(odfB,hC,'contourf','figSize','medium');
mtexColorbar('title','mrd')

%%
% The direct ODF has smooth, sharp lobes at the locations predicted by the
% discrete calculation. It avoids Monte Carlo noise and the additional
% density-estimation step, so it is the preferred route when equal variant
% populations are appropriate.

%% Quantify the sampling difference
%
% The texture index, or J-index, is the mean square of a normalized ODF.
% It is 1 for a uniform texture and increases as texture sharpens.
% <ODFCharacteristics.html ODF Characteristics> develops this measure.

meanSampledChildODF = mean(odfBSim)
meanDirectChildODF = mean(odfB)
textureIndexSampled = norm(odfBSim)^2
textureIndexDirect = norm(odfB)^2

%%
% Both means print as 1.0000, confirming that the ODFs are normalized.
% The sampled and direct texture indices are 3.4814 and 17.4509.
% The earlier page described it as sharper and more detailed; the two
% texture-index values make that comparison reproducible.
% |calcDensity| selected bandwidth 25, while the direct result retains
% bandwidth 48. The difference therefore includes smoothing as well as
% Monte Carlo noise; it does not compare two different physical materials.

%% Model complete variant selection
%
% Equal populations are a crystallographic baseline, not a universal material
% law. Stress, interfaces, and transformation history can favour some variants.
% To expose the consequence, assign variant 1 to every sampled parent.
% This complete selection is deliberately an end member rather than a fitted
% physical model.

selectedVariantId = ones(n,1);
oriBSelected = variants(p2c,oriASim,selectedVariantId);
odfBSelected = calcDensity(oriBSelected)

plotPDF(odfBSelected,hC,'contourf','figSize','medium');
mtexColorbar('title','mrd')

%%
% The selected texture contains one transformed branch instead of the
% 12-branch superposition. Its stronger, less symmetrically repeated lobes show
% why measured child textures cannot be interpreted from the OR alone.
% A variant-population model is also required.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, English ed.,
% 1982, develops normalized ODFs and the texture index used to compare the
% transformed distributions.

%% Next
%
% Continue with <GrainGraphBasedReconstruction.html Grain Graph Based
% Reconstruction> to return to the inverse problem. That page uses shared
% boundaries to decide which measured martensite grains have a common parent.

%#ok<*NOPTS>
