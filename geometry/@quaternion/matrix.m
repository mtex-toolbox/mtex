function mat = matrix(q)
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

a = reshape(q.a,[1 1 length(q)]);
b = reshape(q.b,[1 1 length(q)]);
c = reshape(q.c,[1 1 length(q)]);
d = reshape(q.d,[1 1 length(q)]);

z = zeros([1 1 length(q)]);

mat = 2 * [b .* b b .* c b .* d;...
  c .* b c .* c c .* d; ...
  d .* b d .* c d .* d] ...
  + 2 * repmat(a,3,3) .* [z -d c; d z -b; -c b z] ...
  + repmat(2*a.^2 - 1,3,3) .* repmat(eye(3),[1 1 length(q)]);
