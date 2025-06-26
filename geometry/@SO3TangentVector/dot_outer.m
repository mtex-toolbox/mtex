function v = dot_outer(v1,v2,varargin)

ensureCompatibleTangentSpaces(v1,v2,'AllEqual');
v = dot_outer@vector3d(v1,v2,varargin{:});

end