function display(N)
% standard output

disp(' ')
disp([inputname(1) ' = ']);
disp(' ')

disp('  SO3Grid:')
for i = 1:length(N)
  disp(['   (',int2str(i),') ', char(N(i).CS) '/' char(N(i).SS) ': ' char(N(i))]);
end
disp(' ')
