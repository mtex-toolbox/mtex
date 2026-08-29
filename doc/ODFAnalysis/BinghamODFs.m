%% Bingham ODFs
%
%%
% A Bingham orientation distribution function (ODF) is one compact model
% for a texture with different spreads in different directions. It uses one
% quadratic form. This form can describe a round or elongated peak, a peak
% spread along a fibre, or a surface-like distribution in orientation space.
% <DensityEstimation.html Kernel density estimation> instead places one
% kernel at every measured orientation.
%
% This page assumes the normalization introduced in
% <ODFTheory.html ODF Theory> and the model families compared in
% <ODFModeling.html ODF Modeling>. It also uses the
% <RotationRepresentations.html unit-quaternion representation> of a
% rotation. Quaternions $g$ and $-g$ represent the same rotation. A Bingham
% density has the same value at both. Its antipodal symmetry is therefore
% exactly what a density on rotations requires.
%
% MTEX represents the result as an @SO3FunBingham. It therefore supports
% the same evaluation, plotting, and sampling interface as other
% <SO3FunConcept.html orientation functions>.

plottingConvention.default('y↑→x');

%% Constructing a General Bingham ODF
%
% A Bingham model needs four mutually orthogonal quaternion axes and four
% shape parameters. The axes are orthogonal in four-dimensional quaternion
% space; they are not four physical specimen directions. The example uses
% the identity quaternion basis as the axes.

cs = crystalSymmetry('1');

kappa = [100 90 80 0];
U = orientation.eye(cs);

odf = BinghamODF(kappa,U)

%%
% The printed summary identifies a Bingham component and reports its four
% shape parameters. <BinghamODF.html |BinghamODF|> normalizes the component,
% so its mean is 1 multiple of a random distribution (mrd).
%
% Pole figures project the ODF onto specimen directions. The unequal shape
% parameters make the pole-density features anisotropic rather than round.

h = Miller({0,0,1},{1,0,0},{1,1,1},cs);
plotPDF(odf,h,'antipodal','silent','layout',[1 3]);

%%
% The same anisotropy appears in sections through orientation space. The
% peak changes position between the six panels. Each panel cuts a different
% part of the three-dimensional ODF.

plot(odf,'sections',6);

%% Estimating the Parameters
%
% <orientation.calcBinghamODF.html |calcBinghamODF|> estimates a Bingham
% model from individual orientations. Those orientations may come from
% EBSD or from a simulation. This compact fit can work with far fewer
% measurements than a kernel estimate. It also assumes that one Bingham
% component is adequate.
%
% Start with a fibre ODF about a randomly chosen fibre.

odfTrue = fibreODF(fibre.rand(cs));

plotPDF(odfTrue,h,'antipodal','silent');

%%
% Each pole figure contains the ring expected from a fibre texture. The
% ring position differs between crystal directions, but it belongs to the
% same orientation-space fibre.
%
% Draw 2000 orientations from that ODF and add their pole points to all
% three panels with <SO3Fun.discreteSample.html |discreteSample|>.

ori = discreteSample(odfTrue,2000);
plot(ori,'add2all','MarkerEdgeColor','k',...
  'MarkerSize',5,'MarkerFaceColor','none','MarkerEdgeAlpha',0.2);

%%
% The black points fluctuate about the pole-density rings. They are a
% finite random sample, not a second texture component.
%
% Fit a Bingham distribution to the simulated orientations.

odf = calcBinghamODF(ori)

plotPDF(odf,h,'antipodal','silent');

%%
% The fitted pole figures recover the rings of the original fibre ODF from
% the 2000 sampled orientations. Small irregularities in the point overlay
% are sampling variation; the fitted Bingham model itself is smooth.
%
% Internally, MTEX obtains the four axes from the sample orientation
% tensor. They are its eigenvectors. MTEX derives |odf.kappa| from the
% corresponding eigenvalues with a large-concentration approximation.
% Thus |calcBinghamODF| is a moment-based approximate fit. It is not a
% general maximum-likelihood optimizer. Reach for this model when one
% compact shape is plausible. Compare the fitted plots with the data before
% treating its parameters as a complete description.

%% Three Non-Uniform Cases
%
% The general quaternion Bingham distribution is classified as bipolar,
% circular, or spherical. For texture work these correspond to a localized
% orientation peak, a fibre-like peak, and a surface-like distribution.
% Here "spherical" describes the set of maxima on the quaternion sphere; it
% does not mean a uniform ODF.

%% A Bipolar or Unimodal Distribution
%
% A scalar shape parameter and a reference orientation define a unimodal
% Bingham distribution. <BinghamODF.html |BinghamODF|> expands the scalar
% |20| to |[20 0 0 0]|. The reference orientation is the unique maximum,
% apart from its antipode and symmetry-equivalent descriptions.

cs = crystalSymmetry('321');
oriRef = orientation.byEuler(45*degree,0*degree,0*degree,cs);

odf = BinghamODF(20,oriRef)

plot(odf,'sections',6,'silent','contourf','sigma');

