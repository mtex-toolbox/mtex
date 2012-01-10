function display(N)
% standard output

disp(' ');

disp([inputname(1) ' = ' doclink('SO3Grid_index','SO3Grid')]);

disp(['  symmetry: ',char(N.CS),' - ',char(N.SS)]);
disp(['  grid    : ',char(N)]);

disp(' ');


if get_mtex_option('mtexMethodsAdvise',true)
  disp(['    <a href="matlab:docmethods(' inputname(1) ')">Methods</a>'])
  disp(' ')
end
