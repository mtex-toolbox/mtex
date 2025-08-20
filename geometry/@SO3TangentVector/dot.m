function v = dot(v1,v2,varargin)
% overload dot

if ( isa(v1,'vector3d') && ~isa(v1,'SO3TangentVector') ) || ( isa(v2,'vector3d') && ~isa(v2,'SO3TangentVector') )
  v = dot@vector3d(v1,v2,varargin{:});
  return
end

if ~isa(v1,'SO3TangentVector') ||  ~isa(v2,'SO3TangentVector')
  error('For tangent vectors, it is only possible to calculate the dot product with other tangent vectors.')
end
tS = v1.tangentSpace;
v2 = transformTangentSpace(v2,tS);

ensureCompatibleTangentSpaces(v1,v2,'equal');
v = dot@vector3d(v1,v2,varargin{:});

end