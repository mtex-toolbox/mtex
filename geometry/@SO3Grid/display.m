function display(N)
% standard output

disp(' ');

disp([inputname(1) ' = ' doclink('SO3Grid_index','SO3Grid') ...
  ' ' docmethods(inputname(1))]);

disp(['  symmetry: ',char(N.CS),' - ',char(N.SS)]);
disp(['  grid    : ',char(N)]);
