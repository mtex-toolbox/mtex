function q = mtimes(q1,q2)
% quaternionen multiplication q1 * q2

if isa(q1,'quaternion') && isa(q2,'quaternion')

  q1.a = q1.a(:); q1.b = q1.b(:);q1.c = q1.c(:); q1.d = q1.d(:);
  q2.a = q2.a(:).'; q2.b = q2.b(:).';q2.c = q2.c(:).'; q2.d = q2.d(:).';
 	q.a = q1.a * q2.a - q1.b * q2.b - q1.c * q2.c - q1.d * q2.d;
 	q.b = q1.a * q2.b + q1.b * q2.a + q1.c * q2.d - q1.d * q2.c;
 	q.c = q1.a * q2.c + q1.c * q2.a + q1.d * q2.b - q1.b * q2.d;
 	q.d = q1.a * q2.d + q1.d * q2.a + q1.b * q2.c - q1.c * q2.b;
  %[a,b,c,d] = quaternion_mtimes_qq(q1.a,q1.b,q1.c,q1.d,q2.a,q2.b,q2.c,q2.d);
	
  q = class(q,'quaternion');
  
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
