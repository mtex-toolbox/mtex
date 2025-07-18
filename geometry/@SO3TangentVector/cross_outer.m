function v = cross_outer(v1,v2,varargin)

tS = ensureCompatibleTangentSpaces(v1,v2,'AllEqual');
v = cross_outer@vector3d(vector3d(v1),vector3d(v2),varargin{:});
v = SO3TangentVector(v,v1.rot(1),tS,v1.hiddenCS,v1.hiddenSS);

end