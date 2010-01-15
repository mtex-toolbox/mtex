function display(v)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('SpecimenDirections','vector3d') ': (size: ' int2str(size(v)) ')']);

if numel(v) < 20 && numel(v)>0
  
  d = [v.x(:),v.y(:),v.z(:)];
  d(abs(d) < 1e-10) = 0;
  
  cprintf(d,'-L','  ','-Lc',{'x' 'y' 'z'});
end

disp(' ');
