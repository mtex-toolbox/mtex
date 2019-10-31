function display(sF,varargin)
% standard output

displayClass(sF,inputname(1),varargin{:});

% display symmetry
%dispLine(oR.CS1);
%dispLine(oR.CS2);

%if sF.antipodal, disp(' antipodal: true'); end

disp(' ');
disp([' ' varlink([inputname(1),'.vertices'],'vertices') ': ',size2str(sF.vertices)])
disp([' ' varlink([inputname(1),'.values'],'values') ':   ',size2str(sF.values)])
