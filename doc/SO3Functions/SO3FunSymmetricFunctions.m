%% Symmetry Properties of Orientation Functions
%
%%
% Every <SO3Fun.SO3Fun |SO3Fun|> has a left and a right symmetry. In case
% of ODFs the right symmetry is the <CrystalSymmetries.html crystal
% symmetry> and the left symmetry is the <SpecimenSymmetry.html specimen
% symmetry>.

SO3F = SO3Fun.dubna

cs = SO3F.SRight
ss = SO3F.SLeft

%%
% The function values of |SO3F| are equal at symmetric nodes. Since the
% composition of rotations is not commutative there exists a left and right
% symmetry.

ori = orientation.rand(cs,ss);
SO3F.eval(ori.symmetrise).'
SO3F.eval(ss*ori*cs).'

%%
% The symmetries have, for example, an influence on the plot domain.

plot(SO3F,'sigma')

%%
% * Note that only the fundamental region with respect to the symmetry is
% plotted
% * you can plot the entire orientation space using the argument
% |'complete'|
%
% In most subclasses of <SO3Fun.SO3Fun |SO3Fun|> the symmetries are
% independent from the rest of variables of the function. So one can change
% them very easy and only effects the function values.

SO3F.SLeft = specimenSymmetry('432')

%%
% The class <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|> describes an
% rotational function by the Fourier coefficients of its harmonic series.
% Here it is possible to get the symmetries directly from the fourier
% coefficients. 
% 
% Similarly, if we want to change the symmetry of a function it is not enough
% to change it. We also have to symmetries this function.

SO3F2 = SO3FunHarmonic(rand(1e3,1))
SO3F2.isReal = true
SO3F2.fhat(1:10)

%%

plot(SO3F2)

%%
% Changing the symmetry has no effect on the Fourier coefficients.
% Now we are only plotting the given function on some fundamental region.

SO3F2.SRight = crystalSymmetry('2')
SO3F2.fhat(1:10)

%%

plot(SO3F2)

%%
% Symmetrising the Fourier coefficients transforms the coefficients. So we
% symmetrise the function and it is no longer possible to go back to the
% non symmetrised function from before.

SO3F2 = SO3F2.symmetrise
SO3F2.fhat(1:10)

%%

plot(SO3F2)

%%
% Now the function is symmetrised on the full rotation group.

plot(SO3F2,'complete')

%% 
% Note that you can expand every <SO3Fun.SO3Fun |SO3Fun|> to an
% <SO3FunHarmonic.SO3FunHarmonic |SO3FunHarmonic|>

SO3F3 = SO3FunHarmonic(SO3F)

%%
% and do the same as before.
