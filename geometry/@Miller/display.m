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
  
    if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
      cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'i' 'l'});
    else
      cprintf(hkl.','-L','  ','-Lr',{'h' 'k' 'l'});
    end
    
  end
end

disp(' ');
if get_mtex_option('mtexMethodsAdvise',true)
  disp(['    <a href="matlab:docmethods(' inputname(1) ')">Methods</a>'])
  disp(' ')
end

