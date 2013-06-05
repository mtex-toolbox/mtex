function display(rot,varargin)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('rotation_index','rotation')...
  ' ' docmethods(inputname(1))]);
disp(['  size: ' size2str(rot)]);

if numel(rot) < 30 && numel(rot)>0
  
  Euler(rot);
  
end

disp(' ')
