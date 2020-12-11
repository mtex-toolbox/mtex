function id = findsymmetry(name)
% search for specific symmetry

% import list of point groups
sl = symmetry.pointGroups;

% search for point group
id = [];
for i = numel(sl):-1:1
  if any(strcmp(name,[{sl(i).Schoen,sl(i).Inter,char(sl(i).lattice)},sl(i).altNames]))
    id = i;
    break;
  end
end

% if nothing found convert space to point group
if isempty(id)
  id = findsymmetry(hms2point(name));
end
