function display(o)
% standart output

csss = {'sample symmetry ','crystal symmetry'};

disp(' ');
if isCS(o.SS) && isCS(o.CS)
  disp([inputname(1) ' = ' doclink('orientation_index','misorientation') ' (size: ' int2str(size(o)) ')']);
elseif isCS(o.SS)
  disp([inputname(1) ' = ' doclink('orientation_index','inverse orientation') ' (size: ' int2str(size(o)) ')']);
  
else
  disp([inputname(1) ' = ' doclink('orientation_index','orientation') ' (size: ' int2str(size(o)) ')']);
end
  
disp(['  ' csss{isCS(o.CS)+1} ': ', char(o.CS,'verbose')]);
disp(['  ' csss{isCS(o.SS)+1} ': ',char(o.SS,'verbose')]);


s = docmethods(inputname(1));


if numel(o) < 30 && numel(o)>0
  
  Euler(o);
  s = s(2:end);
  
end

disp(s);
