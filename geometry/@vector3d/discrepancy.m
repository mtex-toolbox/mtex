function [res,info] = discrepancy(v,w,varargin)
% discrepancy between weighted spherical point sets or a spherical density
%
% Syntax
%   d = discrepancy(v,w,'metric','D_2')
%   [d,info] = discrepancy(v,w,'metric','D_cap','numCenters',4097)
%   d = discrepancy(v,w,'metric','L2','bandwidth',32)
%   d = discrepancy(v,w,'weights',c,'weights2',d,'metric','D_2')
%   d = discrepancy(v,f,'weights',c,'metric','D_2')
%
% Point weights are nonnegative and normalized independently to mass one.
% A point set paired with a function is scaled to the function's integral.
% Antipodal points split mass equally between both signs. D_2 is the
% standard root cap L2 discrepancy, evaluated without truncating point
% measures. L2 is the root bandlimited norm. Use 'squared' for their squares.
% D_cap is a finite cap-search approximation; info.isExact is false.
% 'kernel' is the historical squared truncated optimization objective.
% See S2Fun/discrepancy for all options and normalization conventions.
%
% See also
% S2Fun/discrepancy S2Fun/optimalSample

metric = get_option(varargin,'metric','D_2');
if (ischar(metric) || (isstring(metric) && isscalar(metric))) && ...
    strcmpi(metric,'kernel')
  res = legacyDiscrepancy(v,w,varargin{:});
  info = struct('method','legacy squared truncated kernel','isExact',false);
else
  [res,info] = sphericalDiscrepancy(v,w,varargin{:});
end
end

function res = legacyDiscrepancy(v,w,varargin)
if isa(w,'S2Fun')
  res = discrepancy(w,v,varargin{:});
  return
end
assert(isa(w,'vector3d'),'S2Fun:discrepancy:input', ...
  'The second input must be an S2Fun or a vector3d point set.');
assert(numel(v)>0 && numel(w)>0,'S2Fun:discrepancy:emptySample', ...
  'Point sets must not be empty.');
bw = get_option(varargin,'bandwidth',128);
assert(isnumeric(bw) && isscalar(bw) && isreal(bw) && isfinite(bw) && ...
  bw>=0 && bw==fix(bw),'S2Fun:discrepancy:bandwidth', ...
  'The bandwidth must be a nonnegative integer.');
c = sampleWeights(numel(v),varargin{:});
d = sampleWeights(numel(w),'weights', ...
  get_option(varargin,'weights2',ones(numel(w),1)/numel(w)));
assert(all(isfinite(c)) && all(isfinite(d)) && sum(c)>0 && sum(d)>0, ...
  'S2Fun:discrepancy:weights', ...
  'Point weights must be finite and have positive total weight.');

if bw==0
  % Both probability measures have only the same constant coefficient.
  f = S2FunHarmonic(1/sqrt(4*pi)); g = f;
else
  f = S2FunHarmonic.adjointNFSFT(v(:),c,'bandwidth',bw);
  g = S2FunHarmonic.adjointNFSFT(w(:),d,'bandwidth',bw);
  f.bandwidth = bw; g.bandwidth = bw;
end
res = discrepancy(f,g,varargin{:},'bandwidth',bw);

end
