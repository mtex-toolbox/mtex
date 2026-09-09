function [res,info] = discrepancy(sF,v,varargin)
% discrepancy between spherical densities and/or weighted point sets
%
% Syntax
%   d = discrepancy(f,g,'metric','D_2')
%   d = discrepancy(f,v,'metric','D_cap','numCenters',4097)
%   d = discrepancy(f,v,'metric','L2','bandwidth',32)
%   d2 = discrepancy(f,v,'metric','L2','bandwidth',32,'squared')
%   [d,info] = discrepancy(f,v,'metric','D_cap')
%
% Input
%  f,g - scalar real @S2Fun with equal integrals
%  v   - @vector3d, representing a weighted probability measure
%
% Output
%  res  - discrepancy (square root for D_2 and L2 unless 'squared')
%  info - method and approximation information; for D_cap also a witness cap
%
% Options
%  metric        - 'D_2' (default), 'D_cap', 'L2' (alias 'E_L'), or 'kernel'
%  weights       - nonnegative point weights, normalized to sum to one
%  bandwidth     - harmonic projection degree for functions and L2 moments;
%                  default max function bandwidth (128 for nonharmonic
%                  functions or point/point pairs). D_2 and D_cap retain
%                  all atomic mass, including modes above this bandwidth.
%  degreeWeights - L2 energy weights for degrees 0:L, numeric or function
%                  handle of degree; default one. Degree zero is omitted.
%  numCenters    - D_cap search centers, default 2049, plus coordinate axes
%                  and point supports; use 'centers',vector3d to supply them
%  numHeights    - D_cap uniform height grid size, default 257; all atomic
%                  jumps and their one-sided limits are also checked
%
% Flags
%  squared - return the square of the standard discrepancy
%
% Description
% C(m,t) = {x : dot(m,x) >= t}. D_cap is sup |(mu-eta)(C(m,t))|.
% D_2^2 integrates this squared difference against normalized center area
% dS(m)/(4*pi) and height dt on [-1,1] (angular radius: sin(r) dr).
% L2^2 sums squared area-orthonormal harmonic moments through bandwidth L.
% Functions are projected to bandwidth; increase it to check convergence.
% Equal original masses are required and preserved during projection.
% A sample compared with f is scaled to integral(f); two samples each have
% mass one. An antipodal point set represents half mass at each +/- point.
% An even function does not suppress odd moments of a directed sample.
%
% D_cap uses a finite search: it is a lower-bound approximation for the
% represented measures, not a certified global maximum. Increase centers
% and heights to check convergence. info.isExact is false. info.closed=false
% denotes the open-cap/one-sided limiting value at the reported height.
% D_2 uses exact chordal distances for atomic terms (quadratic point cost)
% and harmonic coefficients for continuous terms.
%
% 'kernel' preserves the historical squared, truncated optimalSample
% objective and its antipodal convention. Without that odd-mode projection,
% it equals four times the squared D_2 of the harmonically projected
% difference. It is NOT maximum cap discrepancy. 'squared' is redundant
% for this legacy metric. See tests/S2Discrepancies.md for details.
%
% See also
% vector3d/discrepancy S2Fun/optimalSample

metric = get_option(varargin,'metric','D_2');
if (ischar(metric) || (isstring(metric) && isscalar(metric))) && ...
    strcmpi(metric,'kernel')
  res = legacyDiscrepancy(sF,v,varargin{:});
  info = struct('method','legacy squared truncated kernel','isExact',false);
else
  [res,info] = sphericalDiscrepancy(sF,v,varargin{:});
end
end

function res = legacyDiscrepancy(sF,v,varargin)
% A function without its own bandwidth uses the optimalSample default.
if isa(sF,'S2FunHarmonic'), bw = sF.bandwidth; else, bw = 128; end
if isa(v,'S2Fun')
  if isa(v,'S2FunHarmonic'), bw2 = v.bandwidth; else, bw2 = 128; end
  bw = max(bw,bw2);
end
bw = get_option(varargin,'bandwidth',bw);
assert(isnumeric(bw) && isscalar(bw) && isreal(bw) && isfinite(bw) && ...
  bw>=0 && bw==fix(bw),'S2Fun:discrepancy:bandwidth', ...
  'The bandwidth must be a nonnegative integer.');
assert(isscalar(sF),'S2Fun:discrepancy:scalarFunction', ...
  'Discrepancy requires scalar spherical functions.');
if isa(v,'S2Fun')
  assert(isscalar(v),'S2Fun:discrepancy:scalarFunction', ...
    'Discrepancy requires scalar spherical functions.');
  % Low-bandwidth quadrature of a nonharmonic function can change its mass.
  % Check the original integrals, before projecting to the comparison space.
  masses = [sum(sF),sum(v)];
  assert(all(isfinite(masses)) && abs(diff(masses))<=1e-10*max(abs(masses)), ...
    'S2Fun:discrepancy:massMismatch', ...
    'The functions must have equal integrals. Normalize probability densities to integral one.');
end

sF = S2FunHarmonic(sF,'bandwidth',bw);
sF.bandwidth = bw;

if isa(v,'S2Fun')
  v = S2FunHarmonic(v,'bandwidth',bw);
  v.bandwidth = bw;
  antipodal = sF.antipodal && v.antipodal;
  difference = v.fhat-sF.fhat;
else
  assert(isa(v,'vector3d'),'S2Fun:discrepancy:input', ...
    'The second input must be an S2Fun or a vector3d point set.');
  assert(numel(v)>0,'S2Fun:discrepancy:emptySample','Point sets must not be empty.');
  c = sampleWeights(numel(v),varargin{:});
  assert(all(isfinite(c)) && sum(c)>0,'S2Fun:discrepancy:weights', ...
    'Point weights must be finite and have positive total weight.');

  antipodal = sF.antipodal;

  % Restore the requested bandwidth in case the highest degrees vanish.
  mu = S2FunHarmonic.adjointNFSFT(v(:),c,'bandwidth',bw);
  mu.bandwidth = bw;
  difference = sum(sF)*mu.fhat-sF.fhat;
end

w = kernelWeights(bw,antipodal);
res = sum(abs(w.*difference).^2);

end
