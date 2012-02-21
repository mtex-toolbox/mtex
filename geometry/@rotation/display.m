function display(rot,varargin)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('rotation_index','rotation') ' (size: ' int2str(size(rot)) ')']);

s = docmethods(inputname(1));

if numel(rot) < 30 && numel(rot)>0
  
  Euler(rot);
  s = s(2:end);
  
end

disp(s);