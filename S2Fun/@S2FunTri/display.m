function display(sF,varargin)
% standard output

displayClass(sF,inputname(1),varargin{:});

disp(' ');
disp(['  ' varlink([inputname(1),'.vertices'],'vertices') ': ',size2str(sF.vertices)])
disp(['  ' varlink([inputname(1),'.values'],'values') ':   ',size2str(sF.values)])
