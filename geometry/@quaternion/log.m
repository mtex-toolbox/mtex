function [a12,a13,a23] = log(q)
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

% TODO: make this faster

mat = matrix(q);
a12 = zeros(size(q));
a13 = zeros(size(q));
a23 = zeros(size(q));

for i = 1:length(q)  
  lm = logm(mat(:,:,i));
  a12(i) = lm(1,2);
  a13(i) = lm(1,3);
  a23(i) = lm(2,3);
end