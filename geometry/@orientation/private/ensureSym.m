function [a,left,right] = ensureSym(a,b)
% ensure a and b have compatible symmetries

% collect inner and outer symmetries
[left,inner1] = extractSym(a);
[inner2,right] = extractSym(b);

% ensure inner symmetries coincide
if isempty(inner1)  % e.g. rot * ori
  
  if ~isempty(inner2) && inner2.id > 2 && ... 
      ~(isa(a,'rotation') && all(max(dot_outer(inner2.rot,a))>0.99))
    warning('Rotation does not respect symmetry!');
  end
  left = inner2;
  
elseif isempty(inner2) % e.g. ori * rot, ori * vector3d
  
  if isa(inner1,'crystalSymmetry') && ~isa(b,'rotation') % ori * vector3d
    
    warning('Possibly applying an orientation to an object in specimen coordinates!');
    
  elseif isa(b,'rotation') && inner1.id > 2 && ~all(max(dot_outer(inner1.rot,b))>0.99)
    
    warning('Rotation does not respect symmetry!');
    
  end
  right = inner1;
  
elseif ~eq(inner1,inner2,'Laue') % ori * ori, ori * Miller
  
  if isa(inner1,'crystalSymmetry') && isa(inner2,'specimenSymmetry')
    
    warning('Possibly applying an orientation to an object in specimen coordinates!');
    
  elseif isa(inner2,'crystalSymmetry') && isa(inner1,'specimenSymmetry')
  
    warning('Possibly applying an inverse orientation to an object in crystal coordinates!');
    
  elseif isa(inner2,'crystalSymmetry') && isa(inner1,'crystalSymmetry')
    a = a.transformReferenceFrame(inner2);
  end
end