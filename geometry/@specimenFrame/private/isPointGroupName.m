function out = isPointGroupName(name)
% whether a string names a point group, and nothing else
%
% A specimen frame takes its name as the first argument and a point group in
% the same place, so the two have to be told apart. findsymmetry cannot do
% it: it falls back to matching a substring, which is right when the caller
% knows a group is meant and wrong here - the frame named 'measurement'
% contains the point group 'm'.

out = false;
if ~(ischar(name) || isStringScalar(name)), return; end

name = char(name);
sl = symmetry.pointGroups;

for k = 1:numel(sl)
  if any(strcmp(name,[{sl(k).Schoen,sl(k).Inter,char(sl(k).lattice)},sl(k).altNames]))
    out = true;
    return
  end
end

end
