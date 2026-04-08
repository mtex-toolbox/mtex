function b = eq(v1,v2,varargin)

if ~isa(v1,'SO3TangentVector') ||  ~isa(v2,'SO3TangentVector')
  error('Trying to compare tangent vectors with other objects.')
end
tS = v1.tangentSpace;
v2 = transformTangentSpace(v2,tS);

b = eq@vector3d(v1,v2,varargin{:});
ensureCompatibleTangentSpaces(v1,v2,'equal');

end