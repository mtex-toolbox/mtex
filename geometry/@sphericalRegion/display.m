function display(sR,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('sphericalRegion_index','sphericalRegion') ...
    ' ' docmethods(inputname(1))]);
end

disp(' ');

if sR.antipodal, disp(' antipodal: true'); end

disp([' ' varlink([inputname(1),'.N'],'edge normales') ': ',num2str(length(sR.N))])

disp(' ');