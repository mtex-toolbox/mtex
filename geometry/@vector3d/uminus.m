function v = uminus(v1)
% overloads unitary minus

if isa(v1,'vector3d')
    v = vector3d(- v1.x,- v1.y,- v1.z);
end
    
