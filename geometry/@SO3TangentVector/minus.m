function v = minus(v1,v2,varargin)

tS = ensureCompatibleTangentSpaces(v1,v2,'equal');
v = minus@vector3d(v1,v2,varargin{:});

if isa(v1,'SO3TangentVector')
  r = v1.rot;
  cs = v1.hiddenCS;
  ss = v1.hiddenSS;
else
  r = v2.rot;
  cs = v2.hiddenCS;
  ss = v2.hiddenSS;
end
v = SO3TangentVector(v,r,tS,cs,ss);

end