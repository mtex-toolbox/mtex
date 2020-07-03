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
        all(norm(S1.axes - S2.axes)./norm(S1.axes)<5*10^-2);
      
    end
    
  else
  
    if eq@handle(S1,S2)
      b = true;
    elseif S1.id == 0
      
      b = S2.id == 0 && numSym(S1) == numSym(S2) && max(angle(S1.rot(:),S2.rot(:)))<0.1 *degree;
      
    else 
      b = S1.id == S2.id && ...
        all(norm(S1.axes - S2.axes)./norm(S1.axes)<5*10^-2);
    end
  end
end
