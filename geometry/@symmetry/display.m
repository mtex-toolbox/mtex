function display(s)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('CrystalSymmetries','Symmetry') ' (size: ' int2str(numel(s)) ')']);
if ~isempty(s.mineral)
  disp(['  mineral: ',s.mineral ' (' s.laue ')']);  
else
  disp(['  name: ',s.name ' (' s.laue ')']);  
end

disp(' ');

