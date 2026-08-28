function out = eqTol(sF1,sF2)
% whether two specimen frames may be treated as one
%
% A specimen frame has no lattice to compare, so what has to agree is the
% Laue class and the basis.

out = sF1 == sF2 || (isa(sF2,'specimenFrame') && ...
  sF1.Laue.id == sF2.Laue.id && isAligned(sF1,sF2));

end
