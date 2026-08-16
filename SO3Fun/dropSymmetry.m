function sym = dropSymmetry(sym,rot,side,what)
% drop a symmetry that a rotation does not respect, keeping its frame
%
% Rotating a function by a rotation which is not one of its own symmetry
% elements destroys that symmetry. The group is then dropped and the
% reference frame kept - the data still lives where it lived, it just no
% longer claims to be symmetric (ADR 0003, see symmetry/stripSym).
%
% Syntax
%   SO3F.CS = dropSymmetry(SO3F.CS,rot,'crystal','ODF')
%   SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF')
%
% Input
%  sym  - @symmetry
%  rot  - @rotation, one or many
%  side - 'crystal' or 'specimen', for the warning
%  what - what is being rotated, for the warning, e.g. 'ODF'
%
% Output
%  sym - @symmetry, the trivial group on the same frame when it was dropped
%
% Description
%
% This replaces twenty three copies of the same block that had drifted into
% three different guards. |numSym(sym.Laue) > 2| is the correct one: it says
% the point group is neither |1| nor |-1|, hence claims something a rotation
% can destroy. The |length(sym.rot) > 2| spelling some copies used is a
% different test - it under-warns for every non centrosymmetric group of
% order two, so an ODF with point group |2| kept a symmetry claim that the
% rotation had just invalidated.
%
% The membership test covers a single rotation and a list at once:
% |all(any(rot(:).' == sym.rot(:)))| reduces to |any(rot == sym.rot(:))| when
% |rot| is scalar, which is what rotate needs and rotate_outer generalises.
%
% See also
% symmetry/stripSym SO3Fun/rotate SO3VectorField/rotate

if numSym(sym.Laue) > 2 && ~all(any(rot(:).' == sym.rot(:)))

  warning('Rotating an %s with %s symmetry will remove the %s symmetry', ...
    what,side,side);

  sym = stripSym(sym);

end

end
