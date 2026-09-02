function out = sameGroup(fr1,fr2)
% whether two crystal frames carry the same point group
%
% A group MTEX has an id for is compared by its Laue class, since a phase
% is identified by the diffraction symmetry it shows. A group given by its
% elements has no id and no Laue class to name, so it is compared as the
% group it is.

if fr1.id == 0
  out = fr1.sym == fr2.sym;
else
  out = fr1.Laue.id == fr2.Laue.id;
end

end
