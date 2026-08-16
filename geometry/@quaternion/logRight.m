function out = logRight(q, q_ref)
% the logarithmic map that translates a rotation into a tangent vector.
%
% Therefore it converts a given rotation, relative to a reference rotation, 
% into its corresponding tangent vector in the tangent space at the 
% reference. 
% Hence, the log-function computes the relative rotation.
%
% Syntax
%   v = log(q) % rotation vector with reference to the identical rotation
%   v = log(q,q_ref) % rotation vector with reference q_ref
%
% Input
%  q - @quaternion
%  q_ref - @quaternion
%
% Output
%  v - @SO3TangentVector, @spinTensor
%
% See also
% quaternion/logm orientation/log vector3d/exp spinTensor/spinTensor

q = itimes(q_ref, q,true); % inv(q_ref) .* q


% the logarithm with respect to the identity 
a = min(q.a,1);
omega = 2 * sign(a) .* acos(abs(a));
denum = sqrt(1-a.^2);
denum(denum == 0) = inf;
omega = omega ./ denum;

out = vector3d(omega .* q.b, omega .* q.c, omega .* q.d);

end