%%
% The filled contours form localized patches. Crystal symmetry repeats the
% same physical peak; those repeated patches are not additional components.

%% A Circular or Fibre Distribution
%
% Passing a @fibre with one shape parameter expands |20| to
% |[20 20 0 0]|. The two equal leading parameters make the density constant
% along the fibre, while the two zeros control its transverse decay.

f = fibre(Miller(0,0,1,cs),vector3d(1,2,3));
odf = BinghamODF(20,f)

plot(odf,'sections',6,'silent','sigma');

%%
% The high-density feature now continues through successive section panels
% instead of closing around one orientation. That continuity is the visual
% signature of the fibre.

%% A Spherical or Surface-Like Distribution
%
% Three equal nonzero parameters give the spherical case. The omitted
% fourth value is padded with zero, so this call uses |[10 10 10 0]|.

odf = BinghamODF([10 10 10],quaternion.eye,cs)

plot(odf,'sections',6,'silent','sigma');

%%
% This plot is not uniform: the density avoids the fourth quaternion axis
% and spreads its maxima over a two-dimensional set. A uniform distribution
% requires all four parameters to be equal. Because a common offset is
% irrelevant, MTEX can represent that case with |[0 0 0 0]|.

%% Reading the Parameters
%
% Whichever constructor produced the model, |odf.A| holds its four
% principal quaternion axes as orientations. |odf.kappa| holds the shape
% parameter belonging to each axis. For a fitted model, these axes are the
% eigenvectors of the orientation tensor and the shape parameters are
% derived from its eigenvalues.
%
% Reconstruct the general example so the following output has deliberately
% unequal parameters.

odf = BinghamODF([100 90 80 0],orientation.eye(cs));

odf.A

%%
% The four displayed orientations are one orthogonal basis of quaternion
% space. Their row order matches the order of the following parameters.

odf.kappa.'

%%
% The constructor preserves the supplied axis order. A fitted model keeps
% the eigenvector order returned by the orientation tensor calculation.
% Do not sort |odf.kappa| without applying the same permutation to |odf.A|.
% The classification below instead labels the parameters in descending
% order.
%
% The bipolar, circular, and spherical classification applies to the
% distribution on the quaternion sphere. With nontrivial crystal symmetry,
% MTEX averages over symmetry-equivalent copies. The resulting ODF may not
% look like one of the three unsymmetrised cases. The sums $k_1+k_4$ and
% $k_2+k_3$ no longer cleanly separate the visible shapes.

%% The Maths Behind the Model
%
% The Bingham density on the unit-quaternion sphere is
%
% $$f(\mathbf{g};\mathbf{K},\mathbf{U}) = C(\mathbf{K})^{-1}
% \exp\!\left\{\mathbf{g}^{\mathrm{T}}\mathbf{U}\mathbf{K}
% \mathbf{U}^{\mathrm{T}}\mathbf{g}\right\},\qquad
% \mathbf{g}\in S^3,$$
%
% where $\mathbf{U}$ is a $4\times4$ orthogonal matrix. Its columns
% $u_{1},\ldots,u_{4}\in S^3$ are the principal quaternion axes.
% $\mathbf{K}$ is diagonal, with ordered entries
% $k_1\geq k_2\geq k_3\geq k_4$. The normalizing constant is
% $C(\mathbf{K})$. It is a confluent hypergeometric function with matrix
% argument.
%
% Adding the same constant to all four $k_i$ changes the exponential and
% its normalizing constant by the same factor. Only three concentration
% differences are therefore identifiable. The matrix $\mathbf{U}$ must also
% be estimated. This is a low-dimensional model, but it does not have only
% four fitted numbers.
%
% For ordered parameters, the three non-uniform cases satisfy
%
% * bipolar if $k_1+k_4 > k_2+k_3$,
% * circular if $k_1+k_4 = k_2+k_3$,
% * spherical if $k_1+k_4 < k_2+k_3$.
%
% The distribution is uniform if
% $k_1=k_2=k_3=k_4$.

%% Further Reading
%
% * <https://doi.org/10.1214/aos/1176342874 Bingham (1974)> introduces the
% antipodally symmetric distribution and its statistical inference.
% * <https://doi.org/10.1023/B:MATG.0000048799.56445.59 Kunze and Schaeben
% (2004)> develop the quaternion classification and its interpretation for
% crystallographic textures and pole figures.
% * <https://doi.org/10.1107/S002188981003027X Bachmann et al. (2010)>
% derive orientation-tensor statistics and the high-concentration
% approximation used for EBSD orientation data.
% * <https://doi.org/10.1002/9780470316979 Mardia and Jupp, Directional
% Statistics> provides the broader theory of axial and directional data.

%% Next
%
% The other model ODFs are <RadialODFs.html Radial ODFs> and
% <FibreODFs.html Fibre ODFs>. A nonparametric alternative does not assume
% one Bingham shape; see
% <DensityEstimation.html Density Estimation>. The shared plotting tools are
% introduced in <ODFPlot.html Plotting an ODF>.

%#ok<*NOPTS>
