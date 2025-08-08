function v = plus(v1,v2)
% overload plus +

if ~isa(v1,'SO3TangentVector') || ~isa(v2,'SO3TangentVector')
  error('For tangent vectors, it is only possible to calculate the cross product with tangent vectors.')
end
tS = v1.tangentSpace;
v2 = transformTangentSpace(v2,tS);

tS = ensureCompatibleTangentSpaces(v1,v2,'equal');
v = plus@vector3d(v1,v2);

end
