function dot = dot_angle(q1,q2,omega)
% compute minimum q1 . q2 modulo rotation about zaxis and angle omega

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
  
% dot = max(abs(bsxfun(@times,cos(omega/2),a) - bsxfun(@times,sin(omega/2),d)),[],2);

dot =  abs(cos(omega(1)/2)*a - sin(omega(1)/2)*d);
for k=2:numel(omega)
  dot = max(dot,abs(cos(omega(k)/2)*a - sin(omega(k)/2)*d));
end
