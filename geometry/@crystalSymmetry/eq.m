function b = eq(S1,S2,varargin)
% check S1 == S2

if ~isa(S1,'crystalSymmetry') || ~isa(S2,'crystalSymmetry')

  try
    b = S1.Laue.id == S2.Laue.id;
  catch
    b = false;
  end
  
else

  if check_option(varargin,'Laue')
  
    if eq@handle(S1,S2)
      b = true;
    else
      
      Lid1 = symmetry.pointGroups(S1.id).LaueId;
      Lid2 = symmetry.pointGroups(S2.id).LaueId;
            
      b = Lid1 == Lid2 && ...
        all(norm(S1.axes - S2.axes)./norm(S1.axes)<10^-2) && ...
        (isempty(S1.mineral) || isempty(S2.mineral) || strcmpi(S1.mineral,S2.mineral));
    end
    
  else
  
    if eq@handle(S1,S2)
      b = true;
    else
      b = S1.id == S2.id && ...
        all(norm(S1.axes - S2.axes)./norm(S1.axes)<10^-2) && ...
        (isempty(S1.mineral) || isempty(S2.mineral) || strcmpi(S1.mineral,S2.mineral));  
    end
  end
end
