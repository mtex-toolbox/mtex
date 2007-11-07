function v = subsasgn(a,s,b)
% overloads subsasgn

switch s.type
	case '()'
		if isa(b,'vector3d')
			v = vector3d(subsasgn(a.x,s,b.x),subsasgn(a.y,s,b.y),subsasgn(a.z,s,b.z));
		elseif isempty(b)
			v = vector3d(subsasgn(a.x,s,[]),subsasgn(a.y,s,[]),subsasgn(a.z,s,[]));
		else
			error('value must be of type vector3d');
		end
	case '.'
		a.(s.subs) = b;
		v = a;
	otherwise
		error('wrong data type');
end
