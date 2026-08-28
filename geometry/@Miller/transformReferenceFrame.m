function m = transformReferenceFrame(m,cs)
% change reference frame while keeping hkl or uvw

if m.framePrivate ~= cs
    
  M = transformationMatrix(m.CS,cs);
  m = rotate(m,rotation.byMatrix(M),1);

  m.framePrivate = cs;
  
end
