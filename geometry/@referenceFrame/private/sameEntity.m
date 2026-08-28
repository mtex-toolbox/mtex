function out = sameEntity(fr1,fr2)
% whether two frames are the same entity, so the register may unify them
%
% The key of ADR 0008 rule 2: the point group, and everything
% <sameBasis.html |sameBasis|> tests. Two frames agreeing on all of it are one
% phase, so the register hands back a single handle for both.
%
% See also
% referenceFrame/intern

out = fr1.sym.id == fr2.sym.id && sameBasis(fr1,fr2);

end
