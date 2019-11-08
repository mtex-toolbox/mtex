function rot = power(rot,n)
% r.^n
%
% Syntax
%   rot = rot^(-1) % inverse rotation
%   rot = rot.^2
%   rot = rot.^[0,1,2,3]
%
%
% Input
%  rot - @rotation
%
% Output
%  rot - @rotation
%
% See also
% rotation/log 

rot = power@quaternion(rot,n);

% change inversion
rot.i = (1-(1-2*rot.i).^n)./2;
