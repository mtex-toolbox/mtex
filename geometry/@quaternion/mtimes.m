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
  
  
  [nx,ny,nz] = quaternion_mtimes(q1.a,q1.b,q1.c,q1.d,x,y,z);
% 	n = q1.b.^2 + q1.c.^2 + q1.d.^2;
% 	s = q1.b*x + q1.c*y + q1.d*z;
% 	l = length(q1.a);
% 	a = spdiags(q1.a,0,l,l);
%     
% 	nx = 2*a * (q1.c * z - q1.d * y) + 2*spdiags(q1.b,0,l,l)*s + (q1.a.^2 - n) * x;
% 	ny = 2*a * (q1.d * x - q1.b * z) + 2*spdiags(q1.c,0,l,l)*s + (q1.a.^2 - n) * y;
% 	nz = 2*a * (q1.b * y - q1.c * x) + 2*spdiags(q1.d,0,l,l)*s + (q1.a.^2 - n) * z;
	
	q = vector3d(nx,ny,nz);
	
elseif isa(q1,'quaternion') && isa(q2,'double') % einfache Zahl   
	
    q = quaternion(q1.a * q2,q1.b * q2,q1.c * q2,q1.d * q2);
		
elseif isa(q2,'quaternion') && isa(q1,'double') % einfache Zahl   
	
    q = quaternion(q2.a * q1,q2.b * q1,q2.c * q1,q2.d * q1);

else 
    error('wrong type of arguments');
end
