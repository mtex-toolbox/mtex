function display(s)
% standard output

disp(' ');
disp([inputname(1) ' = ']);
disp(' ')
disp('  symmetry:')
for i=1:numel(s)
disp(['   name: ',s(i).name ', laue: ',s(i).laue ', size: ',int2str(numel(s(i).quat))]);
end
disp(' ')
