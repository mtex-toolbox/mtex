function q = itimes(q1,q2,takeRight)
% quaternion .* quaternion and quaternion .* vector3d 
%
% Syntax
%   q = q1 .* q2
%
%   q = times(q1,q2)
%   q = times(q1,q2,takeRight)
%
% Input
%  q1 - @quaternion
%  q2 - @quaternion
%  takeRight - logical, use as output left or right input 
%
% Output
%  q  - @quaternion

% which input will become the output?
if takeRight
  q = q2; 
  a1 = q1.a; b1 = -q1.b; c1 = -q1.c; d1 = -q1.d;
  a2 = q2.a; b2 = q2.b; c2 = q2.c; d2 = q2.d;
else
  q = q1; 
  a1 = q1.a; b1 = q1.b; c1 = q1.c; d1 = q1.d;
  a2 = q2.a; b2 = -q2.b; c2 = -q2.c; d2 = -q2.d;
end
 
%standart algorithm
q.a = a1 .* a2 - b1 .* b2 - c1 .* c2 - d1 .* d2;
q.b = b1 .* a2 + a1 .* b2 - d1 .* c2 + c1 .* d2;
q.c = c1 .* a2 + d1 .* b2 + a1 .* c2 - b1 .* d2;
q.d = d1 .* a2 - c1 .* b2 + b1 .* c2 + a1 .* d2;
  
end

