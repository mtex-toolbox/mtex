function out = sim(sF1,sF2)
% whether two specimen frames describe the same sample symmetry
%
% Unlike <specimenFrame.eqTol.html |eqTol|> the bases need not agree - only
% the group does.

out = sF1 == sF2 || ...
  (isa(sF2,'specimenFrame') && sF1.Laue.id == sF2.Laue.id);

end
