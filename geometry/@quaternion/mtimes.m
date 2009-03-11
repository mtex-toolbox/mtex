function q=mtimes(q1,q2)
% quaternionen multiplication q1 * q2

if isa(q2,'Miller')
  q2 = vector3d(q2);
end

if isa(q1,'quaternion') && isa(q2,'quaternion')
	
 	a = q1.a * q2.a - q1.b * q2.b - q1.c * q2.c - q1.d * q2.d;
 	b = q1.a * q2.b + q1.b * q2.a + q1.c * q2.d - q1.d * q2.c;
 	c = q1.a * q2.c + q1.c * q2.a + q1.d * q2.b - q1.b * q2.d;
 	d = q1.a * q2.d + q1.d * q2.a + q1.b * q2.c - q1.c * q2.b;
  %[a,b,c,d] = quaternion_mtimes_qq(q1.a,q1.b,q1.c,q1.d,q2.a,q2.b,q2.c,q2.d);
	
	q = quaternion(a,b,c,d);

elseif isa(q1,'quaternion') && isa(q2,'vector3d')
	
	[x,y,z] = double(q2);
  [nx,ny,nz] = quaternion_mtimes(q1.a(:),q1.b(:),q1.c(:),q1.d(:),x(:).',y(:).',z(:).');
	q = vector3d(nx,ny,nz);
	
elseif isa(q1,'quaternion') && isa(q2,'double') % einfache Zahl   
	
    q = quaternion(q1.a * q2,q1.b * q2,q1.c * q2,q1.d * q2);
		
elseif isa(q2,'quaternion') && isa(q1,'double') % einfache Zahl   
	
    q = quaternion(q2.a * q1,q2.b * q1,q2.c * q1,q2.d * q1);

else 
    error('wrong type of arguments');
end
