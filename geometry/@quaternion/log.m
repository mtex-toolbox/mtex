function tq = log(q,u)
% project a quaternion into the tangential space
%
% Syntax
%   v = log(q)       % tangential vector as vector3d
%   v = log(q,q_ref) % tangential vector as vector3d
%   M = logm(q) % return tangential vector as (skew symmetric) matrix
%
% Input
%  q - @quaternion
%  q_ref - @quaternion
%
% Output
%  v - @vector3d
%
% See also
% expquat 

% if reference point for tangential space is given - rotate
if nargin == 2, q = u' .* q; end

% the logarithm with respect to the identity 
%q = q .* sign(q.a);

omega = 2 * acos(abs(q.a));
denum = sqrt(1-q.a.^2);
omega(denum ~= 0) = omega(denum ~= 0) ./ denum(denum ~= 0);

tq = omega .* vector3d( q.b, q.c, q.d ) .* sign(q.a);
