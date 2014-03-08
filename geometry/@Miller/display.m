function display(m)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('Miller_index','Miller') ...
  ' ' docmethods(inputname(1))]);

display@vector3d(m,'skipHeader', 'skipCoordinates');

% display symmetry
if ~isempty(m.CS.mineral)
  disp([' mineral: ',char(m.CS,'verbose')]);
else
  disp([' symmetry: ',char(m.CS,'verbose')]);
end

% display coordinates
if length(m) < 20 && ~isempty(m)
  
  eps = 1e4;
  
  switch m.dispStyle
    
    case 'uvw'
      
      uvtw = round(m.uvw * eps)./eps;
      uvtw(uvtw==0) = 0;
      
      if any(strcmp(m.CS.lattice,{'trigonal','hexagonal'}))
        cprintf(uvtw.','-L','  ','-Lr',{'u' 'v' 't' 'w'});
      else
        cprintf(uvtw.','-L','  ','-Lr',{'u' 'v' 'w'});
      end
    
    case 'hkl'
    
      hkl = round(m.hkl * eps)./eps;
      hkl(hkl==0) = 0;
      if any(strcmp(m.CS.lattice,{'trigonal','hexagonal'}))                
        cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'i' 'l'});
      else
        cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'l'});
      end
    case 'xyz'
        
  end
end
