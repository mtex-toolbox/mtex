function q1 = rdivide(q1,d)
% scalar division

if isa(q1,'quaternion')
    if isa(d,'double')
      q1.a = q1.a ./ d;
      q1.b = q1.b ./ d;
      q1.c = q1.c ./ d;
      q1.d = q1.d ./ d;      
    else
        error('Second argument must be double');
    end
else
    error('First argument must be Quaternion');
end
