function grains = findByOrientation( grains,q0, epsilon )




o = get(grains,'orientation');

ind = find(o,q0,epsilon);

grains = subsref(grains,any(ind,2));

