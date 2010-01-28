function b = eq(o1,o2)
% ? o1 == o2

b = dot(o1,o2) > 1-1e-7;
