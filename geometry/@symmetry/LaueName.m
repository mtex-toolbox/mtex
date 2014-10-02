function c = LaueName(s)
% get Laue name

pg = symmetry.pointGroups; 

c = pg(pg(s.id).LaueId).Inter;
