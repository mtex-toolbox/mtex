function display(s)
% standard output

disp(' ');
l = size(horzcat(s.quaternion));
disp([inputname(1) ' = ' doclink('CrystalSymmetries','Symmetry') ' (size: ' int2str(l(1)) 'x' int2str(l(2)) ')']);
if ~isempty(s.mineral)
  disp(['  mineral: ',s.mineral ' (' s.laue ')']);  
else
  disp(['  name: ',s.name ' (' s.laue ')']);  
end

disp(' ');

