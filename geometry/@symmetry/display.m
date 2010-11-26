function display(s)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('symmetry_index','symmetry') ' (size: ' int2str(numel(s)) ')']);

convention = get(s,'convention');
if ~isempty(s.mineral)
  disp(['  mineral: ',s.mineral ' (' option2str([{s.name},convention]) ')']);  
else
  disp(['  name: ',s.name ' (' option2str([{s.laue},convention]) ')']);  
end

disp(' ');

