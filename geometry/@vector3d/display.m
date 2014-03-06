function display(v,varargin)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('vector3d_index','vector3d') ...
  ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(v)]);

o = char(option2str(check_option(v)));
if ~isempty(o)
  disp(['  options: ' o]);
end

if check_option(varargin,'all') || (numel(v) < 20 && numel(v)>0)
  
  d = [v.x(:),v.y(:),v.z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end
