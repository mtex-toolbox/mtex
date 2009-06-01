function q = subsasgn(q,s,b)
% overloads subsasgn

if isa(b,'quaternion')
    switch s.type
    case '()'
        q.a = subsasgn(q.a,s,b.a);
        q.b = subsasgn(q.b,s,b.b);
        q.c = subsasgn(q.c,s,b.c);
        q.d = subsasgn(q.d,s,b.d);
    otherwise
        error('wrong data type');
    end
elseif isempty(b)
        q.a = subsasgn(q.a,s,[]);
        q.b = subsasgn(q.b,s,[]);
        q.c = subsasgn(q.c,s,[]);
        q.d = subsasgn(q.d,s,[]);
else
    error('value must be of type quaternion');
end
