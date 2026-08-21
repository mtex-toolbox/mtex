%% Fitting the Orientation Relationship
%
%%
% The command <calcParent2Child.html |calcParent2Child|> estimates a parent to
% child orientation relationship from the misorientations between neighbouring
% child grains. This page explains what it computes, why the iteration
% converges, and what the damping factor of the classical algorithm actually
% does. The complete derivation is in |docs/adr/0005-parent-to-child-fit.md|.

plottingConvention.default('y↑→x');

%%
% Throughout we use the martensite sample data and the child to child
% misorientations between neighbouring grains.

mtexdata martensite

[grains,ebsd] = calcGrains(ebsd,'angle',3*degree,'minPixel',2,'alpha',12);

job = parentGrainReconstructor(ebsd,grains);
csParent = job.csParent;
csChild = job.csChild;

grainPairs = neighbors(job.grains(csChild));
oriChild = job.grains(grainPairs).meanOrientation;
mori = inv(oriChild(:,1)) .* oriChild(:,2);
mori(mori.angle < 5*degree) = [];

p2c = orientation.KurdjumovSachs(csParent,csChild)

%% The model: child to child misorientations are a conjugated point group
%
% A parent grain of orientation |oriParent| may transform into any of the
% variants |p2c * S|, where |S| runs through the rotations of the parent point
% group. Two child grains grown from the same parent, in variants |i| and |j|,
% are therefore related by

p2cVariants = reshape(p2c.variants,[],1);
c2c = p2c * inv(p2cVariants)

%%
% Writing this out, the misorientation between two child variants is
% |p2c * inv(S) * inv(p2c)| — the parent point group *conjugated by* |p2c|.
% That single formula is the whole model, and it has a consequence which is
% easy to miss: conjugation does not change a rotation angle. The child to
% child variants always carry the angles of the parent point group,

unique(round(angle(c2c,'noSymmetry')./degree))

%%
% which for a cubic parent are 0, 90, 120 and 180 degree. Only their *axes*
% depend on |p2c|. The familiar Kurdjumov-Sachs angles appear only after the
% child symmetry has been used to reduce each misorientation to its
% disorientation,

unique(round(angle(c2c)./degree,2)).'

%%
% Fitting an orientation relationship is thus a problem about axes: rotate the
% parent's symmetry axes until the resulting variants line up with the observed
% misorientations.
%
% Note the first entry, zero. The variant |S = identity| gives |c2c = identity|
% for *every* |p2c|, so it carries no information about the orientation
% relationship at all. |calcParent2Child| excludes it.

%% The objective function
%
% For a candidate |p2c| each observed misorientation gets the residual

omega = min(angle_outer(mori,c2c(angle(c2c) > 1e-3*degree)),[],2);

%%
% i.e. the disorientation to the closest child to child variant. Not every
% neighbouring pair comes from a common parent, so a plain mean would be pulled
% around by the pairs that do not fit. |calcParent2Child| therefore minimises a
% *trimmed* misfit: the mean of |1 - cos(omega)| over the best |quantile|
% fraction of the observations, 90 percent by default.

close all
histogram(omega./degree)
xlabel('disorientation to the closest variant')

%%
% The search domain is small. The misfit is unchanged when |p2c| is multiplied
% by a child symmetry on the left or a parent symmetry on the right, so it
% really lives on the misorientation fundamental zone of the phase pair, of
% volume |8*pi^2/(24*24)| for cubic to cubic — three dimensions, and about
% 0.137 in units of radian cubed.

%% The algorithm
%
% Each observation, *together with an assumed variant*, is a direct measurement
% of |p2c|. If |mori| were exactly the variant |c2c(k)|, then

k = 5;
c2c(k) * p2cVariants(k)

%%
% returns |p2c| itself, because |c2c(k) = p2c * inv(p2cVariants(k))| by
% construction. A noisy observation therefore votes for a |p2c| close to the
% true one, and averaging the votes averages the noise away.
% So the iteration is
%
% # assign every misorientation to its closest variant,
% # keep the best |quantile| fraction of them,
% # form the vote |mori * p2cVariants(k)| for each,
% # replace |p2c| by the mean of the votes.
%
% This is a fixed point iteration, not a descent step, because the vote itself
% depends on the current |p2c|. That distinction matters: the misfit is not
% guaranteed to fall at every step, which is why the implementation keeps a
% backtracking safeguard.

