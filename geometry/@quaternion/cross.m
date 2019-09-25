function q = cross(q1, q2, q3)
% pointwise cross product of three quaternions
%
% Input
%  q1,q2,q3 - @quaternion
%
% Output
%  q - @quaternion
%

if nargin == 3
  [a1,b1,c1,d1] = double(q1);
  [a2,b2,c2,d2] = double(q2);
  [a3,b3,c3,d3] = double(q3);
else
  [a,b,c,d] = double(q1);
  a1 = a(:,1); a2 = a(:,2); a3 = a(:,3);
  b1 = b(:,1); b2 = b(:,2); b3 = b(:,3);
  c1 = c(:,1); c2 = c(:,2); c3 = c(:,3);  
  d1 = d(:,1); d2 = d(:,2); d3 = d(:,3);  
end

% Calculate cross product
q = q1;
q.a = b1.*c2.*d3 - b1.*c3.*d2 - b2.*c1.*d3 + b2.*c3.*d1 + b3.*c1.*d2 - b3.*c2.*d1;
q.b = a1.*c3.*d2 - a1.*c2.*d3 + a2.*c1.*d3 - a2.*c3.*d1 - a3.*c1.*d2 + a3.*c2.*d1;
q.c = a1.*b2.*d3 - a1.*b3.*d2 - a2.*b1.*d3 + a2.*b3.*d1 + a3.*b1.*d2 - a3.*b2.*d1;
q.d = a1.*b3.*c2 - a1.*b2.*c3 + a2.*b1.*c3 - a2.*b3.*c1 - a3.*b1.*c2 + a3.*b2.*c1;

% one could also do 
%
%M = [[q1.a,q1.b,q1.c,q1.d];...
%  [q2.a,q2.b,q2.c,q2.d];...
%  [q3.a,q3.b,q3.c,q3.d]].';
%
%[q,~] = qr(M);
%
%q = quaternion(q(:,4));
