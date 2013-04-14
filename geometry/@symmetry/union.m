function s1 = union(s1,s2)
% returns the disjoint of two symmetry groups

s1.rotation = s1.rotation * s2.rotation;

s1.rotation = unique(s1.rotation(:));

s1.mineral = '';
s1.name = '';
s1.laue = '';
