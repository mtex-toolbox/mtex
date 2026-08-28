function out = eqTolPair(fr1,fr2)
% whether two frames may be treated as one, by value
%
% Looser than <sameEntity.html |sameEntity|>, which the register uses: the
% cell shape is not compared and the plotting convention plays no part, so
% two measurements of the same phase written with different conventions
% still count as one frame here.

out = strcmpi(class(fr1),class(fr2));
if ~out, return; end

switch class(fr1)

  case "notIndexedFrame"

    out = strcmpi(fr1.name,fr2.name);

  case "specimenFrame"

    % a specimen frame has no lattice to compare, so what has to agree is
    % the Laue class and the basis
    out = fr1.Laue.id == fr2.Laue.id && isAligned(fr1,fr2);

  case "crystalFrame"

    out = strcmpi(fr1.name,fr2.name);
    if ~out, return; end

    out = sameGroup(fr1,fr2);
    if ~out, return; end

    % the frames have to be aligned - the 5e-2 rule of
    % referenceFrame.tolAligned
    out = isAligned(fr1,fr2);

  otherwise
    % a class this does not know about is only equal to itself, which the
    % identity test in eqTol has already ruled out
    out = false;

end

end
