function [res,info] = discrepancy(rot,w,varargin)
% discrepancy between weighted orientation sets or a rotational density
%
% Syntax
%   d = discrepancy(ori1,ori2,'metric','D_2')
%   [d,info] = discrepancy(ori1,ori2,'metric','D_ball','numCenters',4097)
%   d = discrepancy(ori1,ori2,'metric','L2','bandwidth',16)
%   d = discrepancy(ori1,ori2,'weights',c,'weights2',d,'metric','D_2')
%   d = discrepancy(ori,f,'weights',c,'metric','D_2')
%
% Point weights are nonnegative and normalized independently to mass one.
% An orientation set paired with a density is scaled to the density's
% integral, and keeps mass one if that integral vanishes. A symmetric orientation splits its mass uniformly over the orbit
% of symmetrically equivalent rotations. D_2 is the standard root ball L2
% discrepancy, evaluated without truncating atomic measures and counting a
% difference in total mass. L2 is the root bandlimited norm. Use 'squared'
% for their squares. D_ball is a finite ball-search approximation over a
% three dimensional space; info.isExact is false and the estimate needs
% refinement to settle. 'kernel' is the historical squared truncated
% optimization objective and takes two densities of equal integral only.
% See SO3Fun/discrepancy for all options and normalization conventions.
%
% See also
% SO3Fun/discrepancy SO3Fun/optimalSample

metric = get_option(varargin,'metric','D_2');
if (ischar(metric) || (isstring(metric) && isscalar(metric))) && ...
    strcmpi(metric,'kernel')
  res = legacyDiscrepancy(rot,w,varargin{:});
  info = struct('method','legacy squared truncated kernel','isExact',false);
else
  [res,info] = rotationalDiscrepancy(rot,w,varargin{:});
end
end

function res = legacyDiscrepancy(rot,w,varargin)
if isa(w,'SO3Fun')
  res = discrepancy(w,rot,varargin{:});
  return
end
assert(isa(w,'rotation'),'SO3Fun:discrepancy:input', ...
  'The second input must be an SO3Fun or a rotation set.');
assert(numel(rot)>0 && numel(w)>0,'SO3Fun:discrepancy:emptySample', ...
  'Orientation sets must not be empty.');
bw = get_option(varargin,'bandwidth',32);
assert(isnumeric(bw) && isscalar(bw) && isreal(bw) && isfinite(bw) && ...
  bw>=0 && bw==fix(bw),'SO3Fun:discrepancy:bandwidth', ...
  'The bandwidth must be a nonnegative integer.');
c = sampleWeights(numel(rot),varargin{:});
d = sampleWeights(numel(w),'weights', ...
  get_option(varargin,'weights2',ones(numel(w),1)/numel(w)));
assert(all(isfinite(c)) && all(isfinite(d)) && sum(c)>0 && sum(d)>0, ...
  'SO3Fun:discrepancy:weights', ...
  'Point weights must be finite and have positive total weight.');

if bw==0
  % Both probability measures have only the same constant coefficient.
  f = SO3FunHarmonic(1/(8*pi^2)); g = f;
else
  f = SO3FunHarmonic.adjointNFSOFT(rot(:),c,'bandwidth',bw)/(8*pi^2);
  g = SO3FunHarmonic.adjointNFSOFT(w(:),d,'bandwidth',bw)/(8*pi^2);
  f.bandwidth = bw; g.bandwidth = bw;
  % the transform recovers the known mass only to its own accuracy
  f.fhat(1) = 1/(8*pi^2); g.fhat(1) = 1/(8*pi^2);
end
res = discrepancy(f,g,varargin{:},'bandwidth',bw);

end
