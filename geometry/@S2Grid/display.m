function display(S2G)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ...
  ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(S2G)]);

o = char(option2str(check_option(S2G)));
if ~isempty(o)
  disp(['  options: ' o]);
end

if numel(S2G) < 20 && numel(S2G)>0
  
  [x,y,z] = double(S2G);
  d = [x(:),y(:),z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end
