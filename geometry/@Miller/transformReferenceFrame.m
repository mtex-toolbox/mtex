function m = transformReferenceFrame(m,cs)
% change reference frame while keeping hkl or uvw

% recompute representation in cartesian coordinates
if m.CSprivate ~= cs
    
  M = transformationMatrix(m.CS,cs);
  m = rotate(m,rotation('matrix',M),1);

  m.CSprivate = cs;
  
end

%if m.lattice ~= 0
%
%  hkl = m.(m.dispStyle);
%  m.CSprivate = cs;
%  m.(m.dispStyle) = hkl;

%else
%end