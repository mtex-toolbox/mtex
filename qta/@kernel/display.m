function display(k)
% standard output

disp(' ');
disp([inputname(1) ' = ' doclink('kernel_index','kernel') ' '...
  docmethods(inputname(1))]);
disp(['  type: ',char(k(1))]);
for i = 2:length(k)
    disp(['  type: ',char(k(i))]);
end
