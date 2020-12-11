function m = transformReferenceFrame(m,cs)
% change reference frame while keeping hkl or uvw

if m.CSprivate ~= cs
    
  M = transformationMatrix(m.CS,cs);
  m = rotate(m,rotation('matrix',M),1);

  m.CSprivate = cs;
  
end
