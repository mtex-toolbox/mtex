function q=quaternion(a,b,c,d)
% Constructor

if nargin == 0
  q.a = [];
  q.b = [];
  q.c = [];
  q.d = [];
  
  q = class(q,'quaternion');
elseif nargin == 1
  if isa(a,'quaternion')
    if nargin == 2
      q = a(b);
    else
      q=a;
    end
  elseif isa(a,'vector3d')
    q.a = zeros(size(a));
    [q.b,q.c,q.d] = double(a);
    
    q = class(q,'quaternion');
  elseif isa(a,'double') && size(a,1) == 4
    q.a = a(1,:,:,:,:,:,:);
    q.b = a(2,:,:,:,:,:,:);
    q.c = a(3,:,:,:,:,:,:);
    q.d = a(4,:,:,:,:,:,:);
    
    q = class(q,'quaternion');
  else
    error('input should be a quaternion or vector3d');
  end
elseif nargin == 2
  if isa(b,'vector3d')
    if length(a) ~= 1
      q.a = a;
    else
      q.a = repmat(a,size(b));
    end
    [q.b,q.c,q.d] = double(b);
    
    q = class(q,'quaternion');
  elseif size(b,1)==3
    q.a = a;
    q.b = b(1,:);
    q.c = b(2,:);
    q.d = b(3,:);
    
    q = class(q,'quaternion');
  elseif size(b,2) == 3
    q.a = a;
    q.b = b(:,1);
    q.c = b(:,2);
    q.d = b(:,3);
    
    q = class(q,'quaternion');
  else
    error('second argument should be a threedimensional vector');
  end
elseif nargin == 4
  q.a = a;
  q.b = b;
  q.c = c;
  q.d = d;
  
  q = class(q,'quaternion');
else
  error('wrong number of arguments');
end

