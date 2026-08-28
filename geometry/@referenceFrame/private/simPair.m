function out = simPair(fr1,fr2)
% whether two frames describe the same symmetry, by value
%
% Unlike <eqTolPair.html |eqTolPair|> the bases need not be aligned: a
% crystal frame still has to have the same cell, a specimen frame only the
% same group.

out = strcmpi(class(fr1),class(fr2));
if ~out, return; end

switch class(fr1)

  case "notIndexedFrame"

    out = strcmpi(fr1.name,fr2.name);

  case "specimenFrame"

    out = fr1.Laue.id == fr2.Laue.id;

  case "crystalFrame"

    out = strcmpi(fr1.name,fr2.name);
    if ~out, return; end

    out = sameGroup(fr1,fr2);
    if ~out, return; end

    out = all(abs(fr1.abc - fr2.abc)/max(fr1.abc) < 1e-2) && ...
      all(abs(fr1.abg - fr2.abg) < 1e-2);

  otherwise
    out = false;

end

end
