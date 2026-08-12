function check_calcDensityEmpty
% check density estimation from an empty or all nan list of orientations
%
% Both used to be handled by an early return of ODF(cs,ss) - the obsolete
% pre 5.9 shim, which no longer takes those arguments - so calcDensity on an
% empty list died with "Too many input arguments", while a list of nothing
% but nan orientations slipped past that guard and came out as the zero
% function, which is not a density at all.
%
% The two are the same situation: after the nan orientations are dropped
% there is nothing left to estimate from. Both now return the uniform ODF.

cs = crystalSymmetry('m-3m');

checkUniform('orientations, empty',   orientation.rand(0,cs));
checkUniform('orientations, all nan', orientation.nan(5,1,cs));

% misorientations take the harmonic path rather than the RBF one
checkUniform('misorientations, empty',   orientation.rand(0,cs,cs));
checkUniform('misorientations, all nan', orientation.nan(5,1,cs,cs));

% the two estimators directly, so this does not depend on how calcDensity
% happens to dispatch
checkUniform('calcKernelODF',  orientation.rand(0,cs), @calcKernelODF);
checkUniform('calcFourierODF', orientation.rand(0,cs), @calcFourierODF);

checkNotUniform;

disp('check_calcDensityEmpty: passed');

end

% =========================================================================
function checkUniform(name,ori,fun)

if nargin < 3, fun = @calcDensity; end

odf = fun(ori);

assert(isa(odf,'SO3Fun'), ...
  'check_calcDensityEmpty: %s returned a %s, not an SO3Fun', name, class(odf))

assert(abs(mean(odf) - 1) < 1e-10, ...
  'check_calcDensityEmpty: %s has mean %g, a density has mean 1', name, mean(odf))

assert(abs(max(odf) - 1) < 1e-6 && abs(min(odf) - 1) < 1e-6, ...
  'check_calcDensityEmpty: %s is not constant, it ranges over [%g %g]', ...
  name, min(odf), max(odf))

assert(odf.CS == ori.CS && odf.SS == ori.SS, ...
  'check_calcDensityEmpty: %s lost the symmetry of its input', name)

end

% -------------------------------------------------------------------------
function checkNotUniform
% a few nan orientations among real ones must not swallow the real ones

cs = crystalSymmetry('m-3m');
rng(0)
ori = [orientation.nan(3,1,cs); orientation.rand(50,cs)];

odf = calcDensity(ori);

assert(abs(mean(odf) - 1) < 1e-10, ...
  'check_calcDensityEmpty: a partly nan list gives mean %g', mean(odf))

assert(max(odf) > 2, ...
  'check_calcDensityEmpty: a partly nan list came out uniform, max is only %g', max(odf))

end
