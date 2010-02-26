function display(rot)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('rotation_index','rotation') ' (size: ' int2str(size(rot)) ')']);

if numel(rot) < 30 && numel(rot)>0
  
  Euler(rot);  
  
else
  
  disp(' ');

end