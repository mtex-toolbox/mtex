function v = cross_outer(v1,v2,varargin)
% overload cross_outer

if ~isa(v1,'SO3TangentVector') ||  ~isa(v2,'SO3TangentVector')
  error('For tangent vectors, it is only possible to calculate the cross product with tangent vectors.')
end
tS = v1.tangentSpace;
v2 = transformTangentSpace(v2,tS);

tS = ensureCompatibleTangentSpaces(v1,v2,'AllEqual');
v = cross_outer@vector3d(vector3d(v1),vector3d(v2),varargin{:});
v = SO3TangentVector(v,v1.rot(1),tS,v1.hiddenCS,v1.hiddenSS);

end