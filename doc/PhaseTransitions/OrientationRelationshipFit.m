%% Fitting the Orientation Relationship
%
% An orientation relationship (OR) is the rotation that relates the parent
% crystal frame to the child crystal frame during a phase transition.
% <calcParent2Child.html |calcParent2Child|> estimates this rotation when only
% the child phase remains in an EBSD map.
%
% The fit uses misorientations between neighbouring child grains.
% It assumes that most retained pairs are variants from a common parent grain.
% This page first fits and checks an OR, then explains the objective and the
% convergence of the algorithm.
% The full derivation and implementation decisions are recorded in
% |docs/adr/0005-parent-to-child-fit.md|.

plottingConvention.default('y↑→x');

%% Prepare the child-grain pairs
%
% Load the martensite map and segment its bcc measurements into grains.
% A grain is a phase-homogeneous, spatially connected region of EBSD pixels.

mtexdata martensite

[grains,ebsd] = calcGrains(ebsd,'angle',3*degree,'minPixel',2,'alpha',12);

job = parentGrainReconstructor(ebsd,grains);
csParent = job.csParent;
csChild = job.csChild;

%%
% <grain2d.neighbors.html |neighbors|> returns pairs of child grains that
% share a boundary.
% The mean orientations of each pair give one child-to-child misorientation.

grainPairs = neighbors(job.grains(csChild));
oriChild = job.grains(grainPairs).meanOrientation;
mori = inv(oriChild(:,1)) .* oriChild(:,2);

%%
% Pairs below 5 degrees are usually subgrain boundaries or the same variant.
% They cannot constrain the OR and are removed before fitting.

mori(mori.angle < 5*degree) = [];

%% Fit from all possible starting regions
%
% An ideal Kurdjumov-Sachs (KS) relationship is a useful initial candidate.
% By default, |calcParent2Child| also scans the complete fundamental region.
% It refines the best candidates and returns the one with the lowest misfit.

p2cKS = orientation.KurdjumovSachs(csParent,csChild)
[p2cGlobal,fitGlobal] = calcParent2Child(mori,p2cKS);
p2cGlobal

%% Inspect the residuals
%
% The second output contains one residual for every input misorientation.
% A residual is the disorientation to the closest predicted child-to-child
% variant, excluding the identity variant.

close all
histogram(fitGlobal./degree)
hold on
xline(quantile(fitGlobal,0.9)./degree,'--k','90% cutoff')
hold off
xlabel('disorientation to the closest variant in degrees')
ylabel('number of neighbouring grain pairs')

%%
% Notice the main population at small residuals and the longer tail.
% Not every neighbouring pair belongs to one former parent grain.
% The default fit therefore uses the best 90 percent rather than allowing the
% tail to pull an ordinary mean away from the main population.
%
% The |'quantile'| option changes that retained fraction.
% The |'threshold'| option caps the loss of larger residuals.
% Use a threshold in degrees only when the experiment supplies a defensible
% angular tolerance; otherwise the default quantile needs no new scale.

%% Compare local and global fits
%
% The |'local'| option skips the scan and starts the fixed-point iteration at
% the supplied relationship.
% It is useful when the starting OR is already trusted.

p2cLocal = calcParent2Child(mori,p2cKS,'local')
localToGlobal = angle(p2cLocal,p2cGlobal)./degree

%%
% The printed value is the angular separation of the two fitted ORs.
% The global solution is a good degree away from the KS-started local result
% and gives the lower objective value.
% That difference is not negligible when habit planes are computed from the
% fitted relationship.
%
% Nishiyama-Wassermann, Pitsch, and Greninger-Trojano starting relationships
% all reach the better basin on this map; Kurdjumov-Sachs does not.
% The complete scan is therefore the default.
% The supplied starting OR remains one candidate, so scanning cannot discard a
% better local result.
% It costs about two and a half times one local fit on this data.
%
% The scan is deterministic.
% Its subsamples stride through an angle-sorted list instead of drawing at
% random, so repeated fits to the same data return the same result.
% A local fit reaches a stationary point rather than a guaranteed best fit, so
% its starting relationship can decide the answer.
% Use |'local'| when refining a trusted OR or fitting many small data sets in a
% loop, where the fixed cost of the scan dominates.

