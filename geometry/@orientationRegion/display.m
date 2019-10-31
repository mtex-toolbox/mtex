function display(oR,varargin)
% standard output

displayClass(oR,inputname(1),varargin{:});

disp(' ');

% display symmetry
dispLine(oR.CS1);
dispLine(oR.CS2);

if oR.antipodal, disp(' antipodal: true'); end

disp([' max angle: ',num2str(oR.maxAngle./degree) mtexdegchar])
disp([' ' varlink([inputname(1),'.N'],'face normales') ': ',num2str(length(oR.N))])
disp([' ' varlink([inputname(1),'.V'],'vertices') ': ',num2str(length(oR.V))])

disp(' ');