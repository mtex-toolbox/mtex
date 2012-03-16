function q = rdivide(q1,d)
% scalar division

if isa(q1,'quaternion')
    if isa(d,'double')
        q = quaternion(q1.a ./ d,q1.b ./ d,q1.c ./ d,q1.d ./ d);
    else
        error('Second argument must be double');
    end
else
    error('First argument must be Quaternion');
end
