function q = times(q1,q2,takeRight)
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

if isa(q1,'quaternion') && isa(q2,'quaternion')
  
  % which input will become the output?
  if nargin == 3 
    if takeRight, q = q2; else, q = q1; end
  elseif isa(q1,'rotation')
    q = q1;
  else
    q = q2;
  end
  
  a1 = q1.a; b1 = q1.b; c1 = q1.c; d1 = q1.d;
  a2 = q2.a; b2 = q2.b; c2 = q2.c; d2 = q2.d;
  
  %standard algorithm
  q.a = a1 .* a2 - b1 .* b2 - c1 .* c2 - d1 .* d2;
  q.b = b1 .* a2 + a1 .* b2 - d1 .* c2 + c1 .* d2;
  q.c = c1 .* a2 + d1 .* b2 + a1 .* c2 - b1 .* d2;
  q.d = d1 .* a2 - c1 .* b2 + b1 .* c2 + a1 .* d2;
  
elseif isa(q1,'quaternion') && isa(q2,'double')
  
  q1.a = q1.a .* q2;
  q1.b = q1.b .* q2;
  q1.c = q1.c .* q2;
  q1.d = q1.d .* q2;
  q = q1;
    
elseif isa(q2,'quaternion') && isa(q1,'double')
 
  q2.a = q1 .* q2.a;
  q2.b = q1 .* q2.b;
  q2.c = q1 .* q2.c;
  q2.d = q1 .* q2.d;
  q = q2;
     
else 
  
  q = rotate(q2,q1);
    
end
