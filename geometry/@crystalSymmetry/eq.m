function b = eq(S1,S2)
% check S1 == S2

if ~isa(S1,'crystalSymmetry') || ~isa(S2,'crystalSymmetry')
  
  b = S1.Laue.id == S2.Laue.id;
  
else

  b = S1.Laue.id == S2.Laue.id && ...
    all(norm(S1.axes - S2.axes)./norm(S1.axes)<10^-2) && ...
    (isempty(S1.mineral) || isempty(S2.mineral) || strcmpi(S1.mineral,S2.mineral));
end
