function [res,info] = discrepancy(SO3F,ori,varargin)
% discrepancy between rotational densities and/or weighted orientation sets
%
% Syntax
%   d = discrepancy(f,g,'metric','D_2')
%   d = discrepancy(f,ori,'metric','D_ball','numCenters',4097)
%   d = discrepancy(f,ori,'metric','L2','bandwidth',16)
%   d2 = discrepancy(f,ori,'metric','L2','bandwidth',16,'squared')
%   [d,info] = discrepancy(f,ori,'metric','D_ball')
%
% Input
%  f,g - scalar real @SO3Fun
%  ori - @rotation or @orientation, representing a weighted probability measure
%
% Output
%  res  - discrepancy (square root for D_2 and L2 unless 'squared')
%  info - method and approximation information; for D_ball also a witness ball
%
% Options
%  metric        - 'D_2' (default), 'D_ball', 'L2' (alias 'E_L'), or 'kernel'
%  weights       - nonnegative point weights, normalized to sum to one
%  bandwidth     - harmonic projection degree for functions and L2 moments;
%                  default max function bandwidth (64 for nonharmonic
%                  functions or orientation/orientation pairs). D_2 and
%                  D_ball retain all atomic mass, including modes above this
%                  bandwidth.
%  degreeWeights - L2 energy weights for degrees 0:L, numeric or function
%                  handle of degree; default one. Degree zero weights the
%                  difference in total mass.
%  numCenters    - D_ball search centers, default 2049, plus the identity and
%                  the atoms; use 'centers',rotation to supply them
%  numRadii      - D_ball uniform radius grid size, default 257; all atomic
%                  jumps and their one-sided limits are also checked
%
% Flags
%  squared - return the square of the standard discrepancy
%
% Description
% B(C,r) = {R : angle(C,R) <= r}. D_ball is sup |(mu-eta)(B(C,r))|.
% D_2^2 integrates this squared difference against normalized center Haar
% measure dR/(8*pi^2) and radius sin(r) dr on [0,pi]. Stolarsky's identity
% turns it into the chordal energy
%
%   D_2^2(nu) = nu(SO(3))^2/2
%                 - 1/(2*sqrt(2)*pi) int int |R-S|_F dnu(R) dnu(S) ,
%
% with |R-S|_F = sqrt(8) sin(omega/2), which is why atomic terms are exact at
% every bandwidth. L2^2 sums squared Haar-orthonormal Wigner moments through
% bandwidth L. All three measure a difference in total mass as well, so
% nothing has to be normalized - an ODF of mean one and integral 8*pi^2 and
% the probability density of integral one describing the same texture differ
% by that factor and the discrepancy says so. Functions keep their own
% integral through the projection; increase the bandwidth to check
% convergence. A sample compared with f is scaled to integral(f), and keeps
% mass one if that integral vanishes; two samples each have mass one. An @orientation represents
% the uniform measure on its orbit of symmetrically equivalent rotations, a
% bare @rotation a single atom - a symmetric density does not symmetrize a
% bare rotation sample.
%
% D_ball uses a finite search: it is a lower-bound approximation for the
% represented measures, not a certified global maximum. info.isExact is
% false, and info.closed=false denotes the open-ball limiting value at the
% reported radius. Orientation space is three dimensional, so a center grid
% resolves it far more coarsely than a grid of the same size resolves the
% sphere and the estimate rises well past the default - refine numCenters and
% numRadii until it settles. Against a peaked density the atoms themselves
% are the decisive centers and the estimate is stable much earlier.
%
% 'kernel' preserves the historical squared, truncated optimalSample
% objective and uses that iteration's transform, so it reproduces it exactly.
% Its degree zero coefficient is negative, so it drops the mass term and
% takes two functions of equal integral only.
% It equals 2*sqrt(2)*pi times the squared D_2 of the harmonically projected
% difference, and it imposes the symmetry of the density on the sample. It is
% NOT maximum ball discrepancy. 'squared' is redundant for this legacy metric.
%
% See also
% rotation/discrepancy SO3Fun/optimalSample

metric = get_option(varargin,'metric','D_2');
if (ischar(metric) || (isstring(metric) && isscalar(metric))) && ...
    strcmpi(metric,'kernel')
  res = legacyDiscrepancy(SO3F,ori,varargin{:});
  info = struct('method','legacy squared truncated kernel','isExact',false);
else
  [res,info] = rotationalDiscrepancy(SO3F,ori,varargin{:});
end
end

function res = legacyDiscrepancy(SO3F,ori,varargin)
% A function without its own bandwidth uses the optimalSample default.
if isa(SO3F,'SO3FunHarmonic'), bw = SO3F.bandwidth; else, bw = 32; end
if isa(ori,'SO3Fun')
  if isa(ori,'SO3FunHarmonic'), bw2 = ori.bandwidth; else, bw2 = 32; end
  bw = max(bw,bw2);
end
bw = get_option(varargin,'bandwidth',bw);
assert(isnumeric(bw) && isscalar(bw) && isreal(bw) && isfinite(bw) && ...
  bw>=0 && bw==fix(bw),'SO3Fun:discrepancy:bandwidth', ...
  'The bandwidth must be a nonnegative integer.');
assert(isscalar(SO3F),'SO3Fun:discrepancy:scalarFunction', ...
  'Discrepancy requires scalar rotational functions.');
if isa(ori,'SO3Fun')
  assert(isscalar(ori),'SO3Fun:discrepancy:scalarFunction', ...
    'Discrepancy requires scalar rotational functions.');
  % Low-bandwidth quadrature of a nonharmonic function can change its mass.
  % Check the original integrals, before projecting to the comparison space.
  masses = [sum(SO3F),sum(ori)];
  % the integral of a nonharmonic function comes from a quadrature grid, so
  % the tolerance is the one of that grid, not of the arithmetic
  assert(all(isfinite(masses)) && abs(diff(masses))<=1e-6*max(abs(masses)), ...
    'SO3Fun:discrepancy:massMismatch', ...
    ['Dropping degree zero only measures a difference if the integrals ' ...
    'agree, these are %g and %g - scale one of them, or use a metric ' ...
    'that keeps the mass.'],masses(1),masses(2));
end

SO3F = SO3FunHarmonic(SO3F,'bandwidth',bw);
SO3F.bandwidth = bw;

if isa(ori,'SO3Fun')
  g = SO3FunHarmonic(ori,'bandwidth',bw);
  g.bandwidth = bw;
  difference = (sqrt(8)*pi)*(g.fhat-SO3F.fhat);
else
  assert(isa(ori,'rotation'),'SO3Fun:discrepancy:input', ...
    'The second input must be an SO3Fun or a rotation set.');
  assert(numel(ori)>0,'SO3Fun:discrepancy:emptySample','Orientation sets must not be empty.');
  c = sampleWeights(numel(ori),varargin{:});
  assert(all(isfinite(c)) && sum(c)>0,'SO3Fun:discrepancy:weights', ...
    'Point weights must be finite and have positive total weight.');

  % the nodes carry the symmetries of the density, as in optimalSample
  ori = orientation(ori(:),SO3F.CS,SO3F.SS);

  % Restore the requested bandwidth in case the highest degrees vanish.
  mu = SO3FunHarmonic.adjointNFSOFT(ori,c,'bandwidth',bw);
  mu.bandwidth = bw;
  difference = (sum(SO3F)/(sqrt(8)*pi))*mu.fhat-(sqrt(8)*pi)*SO3F.fhat;
end

w = kernelWeights(bw);
res = sum(abs(w.*difference).^2);

end
