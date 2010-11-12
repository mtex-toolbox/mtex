function display(m)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('Miller_index','Miller') ' (size: ' int2str(size(m)),...
  '), ',char(option2str(check_option(m)))]);

disp(['  mineral: ',char(m.CS,'verbose')]);

if numel(m) < 20 && numel(m) > 0

  if check_option(m,'uvw')
    
    uvtw = v2d(m);
    
    if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
      cprintf(uvtw.','-L','  ','-Lr',{'u' 'v' 't' 'w'});
    else
      cprintf(uvtw.','-L','  ','-Lr',{'u' 'v' 'w'});
    end
        
  else
    
    hkl = v2m(m);
  
    cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'l' 'i'});
  end
end
disp(' ');
