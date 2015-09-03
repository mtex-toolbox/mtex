function tq = log(q,u)
% quaternion to direction cosine matrix conversion
% converts direction cosine matrix to quaternion
%
% Syntax
%   mat = matrix(q)
%
% Input
%  q - @quaternion
%
% Output
%  mat - vector of matrixes
%
% See also
% mat2quat Euler axis2quat hr2quat

if nargin == 2
  tq = reshape(vector3d(log(u'.*q)'),size(q));
  return
end

q = q .* sign(q.a);

omega = 2 * acos(q.a);
denum = sqrt(1-q.a.^2);
omega(denum ~= 0) =  omega(denum ~= 0) ./ denum(denum ~= 0);

tq = [omega(:) .* q.b(:),omega(:) .* q.c(:),omega(:) .* q.d(:)];
