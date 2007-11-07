function b = eq(v1,v2)
% ? v1 == v2

b = ([v1.h] == [v2.h]) & ([v1.k] == [v2.k]) & ([v1.l] == [v2.l]);
