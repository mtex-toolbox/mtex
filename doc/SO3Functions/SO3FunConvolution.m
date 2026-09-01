%% Convolution of Rotational and Spherical Functions
%
% Convolution combines two functions by averaging their overlap while one
% argument is rotated. It is used to smooth a function, transfer an
% orientation distribution to directions, and construct rotation-dependent
% similarities. A cross-correlation uses the same machinery but may also
% require inversion or complex conjugation, depending on its convention.
%
% Four combinations occur in MTEX:
%
% || first input || second input || result || compatibility ||
% || @SO3Fun || @SO3Fun || @SO3Fun || first right = second left ||
% || @S2Fun || @S2Fun || @SO3Fun || spherical frames must agree ||
% || @SO3Fun || @S2Fun || @S2Fun || rotational left = spherical symmetry ||
% || @SO3Fun or @S2Fun || matching radial kernel || same domain as function ||
%
% The left and right sides are defined on
% <SO3FunSymmetricFunctions.html Symmetry of Orientation-Dependent
% Functions>. Matching means the same point group in the same reference
% frame, not merely point groups with the same printed name.

plottingConvention.default('y↑→x');

%% Convolve two rotational functions
%
% The inner sides are integrated out. Consequently, the right symmetry of
% the first function must match the left symmetry of the second. The result
% inherits its left symmetry from the first function and its right symmetry
% from the second.

g = SO3FunHarmonic.example;

ss1 = specimenSymmetry;
ss2 = specimenSymmetry('222');
centre = orientation.rand(1,ss1,ss2);
kernel = SO3DeLaValleePoussinKernel('halfwidth',15*degree);
f = SO3FunRBF(centre,kernel);

c = conv(f,g)
resultLeftSymmetry = c.SLeft
resultRightSymmetry = c.SRight

%%
% Here |f.SRight| and |g.SLeft| are both the identity specimen symmetry.
% The result therefore keeps the |222| left symmetry of |f| and the quartz
% right symmetry of |g|.
%
% Check one value against direct numerical integration. The @SO3Fun mean
% uses normalized orientation-space measure, so it implements the factor
% $1/(8\pi^2)$ in the integral stated below.

r = orientation.rand(c.CS,c.SS);
convolutionValue = c.eval(r)
integrand = SO3FunHandle(@(q) ...
  f.eval(q) .* g.eval(inv(q).*r));
integralValue = mean(integrand,'resolution',5*degree)
SO3CheckDifference = abs(convolutionValue - integralValue)

plot(c,'sigma')

%%
% The strongest regions are shifted and broadened copies of the input ODF.
% The maximum drops from about 94 to about 10, the bandwidth from 48 to 17,
% and the peak moves.
%
% The plot covers the fundamental region of the inherited |222| and quartz
% symmetries, so symmetrically equivalent copies are folded into it rather
% than drawn beside one another. The printed difference measures the accuracy
% of the independent, coarser numerical integration used for the check.

%% Swap the argument order
%
% Convolution on the rotation group is not commutative in general. A
% right-sided form can be evaluated by swapping the function order, provided
% the new inner symmetry pair is compatible.

rng(3)
fRight = SO3FunRBF(orientation.rand(1,g.CS,g.CS),kernel);
cRight = conv(g,fRight)

rRight = orientation.rand(cRight.CS,cRight.SS);
rightConvolutionValue = cRight.eval(rRight)
qRight = orientation.rand(100000,stripSym(fRight.SRight), ...
  stripSym(fRight.SLeft));
rightSamples = fRight.eval(qRight) .* g.eval(rRight.*inv(qRight));
rightIntegralEstimate = mean(rightSamples)
rightStandardError = std(rightSamples) / sqrt(numel(rightSamples))
rightCheckDifference = abs(rightConvolutionValue - ...
  rightIntegralEstimate)

%%
% This Monte Carlo estimate checks the right-sided integral written in the
% maths section. Compare its difference with the printed standard error.
% It is not a claim that |conv(f,g)| and |conv(g,f)| are generally equal.
%
% Arrays of @SO3Fun objects may also be convolved. Two arrays are combined
% element by element, as described for
% <SO3FunVectorValued.html vector-valued rotational functions>.

%% Convolve two spherical functions
%
% Rotating one spherical function against another produces a function of
% the rotation, not another spherical function. The output measures their
% overlap for every relative orientation. Its right symmetry comes from the
% first spherical function and its left symmetry from the second.

cs = crystalSymmetry;
sphereF = S2FunHarmonicSym(S2Fun.smiley,cs);
sphereG = S2FunHarmonic(S2DeLaValleePoussinKernel);
sphereCorrelation = conv(sphereF,sphereG)

