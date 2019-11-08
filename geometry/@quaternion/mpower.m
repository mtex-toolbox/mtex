function q = mpower(q,n)
% q^n
%
% Syntax
%   q = q^n
%
% q = q^(-1)
% q = q^2
% q = q^[0,1,2,3]
%
%
% Input
%  q - @quaternion
%
% Output
%  q - @quaternion 
%
% See also
% quaternion/ctranspose

q = power(q,n);
