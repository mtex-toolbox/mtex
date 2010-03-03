function q = subsasgn(q,s,b)
% overloads subsasgn

if isempty(q)
  q = b;
  q.a = [];
  q.b = [];
  q.c = [];
  q.d = [];
end

if isa(b,'quaternion')
  switch s.type
    case '()'
      q.a = subsasgn(q.a,s,b.a);
      q.b = subsasgn(q.b,s,b.b);
      q.c = subsasgn(q.c,s,b.c);
      q.d = subsasgn(q.d,s,b.d);
    otherwise
      error('Wrong indexing. Only ()-indexing is allowed for quaternion!');
  end
elseif isempty(b)
  q.a = subsasgn(q.a,s,[]);
  q.b = subsasgn(q.b,s,[]);
  q.c = subsasgn(q.c,s,[]);
  q.d = subsasgn(q.d,s,[]);
else
  error('Value must be of type quaternion!');
end