rSphere = orientation.rand(sphereCorrelation.CS, ...
  sphereCorrelation.SS);
sphereConvolutionValue = sphereCorrelation.eval(rSphere)
sphereIntegrand = S2FunHandle(@(v) ...
  sphereF.eval(inv(rSphere)*v) .* sphereG.eval(v));
sphereGrid = equispacedS2Grid('resolution',1*degree);
sphereIntegralValue = mean(sphereIntegrand.eval(sphereGrid))
sphereCheckDifference = ...
  abs(sphereConvolutionValue - sphereIntegralValue)

plot(sphereCorrelation,'sigma')

%%
% The section plot changes as the smiley pattern moves into and out of
% alignment with the zonal second function. This is why two inputs on the
% sphere produce an output on the rotation group.

%% Convolve a rotational and a spherical function
%
% A rotational function can transport a spherical function through all
% orientations and average the result. The output is spherical. The
% spherical symmetry must match the left symmetry of the rotational
% function, and the output inherits the rotational function's right
% symmetry.

rotF = SO3FunHarmonic.example;
sphereH = S2FunHarmonicSym(S2Fun.smiley,rotF.SLeft);
directionF = conv(rotF,sphereH)

vCrystal = Miller(1,0,0,directionF.CS);
directionValue = directionF.eval(vCrystal)

rng(7)
qDirection = orientation.rand(100000,stripSym(rotF.CS), ...
  rotF.SLeft);
directionSamples = rotF.eval(qDirection) .* ...
  sphereH.eval(qDirection*vCrystal);
directionIntegralEstimate = mean(directionSamples)
directionStandardError = ...
  std(directionSamples) / sqrt(numel(directionSamples))
directionCheckDifference = ...
  abs(directionValue - directionIntegralEstimate)

plot(directionF)

%%
% Bright directions receive large contributions from many orientations
% where both input functions are large. Unlike the preceding section plot,
% this result needs only a direction on the sphere for evaluation.
%
% The Monte Carlo orientations cover the full rotation group. |stripSym|
% removes the quartz point group while retaining its crystal frame. Using a
% symmetry-reduced fundamental region would be invalid for this check,
% because a fixed Miller representative makes the integrand nonsymmetric.
% The check difference should be interpreted against its sampling standard
% error, not as deterministic quadrature error.

%% Use the inverse-action variant
%
% A second convention acts on the spherical argument with the inverse
% rotation. It applies when the rotational function has trivial left
% symmetry and its right symmetry matches the spherical symmetry. Add
% |'inv'|, or equivalently invert the rotational function before calling
% |conv|.

sphereHInv = S2FunHarmonicSym(S2Fun.smiley,rotF.CS);
directionInv = conv(rotF,sphereHInv,'inv');
directionInvEquivalent = conv(inv(rotF),sphereHInv);

vSpecimen = xvector;
inverseActionValue = directionInv.eval(vSpecimen)

rng(5)
qInverse = orientation.rand(100000,stripSym(rotF.CS),rotF.SLeft);
inverseSamples = rotF.eval(qInverse) .* ...
  sphereHInv.eval(inv(qInverse)*vSpecimen);
inverseIntegralEstimate = mean(inverseSamples)
inverseStandardError = ...
  std(inverseSamples) / sqrt(numel(inverseSamples))
inverseActionCheckDifference = ...
  abs(inverseActionValue - inverseIntegralEstimate)

comparisonGrid = equispacedS2Grid('resolution',5*degree);
inverseFlagDifference = max(abs(directionInv.eval(comparisonGrid) - ...
  directionInvEquivalent.eval(comparisonGrid)))

%%
% The small final difference verifies that |'inv'| and
% |conv(inv(rotF),sphereHInv)| implement the same variant. The two action
% conventions should not be mixed: $qv$ and $q^{-1}v$ generally produce
% different averages.

%% Smooth with a rotational kernel
%
% An @SO3Kernel is a radial rotational function: it depends only on the
% rotation angle. Convolution with it attenuates harmonic degrees according
% to the kernel coefficients. Radiality also makes this particular
% convolution commutative, even though convolution of two general
% rotational functions is not.

psi = SO3DeLaValleePoussinKernel('halfwidth',10*degree);
smoothSource = rotF;
smoothSource.bandwidth = min(rotF.bandwidth,psi.bandwidth);
smoothF = conv(smoothSource,psi);
smoothFReverse = conv(psi,smoothSource);
kernelCommutationError = calcError(smoothF,smoothFReverse)

plotSpektra([smoothSource,smoothF],'figSize','small')
legend('before convolution','after convolution')

