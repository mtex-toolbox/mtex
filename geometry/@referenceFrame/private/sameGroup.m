function out = sameGroup(fr1,fr2)
% whether two crystal frames carry the same point group
%
% A group MTEX has an id for is compared by its Laue class, since a phase
% is identified by the diffraction symmetry it shows. A group given by its
% elements has no id, so the elements themselves are compared.

if fr1.id == 0
  out = fr2.id == 0 && numSym(fr1) == numSym(fr2) && ...
    max(angle(fr1.rot(:),fr2.rot(:))) < 0.1*degree;
else
  out = fr1.Laue.id == fr2.Laue.id;
end

end
