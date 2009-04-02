function display(s)
% standard output

disp([inputname(1) ' = "symmetry"']);
disp(['name: ',s.name]);
disp(['laue: ',s.laue]);
l = size(horzcat(s.quat));
disp(['size: ' int2str(l(1)) 'x' int2str(l(2))]);
