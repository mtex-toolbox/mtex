function q = subsasgn(a,s,b)
% overloads subsasgn

if isa(b,'quaternion')
    switch s.type
    case '()'
        q = quaternion(subsasgn(a.a,s,b.a),subsasgn(a.b,s,b.b),subsasgn(a.c,s,b.c),subsasgn(a.d,s,b.d));
    otherwise
        error('wrong data type');
    end
elseif isempty(b)
	q = quaternion(subsasgn(a.a,s,[]),subsasgn(a.b,s,[]),subsasgn(a.c,s,[]),subsasgn(a.d,s,[]));
else
    error('value must be of type quaternion');
end
