function q = mtimes(q1,q2,takeRight)
% quaternionen multiplication q1 * q2

if nargin == 3 || (isa(q1,'quaternion') && isa(q2,'quaternion'))

  a1 = q1.a(:); b1 = q1.b(:); c1 = q1.c(:); d1 = q1.d(:);
  a2 = q2.a(:); b2 = q2.b(:); c2 = q2.c(:); d2 = q2.d(:);

  % which input will become the output?
  if nargin == 3 
    if takeRight, q = q2; else, q = q1; end
  elseif ~isa(q1,'rotation')
    q = q2;
  else
    q = q1;
  end
  
  % left side matrix Q_l(q1)
  qr = [a2,b2,c2,d2]';
  q.a = [a1 -b1 -c1 -d1] * qr;
  q.b = [b1  a1 -d1  c1] * qr;
  q.c = [c1  d1  a1 -b1] * qr;
  q.d = [d1 -c1  b1  a1] * qr;

  % maybe result was rotation 
  % then care also about i
  if isa(q,'rotation')
    try ia = q1.i; catch, ia = false(size(q1.a)); end
    try ib = q2.i; catch, ib = false(size(q2.a)); end
    q.i = bsxfun(@xor,ia(:),ib(:).');
  end
  

  % stadard algorithm
  % a = a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
  % b = a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
  % c = a1 * c2 + c1 * a2 + d1 * b2 - b1 * d2;
  % d = a1 * d2 + d1 * a2 + b1 * c2 - c1 * b2;
   
elseif isa(q1,'quaternion') && isa(q2,'double') % einfache Zahl
  
  q.a = q1.a * q2;
  q.b = q1.b * q2;
  q.c = q1.c * q2;
  q.d = q1.d * q2;
  
elseif isa(q2,'quaternion') && isa(q1,'double') % einfache Zahl
  
  q.a = q1 * q2.a;
  q.b = q1 * q2.b;
  q.c = q1 * q2.c;
  q.d = q1 * q2.d;
    
else
    
  q = rotate_outer(q2,q1);
  
end
