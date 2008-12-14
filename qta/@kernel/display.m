function display(k)
% standard output

disp(' ')
disp([inputname(1) ' = ']);
disp(' ')
disp('  kernel: ')
for i = 1:length(k)
    disp(['   (' n2str(i) ') ',char(k(i))]);
end
disp(' ')
