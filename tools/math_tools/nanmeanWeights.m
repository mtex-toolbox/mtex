function y = nanmeanWeights(x,weights,dim)
% FORMAT: Y = NANMEAN(X,DIM)
% 
%    Average or mean value ignoring NaNs
%
%    This function enhances the functionality of NANMEAN as distributed in
%    the MATLAB Statistics Toolbox and is meant as a replacement (hence the
%    identical name).  
%
%    NANMEAN(X,DIM) calculates the mean along any dimension of the N-D
%    array X ignoring NaNs.  If DIM is omitted NANMEAN averages along the
%    first non-singleton dimension of X.
%
%    Similar replacements exist for NANSTD, NANMEDIAN, NANMIN, NANMAX, and
%    NANSUM which are all part of the NaN-suite.
%
%    See also MEAN

% only one or two elements 
if isempty(x), y = NaN;	return; end
if length(x)==1, y = x;	return; end

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
