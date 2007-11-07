function v = mtimes(v1,v2)
% scalar multiplication

if isa(v1,'vector3d')
    if isa(v2,'vector3d')
        error('the product of two vectors is not definet. see dotprodukt or use .*');
    else 
        v = vector3d(v1.x * v2,v1.y * v2,v1.z * v2);
    end
elseif isa(v2,'vector3d')
    v = vector3d(v1 * v2.x,v1 * v2.y,v1 * v2.z);
end
