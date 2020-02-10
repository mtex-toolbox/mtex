function b = eq(S1,S2,varargin)
% check S1 == S2

if eq@handle(S1,S2)
  
  b = true;
  
elseif check_option(varargin,'Laue')

  Lid1 = symmetry.pointGroups(S1.id).LaueId;
  Lid2 = symmetry.pointGroups(S2.id).LaueId;

  b = Lid1 == Lid2;
  
else
  
  b = S1.id == S2.id;
    
end
