function display(s)
% standard output

disp([inputname(1) ' = "symmetry"']);
disp(['name: ',s.name]);
disp(['laue: ',s.laue]);
disp(['size: ',int2str(numel(s.quat))]);
