function q = expquat(tq)
% matrix exponential to convert skew symmetric matrices into quaternions
%
% Syntax
%   q = expquat(mat)
%
% Input
%  a12,a13,a23 - the matrix entries of the skew symmetric matrix
%
% Output
%  q - @quaternion
%
% See also
%
% quaternion_matrix Euler axis2quat hr2quat
%
% Description

tq = reshape(tq,[],3);
omega = sqrt(sum(tq.^2,2));
a = cos(omega./2);
b = tq(:,1) .* sin(omega./2) ./ omega;
c = tq(:,2) .* sin(omega./2) ./ omega;
d = tq(:,3) .* sin(omega./2) ./ omega; 
q =  quaternion(a,b,c,d);
