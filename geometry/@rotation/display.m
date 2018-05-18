function display(rot,varargin)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('rotation_index','rotation')...
  ' ' docmethods(inputname(1))]);
disp(['  size: ' size2str(rot)]);

if length(rot) < 20 && ~isempty(rot)
  
  Euler(rot);
  
else
  disp(' ')
end