%% The model: child variants determine the observed misorientations
%
% A <ParentChildVariants.html variant> is one crystallographically equivalent
% child orientation predicted from a single parent orientation by a known OR.
% For a parent orientation |oriParent|, the possible child variants have the
% form |p2c * S|, where |S| runs through the parent point group.
%
% Two child grains from one parent may select different variants.
% Their possible child-to-child misorientations are the following set.

p2cVariants = reshape(p2cGlobal.variants,[],1);
c2c = p2cGlobal * inv(p2cVariants)

%%
% In symbols, each member is |p2c * inv(S) * inv(p2c)|.
% This is the parent point group conjugated by |p2c|.
% Conjugation leaves the rotation angles unchanged.
% Without child symmetry reduction, a cubic parent supplies only 0, 90, 120,
% and 180 degree rotations.

unique(round(angle(c2c,'noSymmetry')./degree))

%%
% Only the rotation axes depend on the OR.
% Child symmetry reduces each misorientation to its disorientation, which
% spreads those four angles into the longer list below.
% The list belongs to the fitted relationship, not to ideal KS, whose
% disorientation angles are 10.53, 14.88, 20.61, 21.06, 47.11, 49.47, 50.51,
% 51.73, 57.21, and 60 degrees.

unique(round(angle(c2c)./degree,2)).'

%% See the axis fit
%
% The coloured density shows axes of the measured child-to-child
% misorientations.
% Black squares mark axes predicted by the fitted OR.

plot(mori.axis,'contourf','fundamentalRegion','halfwidth',5*degree)
hold on
isInformative = angle(c2c) > 1e-3*degree;
plot(c2c(isInformative).axis,'Marker','s','MarkerFaceColor','none',...
  'MarkerEdgeColor','k','MarkerSize',8)
hold off

%%
% Notice that the black squares lie on the main measured axis clusters.
% Fitting an OR is therefore mainly an axis-alignment problem: it rotates the
% parent's symmetry axes onto those observed clusters.
%
% The predicted set also contains the identity rotation at zero degrees.
% It is produced by |S = identity| for every possible OR and carries no
% information about the fit.
% |calcParent2Child| excludes this identity variant.

%% The objective function
%
% For a candidate OR, the residual of each observation is its disorientation
% to the closest informative child-to-child variant.

omega = min(angle_outer(mori,c2c(isInformative)),[],2);

%%
% |calcParent2Child| minimises a trimmed chordal misfit.
% It averages |1 - cos(omega)| over the best |quantile| fraction of the
% observations, which is 90 percent by default.
% This robust objective limits the influence of pairs from different parents.
%
% The misfit is unchanged when |p2c| is multiplied by child symmetry on the
% left or parent symmetry on the right.
% Its search domain is therefore the misorientation fundamental region of the
% phase pair.
% For cubic-to-cubic symmetry its volume is |8*pi^2/(24*24)|, or about 0.137
% radians cubed.
% The domain is only three-dimensional, which makes a complete scan practical.

%% The fixed-point algorithm
%
% Each observation becomes a direct measurement of the OR once a variant has
% been assigned.
% If |mori| exactly equals the variant |c2c(k)|, the following product returns
% |p2cGlobal| itself.

k = 5;
c2c(k) * p2cVariants(k)

%%
% A noisy observation therefore votes for an OR near the true one.
% Averaging many such votes averages away part of the noise.
% One iteration performs four operations:
%
% * assign every misorientation to its closest variant;
% * keep the best |quantile| fraction;
% * form the vote |mori * p2cVariants(k)| for each retained pair; and
% * replace |p2c| by the mean of the votes.
%
% The vote depends on the current |p2c|, so this is a fixed-point iteration
% rather than a descent step.
% The misfit need not decrease at every step.
% The implementation therefore backtracks whenever a full step does not lower
% the objective.

