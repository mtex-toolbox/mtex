function v = cross(v1,v2,varargin)
% overload cross

if ~isa(v1,'SO3TangentVector') ||  ~isa(v2,'SO3TangentVector')
  error('For tangent vectors, it is only possible to calculate the cross product with other tangent vectors.')
end
tS = v1.tangentSpace;
v2 = transformTangentSpace(v2,tS);

tS = ensureCompatibleTangentSpaces(v1,v2,'equal');
v = cross@vector3d(vector3d(v1),vector3d(v2),varargin{:});
v = SO3TangentVector(v,v1.rot,tS,v1.hiddenCS,v1.hiddenSS);

end