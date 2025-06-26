function b = eq(v1,v2,varargin)

b = eq@vector3d(v1,v2,varargin{:});
ensureCompatibleTangentSpaces(v1,v2,'equal');

end