%% Why the iteration converges
%
% Write |p2c = pStar * exp(xi)| for a small error |xi| around the solution.
% A vote from variant |k| has error |R_k' * xi|, where |R_k| is the matrix of
% the corresponding parent symmetry operation.
% One iteration maps the error with
%
% $$A = \sum_k w_k R_k^{\prime},$$
%
% where |w_k| is the fraction assigned to variant |k|.
% The matrix |A| is an average of rotation matrices, so its norm cannot exceed
% one and the local iteration cannot diverge.
%
% For evenly populated variants, the parent-group matrices sum to zero.

R = csParent.properGroup.rot;
Aeven = zeros(3);
for j = 1:length(R)
  Aeven = Aeven + matrix(R(j));
end
norm(Aeven)

%%
% This cancellation follows from group theory.
% The three-dimensional vector representation of the cubic rotation group has
% no copy of the trivial representation.
% A martensitic microstructure usually populates many variants, so the error
% contracts in only a handful of iterations.
%
% Removing the identity operation gives |A = -I/23| for even occupancy.
% Its convergence rate is therefore |1/23| per iteration.
% On this map the variant occupancies range from 1.5 to 12 percent, and the
% measured local rate is about 0.24 per iteration.
%
% The iteration stalls only if |A| has an eigenvalue with modulus one.
% That requires every populated variant to share a common rotation axis.
% Two populated variants with non-parallel axes are enough to rule this out.

%% What the classical damping factor does
%
% Classical implementations average the old and new estimates, using a weight
% |alpha| on the old estimate.
% In the linearised error map this replaces |A| by
%
% $$(\alpha I + A)/(1 + \alpha).$$
%
% An eigenvalue |lambda| becomes |(alpha + lambda)/(1 + alpha)|.
% The damping factor can therefore cancel a negative real eigenvalue exactly.
% This explains the traditional |alpha = 1/numSym(csParent)| default.
% For even occupancy the eigenvalue is |-1/23|, and |1/24| nearly cancels it.
%
% Its benefit depends on the spectrum of |A|:
%
% || occupancy || rho(0) || best alpha || rho(alpha) ||
% || even over all 23 variants || 0.0435 || 0.043 || 0.0000 ||
% || only the 180 degree variants || 0.3333 || 0.334 || 0.0001 ||
% || only the 120 degree variants || 0.0000 || 0.000 || 0.0000 ||
% || only the 90 degree variants || 0.3333 || 0.000 || 0.3333 ||
%
% The last row is the important counterexample.
% Fourfold operations give |A| complex eigenvalues, and a real shift cannot
% move that conjugate pair towards zero.
% Damping treats oscillation along a direction, not rotation between directions.
%
% On this map the eigenvalues are |-0.238|, |-0.099|, and |0.021|.
% Theory predicts that |alpha = 0.11| would roughly halve the asymptotic rate.
% Measured from several starting points, however, no tested damping shortened
% the fit.
% Undamped fits needed 12, 23, and 18 iterations.
% With |alpha = 1/24| they needed 13, 24, and 19 iterations.
% With |alpha = 1/4| they needed 15, 22, and at least 25 iterations.
% The middle |alpha = 1/4| fit had not converged at the iteration cap.
% All runs stopped at the same misfit.
%
% The asymptotic rate governs only the final digits.
% Early iterations are dominated by changing variant assignments and changing
% membership of the trimmed set.
% Damping merely shortens those early steps.
% MTEX therefore leaves the iteration undamped and uses backtracking for steps
% that do not descend.

%% References
%
% * T. Nyyssönen, M. Isakov, P. Peura, and V.-T. Kuokkala,
% <https://doi.org/10.1007/s11661-016-3462-2 Iterative determination of the
% orientation relationship between austenite and martensite from a large
% amount of grain pair misorientations>, _Metallurgical and Materials
% Transactions A_ 47 (2016), 2587-2590, gives the iterative OR-fitting method.
% * T. Nyyssönen, P. Peura, and V.-T. Kuokkala,
% <https://doi.org/10.1007/s11661-018-4904-9 Crystallography, morphology, and
% martensite transformation of prior austenite in intercritically annealed
% high-aluminum steel>, _Metallurgical and Materials Transactions A_ 49 (2018),
% 6426-6441, provides the reconstruction setting used by the example.
