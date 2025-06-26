function v = times(v1,v2,varargin)

tS = ensureCompatibleTangentSpaces(v1,v2,'equal');
v = times@vector3d(v1,v2,varargin{:});

if isa(v1,'SO3TangentVector')
  r = v1.rot;
else
  r = v2.rot;
end
v = SO3TangentVector(v,r,tS);

end
