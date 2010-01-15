function display(m)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('CrystalDirections','Miller') ' (size: ' int2str(size(m)) ')']);
disp(['  symmetry: ',char(m.CS)]);

if numel(m) < 20 && numel(m) > 0
  
  [h,k,l] = v2m(m);
  
  if any(strcmp(Laue(m.CS),{'-3','-3m','6/m','6/mmm'}))
    d = [h(:),k(:),-h(:)-k(:),l(:)];
  else
    d = [h(:),k(:),l(:)];
  end
  cprintf(d.','-L','  ','-Lr',{'h' 'k' 'l' 'i'});
end
disp(' ');
