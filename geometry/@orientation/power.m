function ori = power(ori,n)
% power of a misorientation
%
% Description
% Except for n = -1, the inverse, the power is only defined for
% misorientations between the same phase; it is taken of the representative
% in the fundamental region.
%
% Syntax
%
%   mori = mori.^n          % the n-th power
%   mori = mori.^(-1)       % the inverse
%   mori = mori.^2          % the square
%   mori = mori.^[0,1,2,3]  % several powers at once
%
% Input
%  mori - mis@orientation
%  n    - double
%
% Output
%  mori - mis@orientation
%
% See also
% quaternion.log 

if all(n == -1)
  ori = inv(ori);
elseif ori.CS ~= ori.SS
  error('The operation ^ is only applicable for misorientation between the same phase')
else
  ori = power@rotation(ori.project2FundamentalRegion,n);
end
