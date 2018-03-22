function d = det3(M)
% determinant of a list of 3x3 matrices
%
% Syntax
%
%   d = det3(M)
%
% Input
%  M - array of 3x3 matrix
%
% Output
%  d - double
%

d = M(1,1,:) .* (M(2,2,:) .* M(3,3,:) - M(2,3,:) .* M(3,2,:)) - ...
  M(2,1,:) .* (M(1,2,:) .* M(3,3,:) - M(1,3,:) .* M(3,2,:)) + ...
  M(3,1,:) .* (M(1,2,:) .* M(2,3,:) - M(1,3,:) .* M(2,2,:));

s = [size(M),1,1];
d = reshape(d,s(3:end));