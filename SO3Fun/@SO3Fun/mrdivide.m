function SO3F = mrdivide(SO3F,s)
% implements SO3F / alpha
%
% See also

SO3F = times(SO3F,inv(s));
