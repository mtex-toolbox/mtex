function q = times(q1,q2)
% implements quaternion .* quaternion and quaternion .* vector3d 
%
% Input
%  q1 - @quaternion
%  q2 - @quaternion | @vector3d
%
% Output
%  q  - @quaternion | @vector3d

if isa(q1,'quaternion') && isa(q2,'quaternion')
  
%  [a,b,c,d] = quaternion_times_qq(q1.a,q1.b,q1.c,q1.d,q2.a,q2.b,q2.c,q2.d);
%  q = quaternion(a,b,c,d);
     q = q1;
     
     a1 = q1.a; b1 = q1.b; c1 = q1.c; d1 = q1.d;
     a2 = q2.a; b2 = q2.b; c2 = q2.c; d2 = q2.d;
     
     %standart algorithm     
     a = a1 .* a2 - b1 .* b2 - c1 .* c2 - d1 .* d2;
     b = b1 .* a2 + a1 .* b2 - d1 .* c2 + c1 .* d2;
     c = c1 .* a2 + d1 .* b2 + a1 .* c2 - b1 .* d2;
     d = d1 .* a2 - c1 .* b2 + b1 .* c2 + a1 .* d2;
     
     % fast algorithm which is not faster
%      aa = (d1 + b1) .* (b2 + c2);
%      cc = (a1 - c1) .* (a2 + d2);
%      dd = (a1 + c1) .* (a2 - d2);
%      bb = aa + cc + dd;
%      qq = 0.5 * (bb + (d1 - b1) .* (b2 - c2));
% 
%      a = qq - aa + (d1 - c1) .* (c2 - d2);
%      b = qq - bb + (b1 + a1) .* (b2 + a2);
%      c = qq - cc + (a1 - b1) .* (c2 + d2);
%      d = qq - dd + (d1 + c1) .* (a2 - b2);
     
     q.a = a; q.b = b; q.c = c; q.d = d;

elseif isa(q1,'quaternion') && isa(q2,'double')
    q = quaternion(q1.a .* q2,q1.b .* q2,q1.c .* q2,q1.d .* q2);
elseif isa(q2,'quaternion') && isa(q1,'double')
    q = quaternion(q2.a .* q1,q2.b .* q1,q2.c .* q1,q2.d .* q1);
elseif isa(q1,'quaternion') && (isa(q2,'vector3d') || isa(q2,'Miller')) 

  a1 = q1.a; b1 = q1.b; c1 = q1.c; d1 = q1.d;
  [x,y,z] = double(q2);
  
  n = b1.^2 + c1.^2 + d1.^2;
  s = 2*(x.*b1 + y.*c1 + z.*d1);
  
  a1_2 = 2*a1;
  a_n  = a1.^2 - n;
  
  nx = a1_2.*(c1.* z - y.*d1) + s.*b1 + a_n.*x;
  ny = a1_2.*(d1.* x - z.*b1) + s.*c1 + a_n.*y;
  nz = a1_2.*(b1.* y - x.*c1) + s.*d1 + a_n.*z;
  
  q = vector3d(nx,ny,nz);
  
elseif isa(q1,'quaternion') && size(q2,1)==3    % zweites Element ist ein Vektor
    qq = quaternion(0,q2(1,:),q2(2,:),q2(3,:));
    q3 = q1 .* qq .* q1';
    q = [q3.b;q3.c;q3.d];
else 
    error('wrong type of arguments');
end

