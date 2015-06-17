function tq = log(q)
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

ind = q.a < 0;
q.a(ind) = -q.a(ind);
q.b(ind) = -q.b(ind);
q.c(ind) = -q.c(ind);
q.d(ind) = -q.d(ind);


omega = 2 * acos(q.a) ./ sqrt(1-q.a.^2);
tq = [omega(:) .* q.b(:),omega(:) .* q.c(:),omega(:) .* q.d(:)];
