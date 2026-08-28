function out = sameEntity(fr1,fr2)
% whether two frames are the same entity, so the register may unify them
%
% The key of ADR 0008 rule 2: cell shape, alignment, point group, name and
% plotting convention. Colour is deliberately absent - two labs colour
% forsterite differently and it is the same forsterite.
%
% The cell is compared by SHAPE, not by size: uniform scaling of a, b, c
% scales every reciprocal vector by the inverse and moves no
% crystallographic direction, so a literature 2.87 against a measured 2.866
% is a deviation of zero.

out = false;

if ~strcmp(class(fr1),class(fr2)), return; end
if fr1.sym.id ~= fr2.sym.id, return; end
if ~strcmp(char(fr1.name),char(fr2.name)), return; end

% a convention that was never stated matches only another that was not
if isempty(fr1.how2plot) ~= isempty(fr2.how2plot), return; end
if ~isempty(fr1.how2plot) && ~isapprox(fr1.how2plot,fr2.how2plot), return; end

if isa(fr1,'crystalFrame')

  tol = getMTEXpref('frameShapeTolerance',1e-2);

  a1 = fr1.abc ./ fr1.abc(1); a2 = fr2.abc ./ fr2.abc(1);
  out = all(abs(a1 - a2) < tol) && all(abs(fr1.abg - fr2.abg) < tol) && ...
    isequal(alignment(fr1),alignment(fr2));

else

  out = isAligned(fr1,fr2);

end

end