%% Why it converges
%
% Write |p2c = pStar * exp(xi)| for a small error |xi| about the solution. A
% short calculation turns the vote into |pStar * exp(R_k' * xi)|, with |R_k| the
% matrix of the parent symmetry operation |S_k|. Averaging over the assigned
% observations, one iteration maps the error by the matrix
%
%   A = sum_k w_k * R_k'
%
% where |w_k| is the fraction of observations assigned to variant |k|. Every
% property of the iteration follows from |A|.
%
% First, |A| is an average of rotation matrices, so its norm never exceeds one:
% the iteration cannot diverge. Second, and this is why the method works at all,
% for evenly populated variants |A| vanishes *exactly*:

R = csParent.properGroup.rot;
A = zeros(3);
for j = 1:length(R), A = A + matrix(R(j)); end
norm(A)

%%
% The reason is group theory rather than luck: the three dimensional vector
% representation of the cubic rotation group contains no copy of the trivial
% representation, so its elements sum to zero. A martensitic microstructure
% populates many variants, so |A| is small and the error collapses in a handful
% of steps.
%
% Excluding the identity variant leaves |A = -I/23| for even occupancy, a
% convergence rate of |1/23| per step. On real data the occupancies are far from
% even — they range from 1.5 to 12 percent here — and the measured rate is about
% 0.24 per step, still fast.
%
% The iteration only stalls when |A| has an eigenvalue of modulus one, which
% requires every populated variant to share a common rotation axis. Two
% populated variants with non parallel axes are enough to rule that out.

%% The damping factor
%
% Classical implementations replace the new estimate by a weighted mean of the
% old and the new one, with a weight |alpha| on the old. In the error map this
% is not a heuristic at all, it is a relaxation parameter:
%
%   A  ->  (alpha*I + A) / (1 + alpha)
%
% An eigenvalue |lambda| of |A| becomes |(alpha + lambda)/(1 + alpha)|, so
% |alpha| is exactly the shift that annihilates a *negative real* eigenvalue.
% This explains the traditional default |alpha = 1/numSym(csParent)|: for evenly
% populated variants the eigenvalue is |-1/23|, and |1/24| very nearly cancels
% it. The folklore value was the right one.
%
% Whether damping is worth anything depends entirely on the spectrum of |A|:
%
%  occupancy                    rho(0)    best alpha    rho(alpha)
%  even over all 23 variants    0.0435    0.043         0.0000
%  only the 180 degree ones     0.3333    0.334         0.0001
%  only the 120 degree ones     0.0000    0.000         0.0000
%  only the  90 degree ones     0.3333    0.000         0.3333
%
% The last row is the interesting one. Concentrating on the fourfold operations
% gives |A| *complex* eigenvalues, and a real shift cannot move a conjugate pair
% towards zero — no |alpha| helps. Damping is a cure for oscillation along a
% direction, not for rotation between directions.
%
% On this dataset the eigenvalues are |-0.238|, |-0.099| and |0.021|, so theory
% predicts that |alpha = 0.11| would roughly halve the asymptotic rate. Measured
% against iteration counts, it does not: from several starting points, undamped
% needs 12, 23 and 18 iterations, |alpha = 1/24| needs 13, 24 and 19, and
% |alpha = 1/4| needs 15, 22 and at least 25 — the middle case had not
% converged when the iteration cap was reached. All of them stop at the same
% misfit.
%
% The explanation is that the asymptotic rate governs only the last digits. The
% iteration count is dominated by the early phase, in which the variant
% assignment and the trimmed set are still changing, and there damping is
% nothing but a shorter step. MTEX therefore does not damp by default, and
% relies on the backtracking safeguard for the steps that do not descend.

%% Local and global fits
%
% The iteration is local. It converges to a stationary point of the misfit, not
% to the best one, and on real data the starting point decides which.

p2cKS = calcParent2Child(mori,orientation.KurdjumovSachs(csParent,csChild))

%%
% Scanning the entire fundamental zone finds a relationship a good degree away
% from this one, and fitting it better. The |'global'| option does that scan
% instead of trusting the initial guess.

p2cGlobal = calcParent2Child(mori,p2c,'global')

%%
% The two differ by

angle(p2cKS,p2cGlobal)./degree

%%
% degree, which is far from negligible once habit planes are computed from the
% result. Nishiyama-Wassermann, Pitsch and Greninger-Trojano all reach the
% better basin from the start; Kurdjumov-Sachs does not. Use |'global'| whenever
% the orientation relationship itself is the result, and the local fit when
% refining a relationship you already trust.
