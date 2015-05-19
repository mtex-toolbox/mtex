function m = transformReferenceFrame(m,cs)
% change reference frame while keeping hkl or uvw

% recompute representation in cartesian coordinates
if m.CSprivate ~= cs

  switch m.dispStyle
    
    case 'uvw'
      
      uvw = m.uvw;
      m.CSprivate = cs;
      m.uvw = uvw;
      
    case 'hkl'
      
      hkl = m.hkl;
      m.CSprivate = cs;
      m.hkl = hkl;
      
    otherwise
        
      M = transformationMatrix(m.CS,cs);
      v = rotate(m,rotation('matrix',M));
  
      [m.x,m.y,m.z] = double(v);
      m.CSprivate = cs;
  end
  
end
