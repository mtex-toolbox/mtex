function dot = dot_sym(q1,q2,cs,ss)
% compute minimum q1 q2

if nargin > 3
  qss = quaternion(ss);
else
  qss = [];
end

omega = 0:rotangle_max_z(cs):2*pi-rotangle_max_z(cs);
dot = dot_angle(q1,q2,omega);

qcs = quaternion_special(cs);
for i = 2:length(qcs)
  dot = max(dot,dot_angle(q1*qcs(i),q2,omega));
end


function dot = dot_angle(q1,q2,omega)
% compute minimum q1 q2

a1 = q1.a(:);
b1 = q1.b(:);
c1 = q1.c(:);
d1 = q1.d(:);

a2 = q2.a(:);
b2 = q2.b(:);
c2 = q2.c(:);
d2 = q2.d(:);

a =   a1 .* a2 + b1 .* b2 + c1 .* c2 + d1 .* d2;
d = - a1 .* d2 + d1 .* a2 + b1 .* c2 - c1 .* b2;
  
dot = max(abs(bsxfun(@times,cos(omega/2),a) - bsxfun(@times,sin(omega/2),d)),[],2);
