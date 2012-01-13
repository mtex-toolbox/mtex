function display(rot,varargin)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('rotation_index','rotation') ' (size: ' int2str(size(rot)) ')']);

if numel(rot) < 30 && numel(rot)>0
  
  Euler(rot);
  
else
  
  disp(' ');
  
end

if get_mtex_option('mtexMethodsAdvise',true)
  disp(['    <a href="matlab:docmethods(' inputname(1) ')">Methods</a>'])
  disp(' ')
end
