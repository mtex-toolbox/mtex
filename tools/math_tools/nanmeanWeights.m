function y = nanmeanWeights(x,weights,dim)
% weighted mean value ignoring NaNs
%
% Syntax
%
%   y = nanmeanWeights(x,weights)       % along the first non-singleton dimension
%   y = nanmeanWeights(x,weights,dim)   % along dimension dim
%
% Input
%  x       - numeric array
%  weights - numeric array of the size of x
%  dim     - dimension to average along
%
% Output
%  y - weighted mean of the entries of x that are not NaN, NaN where all
%  of them are
%
% See also
% nanmean mean

% only one or two elements 
if isempty(x), y = NaN;	return; end
if isscalar(x), y = x;	return; end

% determine dimension
if nargin < 3, dim = find(size(x)~=1,1,'first'); end
if isempty(dim), dim = 1;	end

% Replace NaNs with zeros.
nans = isnan(x);
x(isnan(x)) = 0; 

% denominator
normalization = sum(weights .* ~nans,dim);

% protect against a  all NaNs in one dimension
normalization(normalization==0) = NaN;

% compute weights mean
y = sum(weights .* x,dim)./normalization;
