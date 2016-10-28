function display(oR,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('orientationRegion_index','orientationRegion') ...
    ' ' docmethods(inputname(1))]);
end

% display symmetry
dispLine(oR.CS1);
dispLine(oR.CS2);

if oR.antipodal, disp(' antipodal: true'); end

disp([' ' varlink([inputname(1),'.N'],'face normales') ': ',size2str(oR.N)])
disp([' ' varlink([inputname(1),'.V'],'vertices') ': ',size2str(oR.V)])
