function display(sR,varargin)
% standard output

displayClass(sR,inputname(1),varargin{:});

disp(' ');

if sR.antipodal, disp(' antipodal: true'); end

disp([' ' varlink([inputname(1),'.N'],'edge normales') ': ',num2str(length(sR.N))])

disp(' ');