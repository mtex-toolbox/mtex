function d = dot_outer(g1,g2,varargin)
% outer inner product between two quaternions
%
% Input
%  g1, g2 - @quaternion
%
% Output
%  d - double
%
% Description
% cos angle(g1,g2)/2 = dot(g1,g2)

if ~isempty(g1) && ~isempty(g2)

  q1 = [g1.a(:) g1.b(:) g1.c(:) g1.d(:)];
  q2 = [g2.a(:) g2.b(:) g2.c(:) g2.d(:)];
  
  d = q1 * q2.';
    
else
    d = [];
end
