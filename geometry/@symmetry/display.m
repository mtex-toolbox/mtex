function display(s)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('symmetry_index','symmetry') ' (size: ' int2str(numel(s)) ')']);
if ~isempty(s.mineral)
  disp(['  mineral: ',s.mineral ' (' s.name ')']);  
else
  disp(['  name: ',s.name ' (' s.laue ')']);  
end

disp(' ');

