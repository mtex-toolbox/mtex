function r = power(r,n)
% r.^n
%
% Syntax
%
% r = r^(-1)
% r = r.^2
% r = r.^[0,1,2,3]
%
%
% Input
%  r - @rotation
%
% Output
%  r - @rotation
%
% See also
% rotation/log 

r = power@quaternion(r,n);

% change inversion
r.i = (1-(1-2*r.i).^n)./2;
