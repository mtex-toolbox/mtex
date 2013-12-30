function b = eq(k1,k2)
% ? kernel1 == kernel2

b = strcmp(k1.name,k2.name) & (k1.p1 == k2.p1);
