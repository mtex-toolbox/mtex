function display(S2G)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ', points: ',...
  char(S2G),', ',char(option2str(check_option(S2G)))]);

if numel(S2G) < 20 && numel(S2G)>0
  
  [x,y,z] = double(S2G);
  d = [x(:),y(:),z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end


disp(' ');
