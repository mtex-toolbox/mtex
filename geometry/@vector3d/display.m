function display(v,varargin)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('vector3d_index','vector3d') ...
  ' ' docmethods(inputname(1))]);

disp([' size: ' size2str(v)]);

if v.antipodal
  disp(' antipodal: true');
end

if v.resolution < 2*pi
  disp([' resolution: ',xnum2str(v.resolution/degree),mtexdegchar]);
end

if check_option(varargin,'all') || (length(v) < 20 && ~isempty(v))
  
  d = [v.x(:),v.y(:),v.z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end
