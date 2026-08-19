%% Bingham Distribution
%%
plottingConvention.default('y↑→x');
%% Theory
%
% The Bingham distribution has the density function
%
% $$ f(g;K,U) = _1\!F_1 \left(\frac{1}{2},2,K \right)^{-1} \exp
% \left\{ g^T UKU  g \right\},\qquad g\in S^3, $$
%
% where $U$ is an $4 \times 4$ orthogonal matrix with unit quaternions
% $u_{1,..,4}\in S^3$ in the columns and $K$ is a $4 \times 4$ diagonal matrix
% with the entries $k_1,..,k_4$ describing the shape of the distribution.
% $_1F_1(\cdot,\cdot,\cdot)$ is the hypergeometric function with matrix
% argument normalizing the density.
%
% The shape parameters $k_1 \ge k_2 \ge k_3 \ge k_4$ give
%
% * a _bipolar_   distribution, if $k_1 + k_4 > k_2 + k_3$,
% * a _circular_  distribution, if $k_1 + k_4 = k_2 + k_3$,
% * a _spherical_ distribution, if $k_1 + k_4 < k_2 + k_3$,
% * a _uniform_  distribution, if $k_1 = k_2 = k_3 = k_4$,
%
%%
% The general setup of the Bingham distribution in MTEX is done as follows

cs = crystalSymmetry('1');

kappa = [100 90 80 0];   % shape parameters
U     = orientation.eye(cs);  % principle axes as orthogonal orientations

odf = BinghamODF(kappa,U)

%%
% Lets visualize the ODF as pole figures

h = Miller({0,0,1},{1,0,0},{1,1,1},cs);
plotPDF(odf,h,'antipodal','silent','layout',[1 3]);

%%
% and in Euler angle space

plot(odf,'sections',6)

%% Estimating the parameters of a Bingham distribution
%
% The importance of the Bingham distribution is that it is a quite low
% dimensional model for an orientation distribution function that still is
% flexible enough to represent different kinds of textures like fibers and
% unimodal distributions. Furthermore, we may estimate Bingham distribution
% from a set of individual orientations, coming e.g. from an EBSD
% measurement or a plasticity simulation. In contrast to
% <DensityEstimation.html kernel density estimation> estimating the
% parameters of the Bingham distributions requires much less data. Lets
% demonstrate the process of fitting a Bingham ODF to experimental data. To
% this end we start with a randomly aligned fibre ODF

odfTrue = fibreODF(fibre.rand(cs));

plotPDF(odfTrue,h,'antipodal','silent')

%%
% Next we use this fibre ODF to simulate only 2000 random orientations
% using the command <SO3Fun.discreteSample.html |discreteSample|>

ori = discreteSample(odfTrue,2000);
plot(ori,'add2all','MarkerEdgeColor','k',...
  'MarkerSize',5,'MarkerFaceColor','none','MarkerEdgeAlpha',0.2)

%%
% To those simulated orientation data we can now fit a Bingham distribution
% using the command <orientation.calcBinghamODF.html |calcBinghamODF|>

odf = calcBinghamODF(ori)

plotPDF(odf,h,'antipodal','silent')

%%
% We observe an almost perfect fit between the original fibre ODF and the
% Bingham distribution estimated from only 2000 randomly drawn
% orientations. Internally the estimate is read off the orientation tensor
% of the data - |odf.A| is its matrix of eigenvectors and |odf.kappa| holds
% the shape parameters associated with them.
%
%% Specific Bingham distributions
%
% In the following we present the three corner cases of the Bingham
% distribution: the unimodal distribution, the fibre distribution, and the
% spherical distribution.
%
% *The unimodal case*
% A unimodal Bingham distribution with reference orientation |oriRef| and
% |kappa=40| is constructed by

% a modal orientation
cs = crystalSymmetry('321');
oriRef = orientation.byEuler(45*degree,0*degree,0*degree,cs);

% the corresponding Bingham ODF
odf = BinghamODF(20,oriRef)

plot(odf,'sections',6,'silent','contourf','sigma')

%%
% *The fibre case*
% For a fibre symmetric Bingham distribution we simply specify the fibre
% and the first kappa parameter. The first two kappa parameters are always
% equal while the third and fourth are zero.

f = fibre(Miller(0,0,1,cs),vector3d(1,2,3));
odf = BinghamODF(20,f)

plot(odf,'sections',6,'silent','sigma')

%%
% *The spherical case*
% The spherical case is characterized by the fact that we have 3 equal non
% zero kappa coefficients.

odf = BinghamODF([10,10,10],quaternion.eye,cs)

plot(odf,'sections',6,'silent','sigma');


%% Reading the estimated parameters
%
% Whichever way the parameters were obtained, |odf.A| holds the four
% principal axes as orientations and |odf.kappa| the shape parameters
% belonging to them - |A| is the matrix of eigenvectors of the orientation
% tensor of the data and |kappa| is derived from its eigenvalues.

odf = BinghamODF([100 90 80 0],orientation.eye(cs));

odf.A

%%

odf.kappa.'

%%
% The classification into the bipolar, circular and spherical case listed
% at the top of this page is stated for the parameters in this order. Note
% that it applies to the distribution on the quaternion sphere - once a
% nontrivial crystal symmetry is imposed, the estimated parameters describe
% the symmetrised distribution and the three cases are no longer cleanly
% separated by the sums $k_1+k_4$ and $k_2+k_3$.

%#ok<*NOPTS>