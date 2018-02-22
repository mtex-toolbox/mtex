function display(sF,varargin)
% standard output

if ~check_option(varargin,'skipHeader')
  disp(' ');
  disp([inputname(1) ' = ' doclink('S2VectorFieldTri_index','S2VectorFieldTri') ...
    ' ' docmethods(inputname(1))]);
  disp(' ')
end

% display symmetry
%dispLine(oR.CS1);
%dispLine(oR.CS2);

%if sF.antipodal, disp(' antipodal: true'); end

disp([' ' varlink([inputname(1),'.vertices'],'vertices') ': ',size2str(sF.vertices)])
disp([' ' varlink([inputname(1),'.values'],'values') ':   ',size2str(sF.values)])
