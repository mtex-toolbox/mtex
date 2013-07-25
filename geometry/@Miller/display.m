function display(m)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('Miller_index','Miller') ...
  ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(m)]);

o = char(option2str(m.options));
if ~isempty(o)
  disp(['  options: ' o]);
end

if ~isempty(get(m.CS,'mineral'))
  disp(['  mineral: ',char(m.CS,'verbose')]);
else
  disp(['  symmetry: ',char(m.CS,'verbose')]);
end

if length(m) < 20 && length(m) > 0
  
  eps = 1e4;
  
  switch m.dispStyle
    
    case 'uvw'
      
      uvtw = round(m.uvw * eps)./eps;
      uvtw(uvtw==0) = 0;
      
      if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
        cprintf(uvtw.','-L','  ','-Lr',{'u' 'v' 't' 'w'});
      else
        cprintf(uvtw.','-L','  ','-Lr',{'u' 'v' 'w'});
      end
    
    case 'hkl'
    
      hkl = round(m.hkl * eps)./eps;
      hkl(hkl==0) = 0;
      if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
        cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'i' 'l'});
      else
        cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'l'});
      end
    case 'xyz'
        
  end
end
