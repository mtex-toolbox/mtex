function display(oR,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('orientationRegion_index','orientationRegion') ...
    ' ' docmethods(inputname(1))]);
end

disp(' ');

% display symmetry
dispLine(oR.CS1);
dispLine(oR.CS2);

if oR.antipodal, disp(' antipodal: true'); end

disp([' max angle: ',num2str(oR.maxAngle./degree) mtexdegchar])
disp([' ' varlink([inputname(1),'.N'],'face normales') ': ',num2str(length(oR.N))])
disp([' ' varlink([inputname(1),'.V'],'vertices') ': ',num2str(length(oR.V))])

disp(' ');