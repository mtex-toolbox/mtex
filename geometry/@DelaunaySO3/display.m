function display(DSO3,varargin)
% standard output

displayClass(DSO3,inputname(1),varargin{:});

disp(['  size: ' size2str(DSO3)]);
disp(['  tetrahegons: ',int2str(size(DSO3.tetra,1))]);
disp(['  ' char(DSO3.CS,'verbose')]);
disp(['  ' char(DSO3.SS,'verbose')]);

if length(DSO3) < 30 && ~isempty(o), Euler(DSO3);end

disp(' ')
