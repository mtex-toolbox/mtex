function display(S2G)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('S2Grid_index','S2Grid') ...
  ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(S2G)]);

if S2G.antipodal, disp(' antipodal: true'); end

if isProp(S2G,'resolution')
  disp([' resolution: ',xnum2str(getProp(S2G,'resolution')/degree),mtexdegchar]);
end

if length(S2G) < 20 && ~isempty(S2G)
  
  [x,y,z] = double(S2G);
  d = [x(:),y(:),z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end
