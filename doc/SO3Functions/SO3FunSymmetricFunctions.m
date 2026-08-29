%% Symmetry of Orientation-Dependent Functions
%
% A rotational function can repeat under symmetry operations on either side
% of its argument. Every @SO3Fun therefore stores a right symmetry
% |SRight| and a left symmetry |SLeft|. For an orientation distribution
% function (ODF), the right side is the crystal symmetry and the left side
% is the specimen symmetry.
%
% Symmetry is the point group under which the data is invariant. It is not
% a reference frame. Each stored symmetry is attached to the reference
% frame of its side, so replacing a symmetry may also change which frame
% the function reports.

plottingConvention.default('y↑→x');
SO3F = SO3Fun.dubna

cs = SO3F.SRight
ss = SO3F.SLeft

%%
% |CS| and |SS| are convenient aliases for |SRight| and |SLeft|. The Dubna
% ODF has quartz crystal symmetry |321| on the right and no specimen
% symmetry on the left.

%% Left and right actions
%
% If $s_L$ belongs to |SLeft| and $s_R$ belongs to |SRight|, a symmetric
% function satisfies
%
% $$ f(s_L R s_R)=f(R). $$
%
% Rotation composition is not commutative, so the two point groups cannot
% be exchanged. <orientation.symmetrise.html |symmetrise|> constructs the
% complete orbit $s_L R s_R$ of an orientation.

ori = orientation.rand(cs,ss);
equivalentOrientations = ori.symmetrise;
equivalentValues = SO3F.eval(equivalentOrientations);
maximumOrbitDifference = ...
  max(abs(equivalentValues - SO3F.eval(ori)))

manualOrbit = ss * ori * cs;
manualOrbitValues = SO3F.eval(manualOrbit);
manualConstructionDifference = ...
  max(abs(sort(equivalentValues(:)) - sort(manualOrbitValues(:))))

%%
% Both printed differences are at numerical precision. The first verifies
% that all symmetry-equivalent orientations have the same density. The
% second verifies that left multiplication by |ss| and right multiplication
% by |cs| construct the same orbit as |ori.symmetrise|.

%% Symmetry reduces the plot domain
%
% By default, MTEX plots only one fundamental region. A fundamental region
% contains one representative from every symmetry-equivalent orbit.

plot(SO3F,'sigma')

%%
% The displayed sigma sections stop at the boundary of the quartz
% fundamental region. This smaller domain avoids showing repeated copies;
% it does not discard part of the ODF. Every orientation left outside the
% picture has an equivalent inside it, carrying the same density.

%% A symmetry label is not a projection
%
% In most @SO3Fun representations, the symmetry properties are stored
% separately from coefficients, centres, or other model parameters. This
% makes reassignment easy, but it does not mean that arbitrary stored data
% automatically has the newly claimed invariance.
%
% The effect of reassignment depends on the representation. For an RBF
% model it changes which symmetry-related kernel copies contribute to an
% evaluation. For a harmonic model it leaves the Fourier coefficients
% untouched until the function is explicitly symmetrised.
%
% On an ODF, assign a @specimenSymmetry to the left side. A general
% rotational function may instead describe a relation between two crystal
% sides, for which an assignment such as the following is meaningful:
%
%   SO3F.SLeft = crystalSymmetry('432');
%
% Applying that line to the Dubna ODF would change its physical meaning. It
% would no longer describe quartz orientations relative to an unsymmetric
% specimen frame.

%% Relabel harmonic coefficients
%
% Construct a reproducible real-valued harmonic function without a
% nontrivial point-group symmetry. Its random coefficients make violations
% of a proposed twofold symmetry easy to detect.

rng(1)
SO3F2 = SO3FunHarmonic(randn(1000,1));
SO3F2.isReal = true;
coefficientsBefore = SO3F2.fhat;

twoFold = crystalSymmetry('2');
SO3F2.SRight = twoFold;
coefficientChangeAfterRelabelling = ...
  norm(SO3F2.fhat - coefficientsBefore)

%%
% The zero coefficient change confirms that assignment only relabelled the
% existing series. Test the claimed invariance at a random orientation and
% its twofold orbit.

probe = orientation.rand(twoFold,SO3F2.SLeft);
probeOrbit = probe.symmetrise;
valuesBeforeProjection = SO3F2.eval(probeOrbit);
orbitSpreadBeforeProjection = ...
  max(abs(valuesBeforeProjection - valuesBeforeProjection(1)))

plot(SO3F2)

%%
% The nonzero orbit spread shows that the relabelled coefficients do not
% yet define a twofold-symmetric function. The plot uses the newly labelled
% fundamental region, so a smaller plot domain is not evidence of actual
% invariance.

%% Project onto symmetric functions
%
% <SO3FunHarmonic.symmetrise.html |SO3FunHarmonic.symmetrise|> averages the
% function over its left and right point groups. In coefficient space this
% projects the Fourier coefficients onto the subspace with the requested
% invariance.

SO3F2Sym = SO3F2.symmetrise;
relativeCoefficientChange = ...
  norm(SO3F2Sym.fhat - SO3F2.fhat) / norm(SO3F2.fhat)

valuesAfterProjection = SO3F2Sym.eval(probeOrbit);
orbitSpreadAfterProjection = ...
  max(abs(valuesAfterProjection - valuesAfterProjection(1)))

plot(SO3F2Sym)

%%
% The coefficients now change, while the orbit spread falls to numerical
% precision. Features that disagreed between symmetry-related orientations
% have been averaged. This projection loses their differences, so the
% original nonsymmetric function cannot be recovered from |SO3F2Sym|.

plot(SO3F2Sym,'complete')

%%
% In the complete plot, every twofold-related position now carries the same
% value. This visual repetition and the small printed orbit spread test the
% same property in complementary ways.
%
% Harmonic invariance is encoded directly in the Fourier coefficients.
% Changing only |SRight| or |SLeft| does not encode it; applying
% |symmetrise| does.

%% Convert another representation before projection
%
% Every @SO3Fun can be expanded as an @SO3FunHarmonic. The constructor uses
% the quadrature procedure from <SO3FunQuadrature.html Quadrature of
% Orientation-Dependent Functions> when the representation offers nothing
% quicker. The Dubna ODF is an @SO3FunRBF and takes its own route, from its
% centres and kernel. Either way the same explicit projection can then be
% applied.

SO3F3 = SO3FunHarmonic(SO3F,'bandwidth',14)

%%
% |SO3F3| inherits the left and right symmetries of the Dubna ODF. Because
% the source is already invariant, its computed coefficients are
% symmetrised during construction. Calling |SO3F3.symmetrise| again would
% therefore leave it unchanged apart from numerical accuracy.

%% The maths behind symmetrisation
%
% Let $G_L$ and $G_R$ be the proper rotations in the left and right point
% groups. Symmetrisation replaces a function $f$ by the group average
%
% $$ f_{\mathrm{sym}}(R)=\frac{1}{\lvert G_L\rvert\lvert G_R\rvert}
% \sum_{s_L\in G_L}\sum_{s_R\in G_R}f(s_L R s_R). $$
%
% Applying any member of either group merely permutes the terms in the sum.
% The averaged function therefore has the required left and right
% invariance. Components that are incompatible with the point groups cancel,
% which explains both the coefficient change and the loss of information.

%% References
%
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths (1982), develops crystal and
% specimen symmetry for ODFs and their generalized harmonic coefficients.

%% Next
%
% Continue with <SO3FunConvolution.html Convolution> to combine rotational
% functions. The left and right sides introduced here determine whether two
% functions can be convolved and which symmetries the result inherits.

%#ok<*NOPTS>
