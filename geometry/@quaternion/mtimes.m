function q = mtimes(q1,q2)
% quaternionen multiplication q1 * q2

if isa(q1,'quaternion') && isa(q2,'quaternion')
  
  q = q1;
  
  a1 = q1.a(:);   b1 = q1.b(:);   c1 = q1.c(:);   d1 = q1.d(:);
  a2 = q2.a(:).'; b2 = q2.b(:).'; c2 = q2.c(:).'; d2 = q2.d(:).';
  
 	a = a1 * a2 - b1 * b2 - c1 * c2 - d1 * d2;
 	b = a1 * b2 + b1 * a2 + c1 * d2 - d1 * c2;
 	c = a1 * c2 + c1 * a2 + d1 * b2 - b1 * d2;
 	d = a1 * d2 + d1 * a2 + b1 * c2 - c1 * b2;
  
  q.a = a; q.b = b; q.c = c; q.d = d;
  
  %[a,b,c,d] = quaternion_mtimes_qq(q1.a,q1.b,q1.c,q1.d,q2.a,q2.b,q2.c,q2.d);
	
%    q = class(q,'quaternion');
  
elseif isa(q1,'quaternion') && (isa(q2,'vector3d') || isa(q2,'Miller'))
	
	[x,y,z] = double(q2);
  [nx,ny,nz] = quaternion_mtimes(q1.a(:),q1.b(:),q1.c(:),q1.d(:),x(:).',y(:).',z(:).');
	q = vector3d(nx,ny,nz);
	
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
