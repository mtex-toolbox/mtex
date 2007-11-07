function display(k)
% standard output

disp([inputname(1) ' = "kernel"']);
disp(['type: ',char(k(1))]);
for i = 2:length(k)
    disp(['type: ',char(k(i))]);
end
