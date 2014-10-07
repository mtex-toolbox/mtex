function display(DSO3)
% standard output

disp(' ');

disp([inputname(1) ' = ' doclink('DelaunaySO3_index','DelaunaySO3') ...
  ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(DSO3)]);
disp(['  tetrahegons: ',int2str(size(DSO3.tetra,1))]);
disp(['  ' char(DSO3.CS,'verbose')]);
disp(['  ' char(DSO3.SS,'verbose')]);

if length(DSO3) < 30 && ~isempty(o), Euler(DSO3);end

disp(' ')
