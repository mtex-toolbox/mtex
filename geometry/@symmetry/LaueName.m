function c = LaueName(s)
% get Laue name

pg = symmetry.pointGroups; 

if s.id > 0
  c = pg(pg(s.id).LaueId).Inter;
else
  c = 'unknown';
end
