function b = eq(S1,S2,varargin)
% check S1 == S2

if S1.id == S2.id
  b= true;
else
  Lid1 = symmetry.pointGroups(S1.id).LaueId;
  Lid2 = symmetry.pointGroups(S2.id).LaueId;

  b = Lid1 == Lid2;
end
