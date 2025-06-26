function v = dot(v1,v2,varargin)

ensureCompatibleTangentSpaces(v1,v2,'equal');
v = dot@vector3d(v1,v2,varargin{:});

end