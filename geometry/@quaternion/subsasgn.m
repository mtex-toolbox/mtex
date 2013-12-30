function q = subsasgn(q,s,b)
% overloads subsasgn

if isempty(q) && ~isempty(b)
  q = b;
  q.a = [];
  q.b = [];
  q.c = [];
  q.d = [];
end

if islogical(s) || isnumeric(s)
  s = substruct('()',{s});
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  builtin('subsasgn',subsref(q,s(1)),s(2:end),b); end
      
    if isempty(b)
      q.a = subsasgn(q.a,s(1),[]);
      q.b = subsasgn(q.b,s(1),[]);
      q.c = subsasgn(q.c,s(1),[]);
      q.d = subsasgn(q.d,s(1),[]);
    else
      q.a = subsasgn(q.a,s(1),b.a);
      q.b = subsasgn(q.b,s(1),b.b);
      q.c = subsasgn(q.c,s(1),b.c);
      q.d = subsasgn(q.d,s(1),b.d);
    end
  otherwise
      
    q =  builtin('subsasgn',q,s,b);
      
end

end