%%
% The convolved spectrum lies below the original at higher harmonic
% degrees. Those degrees encode rapid angular variation, so their
% attenuation is the spectral signature of smoothing.

%% Smooth with a spherical kernel
%
% An @S2Kernel is a zonal spherical function. Convolving an @S2Fun with it
% produces another @S2Fun and smooths angular variation around every
% direction.

sphericalSource = S2Fun.smiley;
phi = S2DeLaValleePoussinKernel('halfwidth',10*degree);
sphericalSmooth = conv(sphericalSource,phi)

plot(sphericalSmooth)

%%
% The face remains recognizable, while the sharp boundaries of its features
% are softened by the 10 degree kernel.
%
% The same kernel can be regarded as a spherical function and convolved with
% |sphericalSource| to produce an @SO3Fun. The two results agree when the
% direction $v$ and rotation $R$ satisfy $v=R^{-1}e_3$.

v = vector3d.rand;
rKernel = rotation.map(v,zvector);
kernelAsFunction = S2FunHarmonic(phi);
sphericalOnSO3 = conv(sphericalSource,kernelAsFunction);
kernelFormDifference = abs(sphericalSmooth.eval(v) - ...
  sphericalOnSO3.eval(rKernel))

xi = equispacedS2Grid('resolution',1*degree);
sphericalKernelIntegral = ...
  mean(sphericalSource.eval(xi) .* ...
  phi.eval(cos(angle(xi,v).')))
sphericalKernelCheckDifference = ...
  abs(sphericalSmooth.eval(v) - sphericalKernelIntegral)

%% The maths behind convolution
%
% MTEX uses normalized Haar measure. If $\mathrm{d}q$ denotes the usual
% unnormalized measure with volume $8\pi^2$, convolution of compatible
% rotational functions is
%
% $$ (f*g)(R)=\frac{1}{8\pi^2}\int_{\mathrm{SO}(3)}
% f(q)g(q^{-1}R)\,\mathrm{d}q. $$
%
% If $f$ has left symmetry $S_L$ and right symmetry $S_x$, while $g$ has
% left symmetry $S_x$ and right symmetry $S_R$, the result has left
% symmetry $S_L$ and right symmetry $S_R$. Swapping the order gives the
% right-sided form
%
% $$ (g*f)(R)=\frac{1}{8\pi^2}\int_{\mathrm{SO}(3)}
% f(q)g(Rq^{-1})\,\mathrm{d}q. $$
%
% The sphere has volume $4\pi$. For two spherical functions, MTEX uses
%
% $$ (f*g)(R)=\frac{1}{4\pi}\int_{\mathbb S^2}
% f(R^{-1}\xi)g(\xi)\,\mathrm{d}\xi. $$
%
% The two rotational--spherical actions are
%
% $$ (f*h)(\xi)=\frac{1}{8\pi^2}\int_{\mathrm{SO}(3)}
% f(q)h(q\xi)\,\mathrm{d}q $$
%
% and, with |'inv'|,
%
% $$ (f*h)(\xi)=\frac{1}{8\pi^2}\int_{\mathrm{SO}(3)}
% f(q)h(q^{-1}\xi)\,\mathrm{d}q. $$
%
% Finally, a zonal spherical kernel $\psi$ satisfies
%
% $$ (f*\psi)(v)=\frac{1}{4\pi}\int_{\mathbb S^2}
% f(\xi)\psi(\xi\mathbin{\cdot}v)\,\mathrm{d}\xi. $$
%
% Regarding the kernel as the spherical function
% $\psi(\xi\mathbin{\cdot}e_3)$ instead gives an @SO3Fun. Its value at $R$
% equals the spherical result at $v=R^{-1}e_3$. For an @SO3Kernel,
% $\omega(q^{-1}R)=\omega(Rq^{-1})$ explains the special commutativity.

%% References
%
% * P. J. Kostelec and D. N. Rockmore,
% <https://doi.org/10.1007/s00041-008-9013-5 FFTs on the rotation group>,
% _Journal of Fourier Analysis and Applications_ 14 (2008), 145--179,
% develops the Fourier transform on $\mathrm{SO}(3)$ that turns convolution
% into multiplication of Wigner coefficient matrices.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths (1982), gives the harmonic
% framework for ODFs, pole figures, and their rotational integral operators.

%% Next
%
% Continue with <SO3FunVectorValued.html Vector-Valued Functions> to apply
% the elementwise array behaviour introduced above. The following
% <SO3FunVectorField.html Rotational Vector Fields> page extends the domain
% to vector-valued fields with a rotating tangent space.

%#ok<*MINV>
%#ok<*NOPTS>
