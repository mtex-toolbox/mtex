function v = cross(v1,v2,varargin)
% overload cross

tS = ensureCompatibleTangentSpaces(v1,v2,'equal');
v = cross@vector3d(vector3d(v1),vector3d(v2),varargin{:});
v = SO3TangentVector(v,v1.rot,tS,v1.hiddenCS,v1.hiddenSS);

end