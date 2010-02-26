function display(o)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('orientation_index','orientation') ' (size: ' int2str(size(o)) ')']);
disp(['  symmetry: ',char(o.CS),' - ',char(o.SS)]);

if numel(o) < 30 && numel(o)>0
  
  Euler(o);
  
else

  disp(' ');
  
end

