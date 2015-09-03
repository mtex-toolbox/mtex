%% Bingham distribution and EBSD data
% testing rotational symmetry of individual orientations
%
%% Open in Editor
%
%% Contents
%

%% Bingham Distribution
% The quaternionic Bingham distribution has the density
%
% $$ f(g;K,U) = _1F_1 \left(\frac{1}{2},2,K \right)^{-1} \exp
% \left\{ g^T UKU  g \right\},\qquad g\in S^3, $$
%
% where $U$ is a $4 \times 4$ orthogonal matrix with unit quaternions
% $u_{1,..,4}\in S^3$ in column and $K$ is a $4 \times 4$ diagonal matrix
% with the entries $k_1,..,k_4$ describing the shape of the distribution.
% $_1F_1(,,)$ is the hypergeometric function with matrix argument normalizing
% the density.
%
% The shape parameters $k_1 \ge k_2 \ge k_3 \ge k4$ give
%
% * a _bipolar_   distribution, if $k_1 + k_4 > k_2 + k_3$,
% * a _circular_  distribution, if $k_1 + k_4 = k_2 + k_3$,
% * a _spherical_ distribution, if $k_1 + k_4 < k_2 + k_3$,
% * an _uniform_  distribution, if $k_1 = k_2 = k_3 = k_4$,
%
% in unit quaternion space. Since the quaternion +g and -g describes the same rotation, the
% _bipolar_ distribution corresponds to an unimodal distribution in
% orientation space. Moreover we would call the _circular_ distribution a
% fibre in orientation space.
%
%%
% The general setup of the Bingham distribution in MTEX is done as follows

cs = crystalSymmetry('1');

kappa = [100 90 80 0];   % shape parameters
U     = eye(4);          % orthogonal matrix

odf = BinghamODF(kappa,U,cs)

%%
%

h = [Miller(0,0,1,cs) Miller(1,0,0,cs) Miller(1,1,1,cs)];
plotPDF(odf,h,'antipodal','silent');


% plot(odf,'sections',10)
%% The bipolar case and unimodal distribution
% First we define some unimodal odf

odf_spherical = unimodalODF(idquaternion,crystalSymmetry,specimenSymmetry,'halfwidth',20*degree)

%%
%

plotPDF(odf_spherical,h,'antipodal','silent')

%%
% Next we simulate individual orientations from this odf, in a scattered
% axis/angle plot in which the simulated data looks like a sphere

ori_spherical = calcOrientations(odf_spherical,1000);
scatter(ori_spherical)

%%
% From this simulated ebsd data, we can estimate the parameters of the
% bingham distribution,

calcBinghamODF(ori_spherical)


%%
% where |U| is the orthogonal matrix of eigenvectors of the orientation
% tensor and |kappa| the shape parameters associated with the |U|.
%
% next, we test the different cases of the distribution on rejection

T_spherical = bingham_test(ori_spherical,'spherical','approximated');
T_oblate    = bingham_test(ori_spherical,'prolate',  'approximated');
T_prolate   = bingham_test(ori_spherical,'oblate',   'approximated');

t = [T_spherical T_oblate T_prolate]

%%
% The spherical test case failed to reject it for some level of
% significance, hence we would dismiss the hypothesis prolate and oblate.

odf_spherical = BinghamODF(kappa,U,crystalSymmetry,specimenSymmetry)

%%
%

plotPDF(odf_spherical,h,'antipodal','silent')

%% Prolate case and fibre distribution
% The prolate case correspondes to a fibre.

odf_prolate = fibreODF(Miller(0,0,1,crystalSymmetry('1')),zvector,...
  'halfwidth',20*degree)

%%
%

plotPDF(odf_prolate,h,'upper','silent')

%%
% As before, we generate some random orientations from an model odf. The
% shape in a axis/angle scatter plot reminds of a cigar

ori_prolate = calcOrientations(odf_prolate,1000);
scatter(ori_prolate)

%%
% We estimate the parameters of the bingham distribution

calcBinghamODF(ori_prolate)

%%
% and test on the three cases

T_spherical = bingham_test(ori_prolate,'spherical','approximated');
T_oblate    = bingham_test(ori_prolate,'prolate',  'approximated');
T_prolate   = bingham_test(ori_prolate,'oblate',   'approximated');

t = [T_spherical T_oblate T_prolate]

%%
% The test clearly rejects the spherical and prolate case, but not the
% prolate. We construct the bingham distribution from the parameters, it
% might show some skewness

odf_prolate = BinghamODF(kappa,U,crystalSymmetry,specimenSymmetry)

%%
%

plotPDF(odf_prolate,h,'antipodal','silent')

%% Oblate case
% The oblate case of the bingham distribution has no direct counterpart in
% terms of texture components, thus we can construct it straightforward

odf_oblate = BinghamODF([50 50 50 0],eye(4),crystalSymmetry,specimenSymmetry)

%%
%

plotPDF(odf_oblate,h,'antipodal','silent')

%%
% The oblate cases in axis/angle space reminds on a disk 

ori_oblate = calcOrientations(odf_oblate,1000);
scatter(ori_oblate)

%%
% We estimate the parameters again

calcBinghamODF(ori_oblate)

%%
% and do the tests

T_spherical = bingham_test(ori_oblate,'spherical','approximated');
T_oblate    = bingham_test(ori_oblate,'prolate',  'approximated');
T_prolate   = bingham_test(ori_oblate,'oblate',   'approximated');

t = [T_spherical T_oblate T_prolate]

%%
% the spherical and oblate case are clearly rejected, the prolate case
% failed to reject for some level of significance

odf_oblate = BinghamODF(kappa, U,crystalSymmetry,specimenSymmetry)

%%
%

plotPDF(odf_oblate,h,'antipodal','silent')


