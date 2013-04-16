function r = subsasgn(r,s,b)
% overloads subsasgn

if isempty(r)
  r = b;
  r.a = [];
  r.b = [];
  r.c = [];
  r.d = [];
  r.i = [];
end

if isa(b,'quaternion')
  
  b = rotation(b);
  switch s.type
    case '()'
      r.a = subsasgn(r.a,s,b.a);
      r.b = subsasgn(r.b,s,b.b);
      r.c = subsasgn(r.c,s,b.c);
      r.d = subsasgn(r.d,s,b.d);
      r.i = subsasgn(r.i,s,b.i);
    otherwise
      error('Wrong indexing. Only ()-indexing is allowed for quaternion!');
  end
elseif isempty(b)
  r.a = subsasgn(r.a,s,[]);
  r.b = subsasgn(r.b,s,[]);
  r.c = subsasgn(r.c,s,[]);
  r.d = subsasgn(r.d,s,[]);
  r.i = subsasgn(r.i,s,[]);
else
  error('Value must be of type quaternion!');
end
