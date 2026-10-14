function y = nanmean(x,dim)
% mean value ignoring NaNs
%
% Syntax
%
%   y = nanmean(x)       % along the first non-singleton dimension
%   y = nanmean(x,dim)   % along dimension dim
%
% Input
%  x   - numeric array
%  dim - dimension to average along
%
% Output
%  y - mean of the entries of x that are not NaN, NaN where all of them are
%
% See also
% mean nanmeanWeights

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

% -------------------------------------------------------------------------
%    author:      Jan Gl�scher
%    affiliation: Neuroimage Nord, University of Hamburg, Germany
%    email:       glaescher@uke.uni-hamburg.de
%    
%    $Revision: 1.1 $ $Date: 2004/07/15 22:42:13 $

% only one or two elements -> nan
if isempty(x), y = NaN;	return; end
if isscalar(x), y = x;	return; end

if nargin < 2, dim = min(find(size(x)~=1)); end
if isempty(dim), dim = 1;	end

% Replace NaNs with zeros.
nans = isnan(x);
x(isnan(x)) = 0; 

% denominator
count = sum(~nans,dim);

% Protect against a  all NaNs in one dimension
count(count == 0) = NaN;

% perform summation
y = sum(x,dim)./count;

% $Id: nanmean.m,v 1.1 2004/07/15 22:42:13 glaescher Exp glaescher $
