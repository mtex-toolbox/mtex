function display(s)
% standard output

disp([inputname(1) ' = "symmetry"']);
if ~isempty(s.mineral)
  disp(['mineral: ',s.mineral]);  
else
  disp(['name: ',s.name]);  
end
disp(['laue: ',s.laue]);
l = size(horzcat(s.quat));
disp(['size: ' int2str(l(1)) 'x' int2str(l(2))]);
