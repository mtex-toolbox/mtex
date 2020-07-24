function v = log(q,q_ref,varargin)
% the logarithmic map that translates a rotation into a rotation vector
%
% Syntax
%   v = log(q) % rotation vector with reference to the identical rotation
%   v = log(q,q_ref) % rotation vector with reference q_ref
%
%   v = loq(q,'right')
%   v = loq(q,'left')
%
% Input
%  q - @quaternion
%  q_ref - @quaternion
%
% Output
%  v - @vector3d
%
% See also
% quaternion/logm vector3d/exp spinTensor/spinTensor

% if reference point for tangential space is given - rotate
if nargin >= 2
  if check_option(varargin,'left')
    %q = q .* q_ref';
    q = itimes(q, q_ref,false);
  else
    %q = times(q_ref', q,1);
    q = itimes(q_ref, q,true);
  end
end

% the logarithm with respect to the identity 
a = min(q.a,1);
omega = 2 * sign(a) .* acos(abs(a));
denum = sqrt(1-a.^2);
denum(denum == 0) = inf;
omega = omega ./ denum;

v = vector3d(omega .* q.b, omega .* q.c, omega .* q.d);
