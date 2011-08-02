function q = mtimes(q1,q2)
% quaternionen multiplication q1 * q2

if isa(q1,'quaternion') && isa(q2,'quaternion')
  
  q = q1;
  a1 = q1.a(:); b1 = q1.b(:); c1 = q1.c(:); d1 = q1.d(:);
  a2 = q2.a(:); b2 = q2.b(:); c2 = q2.c(:); d2 = q2.d(:);
  
  if numel(a1) < numel(a2) % assume faster concatenation for its smaller array

    % left side matrix Q_l(q1)
    qr = [a2,b2,c2,d2]';
    q.a = [a1 -b1 -c1 -d1] * qr;
    q.b = [b1  a1 -d1  c1] * qr;
    q.c = [c1  d1  a1 -b1] * qr;
    q.d = [d1 -c1  b1  a1] * qr;

  else
    
    % right side matrix Q_r(q2)
    ql = [a1,b1,c1,d1]';
    q.a = [a2 -b2 -c2 -d2] * ql;
    q.b = [b2  a2  d2 -c2] * ql;
    q.c = [c2 -d2  a2  b2] * ql;
    q.d = [d2  c2 -b2  a2] * ql;

  end

  % stadard algorithm
  %    	a = a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
  %    	b = a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
  %    	c = a1 * c2 + c1 * a2 + d1 * b2 - b1 * d2;
  %    	d = a1 * d2 + d1 * a2 + b1 * c2 - c1 * b2;
 
elseif isa(q1,'quaternion') && isa(q2,'vector3d')
  
  q = rotate(q2,q1);
  
elseif isa(q1,'quaternion') && isa(q2,'double') % einfache Zahl
  
  q.a = q1.a * q2;
  q.b = q1.b * q2;
  q.c = q1.c * q2;
  q.d = q1.d * q2;
  q = class(q,'quaternion');
  
elseif isa(q2,'quaternion') && isa(q1,'double') % einfache Zahl
  
  q.a = q1 * q2.a;
  q.b = q1 * q2.b;
  q.c = q1 * q2.c;
  q.d = q1 * q2.d;
  q = class(q,'quaternion');
  
else
  error('wrong type of arguments');
end
