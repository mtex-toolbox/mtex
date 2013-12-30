function u = union(s1,s2)
% returns the union of two symmetry groups

u  = s1 * s2;

u = unique(u(:));

