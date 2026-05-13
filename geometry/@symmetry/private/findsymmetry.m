function id = findsymmetry(name)
% search for specific symmetry

% import list of point groups
sl = symmetry.pointGroups;

% search for point group
id = [];
for i = numel(sl):-1:1
  if any(strcmp(name,[{sl(i).Schoen,sl(i).Inter,char(sl(i).lattice)},sl(i).altNames]))
    id = i;
    return
  end
end

% try to convert space to point group
try %#ok<TRYNC>
  id = findsymmetry(hms2point(name)); 
  assert(~isempty(id));
  return
end

% search for substrings international as substring
for i = numel(sl):-1:1
  if any(contains(name,[{sl(i).Inter},sl(i).altNames]))
    id = i;
    return
  end
end

% search for lattice as substring
for i = numel(sl):-1:1
  if any(contains(name,char(sl(i).lattice)))
    id = i;
    return
  end
end
end


