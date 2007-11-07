function v = rdivide(v1,d)
% scalar division

if isa(v1,'vector3d')
    if isa(d,'double')
        v = vector3d(v1.x ./ d,v1.y ./ d,v1.z ./ d);
    else
        error('Second argument must be double');
    end
end
    
