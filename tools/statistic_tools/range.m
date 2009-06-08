function y = range(x,dim)
%RANGE  Sample range.
%  Y = RANGE(X) returns the range of the values in X.  For a vector input,
%  Y is the difference between the maximum and minimum values.  For a
%  matrix input, Y is a vector containing the range for each column.  For
%  N-D arrays, RANGE operates along the first non-singleton dimension.
%
%  RANGE treats NaNs as missing values, and ignores them.
%
%  Y = RANGE(X,DIM) operates along the dimension DIM.
%
%
%  Copyright 1993-2004 The MathWorks, Inc.
%  $Revision: 2.8.2.3 $  $Date: 2004/07/05 17:03:18 $

if nargin < 2
  y = max(x) - min(x);
else
  y = max(x,[],dim) - min(x,[],dim);
end
