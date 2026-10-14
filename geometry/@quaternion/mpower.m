function q = mpower(q,n)
% power of a quaternion
%
% Syntax
%
%   q = q^n           % the n-th power
%   q = q^(-1)        % the inverse
%   q = q^[0,1,2,3]   % the powers 0, 1, 2 and 3 of a single quaternion
%
% Input
%  q - @quaternion
%  n - double
%
% Output
%  q - @quaternion
%
% See also
% quaternion/power quaternion/ctranspose

q = power(q,n);
