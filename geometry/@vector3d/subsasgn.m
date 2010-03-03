function v = subsasgn(v,s,b)
% overloads subsasgn

if isempty(v)
  v = b;
  v.x = [];
  v.y = [];
  v.z = [];
end

if isa(b,'vector3d')
  switch s.type
    case '()'
      v.x = subsasgn(v.x,s,b.x);
      v.y = subsasgn(v.y,s,b.y);
      v.z = subsasgn(v.z,s,b.z);
    otherwise
      error('Wrong indexing. Only ()-indexing is allowed for vector3d!');
  end
elseif isempty(b)
  v.x = subsasgn(v.x,s,[]);
  v.y = subsasgn(v.y,s,[]);
  v.z = subsasgn(v.z,s,[]);
else
  error('Value must be of type quaternion!');
end