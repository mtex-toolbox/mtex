function v = dot_outer(v1,v2,varargin)
% overload dot_outer

if ~isa(v1,'SO3TangentVector') ||  ~isa(v2,'SO3TangentVector')
  error('For tangent vectors, it is only possible to calculate the cross product with tangent vectors.')
end
tS = v1.tangentSpace;
v2 = transformTangentSpace(v2,tS);

ensureCompatibleTangentSpaces(v1,v2,'AllEqual');
v = dot_outer@vector3d(v1,v2,varargin{:});

end